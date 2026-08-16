import 'dart:async';

import '../register/sqlite_register_event_repository.dart';
import 'register_event_remote_data_source.dart';

enum RegisterSyncPhase {
  disabled,
  waitingForAuthentication,
  idle,
  syncing,
  synced,
  failed,
}

class RegisterSyncState {
  const RegisterSyncState({
    required this.phase,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastSyncedAt,
    this.message,
  });

  const RegisterSyncState.idle() : this(phase: RegisterSyncPhase.idle);

  final RegisterSyncPhase phase;
  final int pendingCount;
  final int failedCount;
  final DateTime? lastSyncedAt;
  final String? message;
}

typedef ParentSyncBarrier = Future<RegisterSyncState> Function();

/// Prevents Baby-owned data from reaching Supabase before the canonical
/// Family/Baby aggregate. Local rows remain pending and are retried later.
Future<RegisterSyncState?> waitForParentSync(
  ParentSyncBarrier? parentSyncBarrier,
) async {
  if (parentSyncBarrier == null) return null;
  try {
    final parent = await parentSyncBarrier();
    if (parent.phase == RegisterSyncPhase.synced) return null;
    if (parent.phase == RegisterSyncPhase.waitingForAuthentication) {
      return const RegisterSyncState(
        phase: RegisterSyncPhase.waitingForAuthentication,
        message: 'Inicia sesión para sincronizar el perfil del bebé.',
      );
    }
    return RegisterSyncState(
      phase: RegisterSyncPhase.failed,
      failedCount: 1,
      message:
          'Primero debe sincronizarse el perfil del bebé. '
                  'Los cambios locales se conservaron para reintentarlos. '
                  '${parent.message ?? ''}'
              .trim(),
    );
  } on Object catch (error) {
    return RegisterSyncState(
      phase: RegisterSyncPhase.failed,
      failedCount: 1,
      message:
          'No se pudo confirmar el perfil del bebé. '
          'Los cambios locales se conservaron para reintentarlos. $error',
    );
  }
}

class RegisterEventSyncService {
  RegisterEventSyncService(
    this._local,
    this._remote, {
    ParentSyncBarrier? parentSyncBarrier,
    DateTime Function()? clock,
  }) : _parentSyncBarrier = parentSyncBarrier,
       _clock = clock ?? DateTime.now;

  final SqliteRegisterEventRepository _local;
  final RegisterEventRemoteDataSource _remote;
  final ParentSyncBarrier? _parentSyncBarrier;
  final DateTime Function() _clock;
  final _states = StreamController<RegisterSyncState>.broadcast();
  RegisterSyncState _state = const RegisterSyncState.idle();
  Future<RegisterSyncState>? _running;
  bool _rerunRequested = false;

  RegisterSyncState get state => _state;
  Stream<RegisterSyncState> get states => _states.stream;

  Future<RegisterSyncState> synchronize() {
    _rerunRequested = true;
    final running = _running;
    if (running != null) return running;
    final operation = _drainSyncQueue();
    _running = operation;
    return operation.whenComplete(() => _running = null);
  }

  Future<RegisterSyncState> _drainSyncQueue() async {
    var result = _state;
    while (_rerunRequested) {
      _rerunRequested = false;
      result = await _synchronizeOnce();
    }
    return result;
  }

  Future<RegisterSyncState> _synchronizeOnce() async {
    if (!_remote.isConfigured) {
      return _emit(
        const RegisterSyncState(
          phase: RegisterSyncPhase.disabled,
          message: 'Supabase no está configurado; los datos siguen locales.',
        ),
      );
    }
    if (!await _remote.isAuthenticated()) {
      return _emit(
        const RegisterSyncState(
          phase: RegisterSyncPhase.waitingForAuthentication,
          message: 'Inicia sesión para sincronizar los registros.',
        ),
      );
    }

    final blockedByParent = await waitForParentSync(_parentSyncBarrier);
    if (blockedByParent != null) return _emit(blockedByParent);

    final pending = await _local.listPending();
    _emit(
      RegisterSyncState(
        phase: RegisterSyncPhase.syncing,
        pendingCount: pending.length,
      ),
    );

    var failedCount = 0;
    Object? lastError;
    DateTime? newestRemoteTimestamp = await _local.readSyncCursor();
    var pullCompleted = false;
    for (final event in pending) {
      try {
        await _local.markSyncing(event);
        final remoteEvent = await _remote.push(event);
        await _local.markSynced(event);
        await _local.mergeRemote(remoteEvent);
        newestRemoteTimestamp = _newest(
          newestRemoteTimestamp,
          remoteEvent.updatedAt,
        );
      } on Object catch (error) {
        failedCount += 1;
        lastError = error;
        await _local.markFailed(event, error);
      }
    }

    try {
      final pulled = await _remote.pull(
        updatedAfter: await _local.readSyncCursor(),
      );
      for (final event in pulled) {
        await _local.mergeRemote(event);
        newestRemoteTimestamp = _newest(newestRemoteTimestamp, event.updatedAt);
      }
      pullCompleted = true;
    } on Object catch (error) {
      failedCount += 1;
      lastError = error;
    }

    // A successful push must not advance the pull cursor if the pull failed:
    // doing so could skip remote rows written by another caregiver.
    if (pullCompleted && newestRemoteTimestamp != null) {
      await _local.writeSyncCursor(newestRemoteTimestamp);
    }
    final now = _clock().toUtc();
    if (failedCount > 0) {
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.failed,
          pendingCount: pending.length,
          failedCount: failedCount,
          lastSyncedAt: newestRemoteTimestamp == null ? null : now,
          message: lastError?.toString(),
        ),
      );
    }
    return _emit(
      RegisterSyncState(phase: RegisterSyncPhase.synced, lastSyncedAt: now),
    );
  }

  RegisterSyncState _emit(RegisterSyncState value) {
    _state = value;
    if (!_states.isClosed) _states.add(value);
    return value;
  }

  Future<void> close() => _states.close();

  static DateTime _newest(DateTime? current, DateTime candidate) =>
      current == null || candidate.isAfter(current) ? candidate : current;
}
