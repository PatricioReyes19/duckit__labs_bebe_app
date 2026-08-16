import 'dart:async';

import '../repositories/sqlite_agenda_repository.dart';
import 'agenda_event_remote_data_source.dart';
import 'register_event_sync_service.dart';

/// Agenda uses the same observable sync vocabulary as register history so UI
/// can present one consistent offline state.
class AgendaEventSyncService {
  AgendaEventSyncService(
    this._local,
    this._remote, {
    ParentSyncBarrier? parentSyncBarrier,
    DateTime Function()? clock,
  }) : _parentSyncBarrier = parentSyncBarrier,
       _clock = clock ?? DateTime.now;

  final SqliteAgendaRepository _local;
  final AgendaEventRemoteDataSource _remote;
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
          message: 'Supabase no está configurado; la agenda sigue local.',
        ),
      );
    }
    if (!await _remote.isAuthenticated()) {
      return _emit(
        const RegisterSyncState(
          phase: RegisterSyncPhase.waitingForAuthentication,
          message: 'Inicia sesión para sincronizar la agenda.',
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
    DateTime? newest = await _local.readSyncCursor();
    var pullCompleted = false;
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
              pendingCount: pending.length,
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
