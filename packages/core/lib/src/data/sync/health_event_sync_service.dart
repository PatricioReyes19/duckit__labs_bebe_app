import 'dart:async';

import '../datasources/remote/health_event_remote_data_source.dart';
import '../repositories/sqlite_health_repository.dart';
import 'register_event_sync_service.dart';

class HealthEventSyncService {
  HealthEventSyncService(
    this._local,
    this._remote, {
    ParentSyncBarrier? parentSyncBarrier,
    DateTime Function()? clock,
  }) : _parentSyncBarrier = parentSyncBarrier,
       _clock = clock ?? DateTime.now;

  final SqliteHealthRepository _local;
  final HealthEventRemoteDataSource _remote;
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
    final operation = _drain();
    _running = operation;
    return operation.whenComplete(() => _running = null);
  }

  Future<RegisterSyncState> _drain() async {
    var result = _state;
    while (_rerunRequested) {
      _rerunRequested = false;
      result = await _synchronizeOnce();
    }
    return result;
  }

  Future<RegisterSyncState> _synchronizeOnce() async {
    var pendingCount = await _local.countPending();
    if (!_remote.isConfigured) {
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.disabled,
          pendingCount: pendingCount,
          message: 'Supabase no está configurado; Salud sigue local.',
        ),
      );
    }
    if (!await _remote.isAuthenticated()) {
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.waitingForAuthentication,
          pendingCount: pendingCount,
          message: 'Inicia sesión para sincronizar Salud.',
        ),
      );
    }

    final blockedByParent = await waitForParentSync(
      _parentSyncBarrier,
      pendingCount: pendingCount,
    );
    if (blockedByParent != null) return _emit(blockedByParent);

    _emit(
      RegisterSyncState(
        phase: RegisterSyncPhase.syncing,
        pendingCount: pendingCount,
      ),
    );
    var failedCount = 0;
    Object? lastError;
    var newest = await _local.readSyncCursor();
    var pullCompleted = false;
    while (pendingCount > 0 && failedCount == 0) {
      final pending = await _local.listPending();
      if (pending.isEmpty) break;
      for (final event in pending) {
        try {
          await _local.markSyncing(event);
          final remote = await _remote.push(event);
          await _local.markSynced(event);
          await _local.mergeRemote(remote);
          newest = _newest(newest, remote.updatedAt);
        } on Object catch (error) {
          failedCount += 1;
          lastError = error;
          await _local.markFailed(event, error);
        }
      }
      pendingCount = await _local.countPending();
    }
    try {
      final pulled = await _remote.pull(
        updatedAfter: await _local.readSyncCursor(),
      );
      for (final event in pulled) {
        await _local.mergeRemote(event);
        newest = _newest(newest, event.updatedAt);
      }
      pullCompleted = true;
    } on Object catch (error) {
      failedCount += 1;
      lastError = error;
    }
    if (pullCompleted && newest != null) await _local.writeSyncCursor(newest);
    pendingCount = await _local.countPending();
    if (failedCount == 0 && pendingCount > 0) {
      _rerunRequested = true;
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.syncing,
          pendingCount: pendingCount,
        ),
      );
    }
    final now = _clock().toUtc();
    return failedCount == 0
        ? _emit(
            RegisterSyncState(
              phase: RegisterSyncPhase.synced,
              lastSyncedAt: now,
            ),
          )
        : _emit(
            RegisterSyncState(
              phase: RegisterSyncPhase.failed,
              pendingCount: pendingCount,
              failedCount: failedCount,
              lastSyncedAt: newest == null ? null : now,
              message: lastError?.toString(),
            ),
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
