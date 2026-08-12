import 'dart:async';

import '../../domain/repositories/session_repository/session_repository.dart';
import '../datasources/remote/profile_remote_data_source.dart';
import 'agenda_event_sync_service.dart';
import 'app_settings_sync_service.dart';
import 'family_sync_service.dart';
import 'health_event_sync_service.dart';
import 'register_agenda_coordinator.dart';
import 'register_event_sync_service.dart';

enum InitialDataSyncPhase {
  idle,
  syncing,
  waitingForAuthentication,
  disabled,
  ready,
  failed,
}

enum RealtimeSyncTarget { register, agenda, health, preferences, family }

class InitialDataSyncState {
  const InitialDataSyncState({
    required this.phase,
    this.familyState,
    this.registerState,
    this.agendaState,
    this.healthState,
    this.preferencesState,
    this.message,
  });

  const InitialDataSyncState.idle() : this(phase: InitialDataSyncPhase.idle);

  final InitialDataSyncPhase phase;
  final RegisterSyncState? familyState;
  final RegisterSyncState? registerState;
  final RegisterSyncState? agendaState;
  final RegisterSyncState? healthState;
  final RegisterSyncState? preferencesState;
  final String? message;

  bool get localGraphReady => switch (phase) {
    InitialDataSyncPhase.ready || InitialDataSyncPhase.disabled => true,
    _ => false,
  };
}

/// Serializes the parent/child hydration graph for cold start and Realtime.
///
/// Family/Babies is always the barrier for Baby-owned aggregates. Realtime
/// uses the same queue so a callback cannot interleave with initial hydration
/// or with another callback.
class InitialDataSyncCoordinator {
  InitialDataSyncCoordinator(
    this._sessionRepository,
    this._profileRemoteDataSource,
    this._familySyncService,
    this._registerSyncService,
    this._agendaSyncService,
    this._healthSyncService,
    this._appSettingsSyncService,
    this._registerAgendaCoordinator,
  );

  final SessionRepository _sessionRepository;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final FamilySyncService _familySyncService;
  final RegisterEventSyncService _registerSyncService;
  final AgendaEventSyncService _agendaSyncService;
  final HealthEventSyncService _healthSyncService;
  final AppSettingsSyncService _appSettingsSyncService;
  final RegisterAgendaCoordinator _registerAgendaCoordinator;
  final _states = StreamController<InitialDataSyncState>.broadcast();

  InitialDataSyncState _state = const InitialDataSyncState.idle();
  Future<void> _tail = Future<void>.value();

  InitialDataSyncState get state => _state;
  Stream<InitialDataSyncState> get states => _states.stream;

  Future<InitialDataSyncState> synchronize({
    Future<void> Function()? startRealtime,
  }) => _enqueue(() => _synchronizeInitial(startRealtime));

  Future<void> synchronizeFromRealtime(RealtimeSyncTarget target) =>
      _enqueue(() => _synchronizeRealtimeTarget(target));

  Future<InitialDataSyncState> _synchronizeInitial(
    Future<void> Function()? startRealtime,
  ) async {
    final session = await _sessionRepository.currentSession();
    if (session == null) {
      return _emit(
        const InitialDataSyncState(
          phase: InitialDataSyncPhase.waitingForAuthentication,
          message: 'La hidratación inicial espera una sesión autenticada.',
        ),
      );
    }

    _emit(const InitialDataSyncState(phase: InitialDataSyncPhase.syncing));
    try {
      // A persisted Firebase session does not pass through AuthService's
      // post-login hook. Reassert its profile before any table that now
      // references profiles(id).
      await _profileRemoteDataSource.syncAuthenticatedUser(session.user);
      final family = await _familySyncService.synchronize();
      if (!_familyAllowsChildren(family)) {
        return _emit(
          InitialDataSyncState(
            phase: family.phase == RegisterSyncPhase.waitingForAuthentication
                ? InitialDataSyncPhase.waitingForAuthentication
                : InitialDataSyncPhase.failed,
            familyState: family,
            message:
                family.message ??
                'Family/Babies no pudo hidratarse localmente.',
          ),
        );
      }

      // Do not parallelize: all following tables contain Baby-owned children.
      final register = await _registerSyncService.synchronize();
      final agenda = await _agendaSyncService.synchronize();
      final health = await _healthSyncService.synchronize();
      final preferences = await _appSettingsSyncService.synchronize();
      await _registerAgendaCoordinator.reconcile();
      _registerAgendaCoordinator.startListening();
      await startRealtime?.call();

      final childStates = [register, agenda, health, preferences];
      final failed = childStates.any(
        (state) => state.phase == RegisterSyncPhase.failed,
      );
      return _emit(
        InitialDataSyncState(
          phase: failed
              ? InitialDataSyncPhase.failed
              : family.phase == RegisterSyncPhase.disabled
              ? InitialDataSyncPhase.disabled
              : InitialDataSyncPhase.ready,
          familyState: family,
          registerState: register,
          agendaState: agenda,
          healthState: health,
          preferencesState: preferences,
          message: failed
              ? 'La estructura local es válida, pero una sincronización hija '
                    'quedó pendiente de reintento.'
              : null,
        ),
      );
    } on Object catch (error) {
      return _emit(
        InitialDataSyncState(
          phase: InitialDataSyncPhase.failed,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _synchronizeRealtimeTarget(RealtimeSyncTarget target) async {
    if (target == RealtimeSyncTarget.preferences) {
      await _appSettingsSyncService.synchronize();
      return;
    }

    final family = await _familySyncService.synchronize();
    if (!_familyAllowsChildren(family)) return;

    switch (target) {
      case RealtimeSyncTarget.register:
        await _registerSyncService.synchronize();
        await _registerAgendaCoordinator.reconcile();

      case RealtimeSyncTarget.agenda:
        await _agendaSyncService.synchronize();

      case RealtimeSyncTarget.health:
        await _healthSyncService.synchronize();

      case RealtimeSyncTarget.family:
        // A prior child notification may have been skipped while Family was
        // unavailable. Pull all Baby-owned children to guarantee convergence.
        await _registerSyncService.synchronize();
        await _agendaSyncService.synchronize();
        await _healthSyncService.synchronize();
        await _registerAgendaCoordinator.reconcile();

      case RealtimeSyncTarget.preferences:
        break;
    }
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await action());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  InitialDataSyncState _emit(InitialDataSyncState value) {
    _state = value;
    if (!_states.isClosed) _states.add(value);
    return value;
  }

  static bool _familyAllowsChildren(RegisterSyncState state) =>
      switch (state.phase) {
        RegisterSyncPhase.synced || RegisterSyncPhase.disabled => true,
        _ => false,
      };

  Future<void> close() async {
    await _tail;
    await _states.close();
  }
}
