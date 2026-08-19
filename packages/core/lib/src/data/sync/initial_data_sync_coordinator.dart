import 'dart:async';

import '../../domain/repositories/session_repository/session_repository.dart';
import '../datasources/remote/profile_remote_data_source.dart';
import 'agenda_event_sync_service.dart';
import 'app_settings_sync_service.dart';
import 'family_sync_service.dart';
import 'health_event_sync_service.dart';
import 'register_agenda_coordinator.dart';
import 'register_event_sync_service.dart';
import 'sync_ux_state.dart';

enum InitialDataSyncPhase {
  idle,
  syncing,
  waitingForAuthentication,
  disabled,
  ready,
  failed,
}

enum RealtimeSyncTarget { register, agenda, health, preferences, family }

enum InitialDataSyncMilestone {
  profileHydrated,
  familyHydrated,
  domainSyncStarted,
  domainSyncCompleted,
}

typedef InitialDataSyncObserver =
    void Function(InitialDataSyncMilestone milestone);

typedef InitialDataSyncContextBarrier = Future<bool> Function();

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
  ) {
    _observe(_familySyncService.states);
    _observe(_registerSyncService.states);
    _observe(_agendaSyncService.states);
    _observe(_healthSyncService.states);
    _observe(_appSettingsSyncService.states);
    _refreshSyncUxState();
  }

  final SessionRepository _sessionRepository;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final FamilySyncService _familySyncService;
  final RegisterEventSyncService _registerSyncService;
  final AgendaEventSyncService _agendaSyncService;
  final HealthEventSyncService _healthSyncService;
  final AppSettingsSyncService _appSettingsSyncService;
  final RegisterAgendaCoordinator _registerAgendaCoordinator;
  final _states = StreamController<InitialDataSyncState>.broadcast();
  final _syncUxStates = StreamController<SyncUxState>.broadcast();
  final _domainHydrationStates = StreamController<bool>.broadcast();
  final _syncSubscriptions = <StreamSubscription<RegisterSyncState>>[];

  InitialDataSyncState _state = const InitialDataSyncState.idle();
  SyncUxState _syncUxState = const SyncUxState.pending();
  bool _hasHydratedDomains = false;
  Future<void> _tail = Future<void>.value();
  final Set<RealtimeSyncTarget> _pendingRealtimeTargets = {};
  Completer<void>? _realtimeDrainCompleter;

  InitialDataSyncState get state => _state;
  Stream<InitialDataSyncState> get states => _states.stream;
  SyncUxState get syncUxState => _syncUxState;
  Stream<SyncUxState> get syncUxStates => _syncUxStates.stream;

  /// Indica que Register, Agenda, Salud y Preferencias ya terminaron su
  /// primer intento de hidratación para el contexto autenticado actual.
  ///
  /// Un fallo también completa el intento: las vistas dejan el skeleton y
  /// pueden mostrar el cache local junto con el estado accionable de sync.
  bool get hasHydratedDomains => _hasHydratedDomains;
  Stream<bool> get domainHydrationStates => _domainHydrationStates.stream;

  Future<InitialDataSyncState> synchronize({
    Future<void> Function()? startRealtime,
    InitialDataSyncObserver? onMilestone,
    InitialDataSyncContextBarrier? beforeDomainSync,
  }) => _enqueue(
    () => _synchronizeInitial(startRealtime, onMilestone, beforeDomainSync),
  );

  Future<void> synchronizeFromRealtime(RealtimeSyncTarget target) {
    _pendingRealtimeTargets.add(target);
    final active = _realtimeDrainCompleter;
    if (active != null) return active.future;

    final completer = Completer<void>();
    _realtimeDrainCompleter = completer;
    scheduleMicrotask(() async {
      try {
        while (_pendingRealtimeTargets.isNotEmpty) {
          final targets = Set<RealtimeSyncTarget>.of(_pendingRealtimeTargets);
          _pendingRealtimeTargets.clear();
          await _enqueue(() => _synchronizeRealtimeTargets(targets));
        }
        completer.complete();
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        _realtimeDrainCompleter = null;
      }
    });
    return completer.future;
  }

  /// Reutiliza exactamente la misma cola y secuencia del sync inicial.
  Future<SyncUxState> retry() async {
    await synchronize();
    return _syncUxState;
  }

  Future<InitialDataSyncState> _synchronizeInitial(
    Future<void> Function()? startRealtime,
    InitialDataSyncObserver? onMilestone,
    InitialDataSyncContextBarrier? beforeDomainSync,
  ) async {
    if (beforeDomainSync != null) _setDomainsHydrated(false);
    final session = await _sessionRepository.currentSession();
    if (session == null) {
      return _emit(
        const InitialDataSyncState(
          phase: InitialDataSyncPhase.waitingForAuthentication,
          message: 'La hidratación inicial espera una sesión autenticada.',
        ),
      );
    }

    final completesInitialDomainHydration =
        beforeDomainSync == null && !_hasHydratedDomains;
    _emit(const InitialDataSyncState(phase: InitialDataSyncPhase.syncing));
    try {
      // A persisted Firebase session does not pass through AuthService's
      // post-login hook. Reassert its profile before any table that now
      // references profiles(id).
      await _profileRemoteDataSource.syncAuthenticatedUser(session.user);
      onMilestone?.call(InitialDataSyncMilestone.profileHydrated);
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
      onMilestone?.call(InitialDataSyncMilestone.familyHydrated);

      if (beforeDomainSync != null && !await beforeDomainSync()) {
        return _emit(
          InitialDataSyncState(
            phase: family.phase == RegisterSyncPhase.disabled
                ? InitialDataSyncPhase.disabled
                : InitialDataSyncPhase.ready,
            familyState: family,
            message:
                'El contexto autenticado está listo; los datos restantes '
                'continuarán sincronizándose en segundo plano.',
          ),
        );
      }

      // Family/Babies is now hydrated. These repositories are independent
      // children, so serial awaits only lengthen cold start.
      onMilestone?.call(InitialDataSyncMilestone.domainSyncStarted);
      final childStates = await Future.wait<RegisterSyncState>([
        _registerSyncService.synchronize(),
        _agendaSyncService.synchronize(),
        _healthSyncService.synchronize(),
        _appSettingsSyncService.synchronize(),
      ]);
      final register = childStates[0];
      final agenda = childStates[1];
      final health = childStates[2];
      final preferences = childStates[3];
      await _registerAgendaCoordinator.reconcile();
      _registerAgendaCoordinator.startListening();
      await startRealtime?.call();
      onMilestone?.call(InitialDataSyncMilestone.domainSyncCompleted);

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
    } finally {
      if (completesInitialDomainHydration) _setDomainsHydrated(true);
    }
  }

  Future<void> _synchronizeRealtimeTargets(
    Set<RealtimeSyncTarget> targets,
  ) async {
    final preferencesRequested = targets.remove(RealtimeSyncTarget.preferences);
    final familyChanged = targets.contains(RealtimeSyncTarget.family);

    if (targets.isNotEmpty) {
      final family = familyChanged
          ? await _familySyncService.synchronize()
          : await _familySyncService.ensureSynchronized();
      if (_familyAllowsChildren(family)) {
        final syncRegister =
            familyChanged || targets.contains(RealtimeSyncTarget.register);
        final syncAgenda =
            familyChanged || targets.contains(RealtimeSyncTarget.agenda);
        final syncHealth =
            familyChanged || targets.contains(RealtimeSyncTarget.health);
        await Future.wait<void>([
          if (syncRegister) _registerSyncService.synchronize().then((_) {}),
          if (syncAgenda) _agendaSyncService.synchronize().then((_) {}),
          if (syncHealth) _healthSyncService.synchronize().then((_) {}),
          if (preferencesRequested)
            _appSettingsSyncService.synchronize().then((_) {}),
        ]);
        if (syncRegister) await _registerAgendaCoordinator.reconcile();
        return;
      }
    }

    if (preferencesRequested) await _appSettingsSyncService.synchronize();
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
    _refreshSyncUxState();
    return value;
  }

  void _setDomainsHydrated(bool value) {
    if (_hasHydratedDomains == value) return;
    _hasHydratedDomains = value;
    if (!_domainHydrationStates.isClosed) {
      _domainHydrationStates.add(value);
    }
  }

  void _observe(Stream<RegisterSyncState> states) {
    _syncSubscriptions.add(states.listen((_) => _refreshSyncUxState()));
  }

  void _refreshSyncUxState() {
    var next = resolveSyncUxState(
      {
        SyncUxScope.family: _familySyncService.state,
        SyncUxScope.register: _registerSyncService.state,
        SyncUxScope.agenda: _agendaSyncService.state,
        SyncUxScope.health: _healthSyncService.state,
        SyncUxScope.preferences: _appSettingsSyncService.state,
      },
      previous: _syncUxState,
      forceSyncing: _state.phase == InitialDataSyncPhase.syncing,
    );
    if (_state.phase == InitialDataSyncPhase.failed &&
        next.status != SyncUxStatus.error &&
        next.status != SyncUxStatus.offline) {
      next = SyncUxState(
        status: SyncUxStatus.error,
        lastSuccessfulSyncAt: next.lastSuccessfulSyncAt,
        pendingOperations: next.pendingOperations,
        errorKey: 'coordinator:${_state.message ?? 'unknown'}',
      );
    }
    if (next == _syncUxState) return;
    _syncUxState = next;
    if (!_syncUxStates.isClosed) _syncUxStates.add(next);
  }

  static bool _familyAllowsChildren(RegisterSyncState state) =>
      switch (state.phase) {
        RegisterSyncPhase.synced || RegisterSyncPhase.disabled => true,
        _ => false,
      };

  Future<void> close() async {
    await _realtimeDrainCompleter?.future;
    await _tail;
    for (final subscription in _syncSubscriptions) {
      await subscription.cancel();
    }
    await _states.close();
    await _syncUxStates.close();
    await _domainHydrationStates.close();
  }
}
