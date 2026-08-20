import 'dart:async';

import '../register/sqlite_register_event_repository.dart';
import 'remote_sync_cursor.dart';
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
  ParentSyncBarrier? parentSyncBarrier, {
  int pendingCount = 0,
}) async {
  if (parentSyncBarrier == null) return null;
  try {
    final parent = await parentSyncBarrier();
    if (parent.phase == RegisterSyncPhase.synced) return null;
    if (parent.phase == RegisterSyncPhase.waitingForAuthentication) {
      return RegisterSyncState(
        phase: RegisterSyncPhase.waitingForAuthentication,
        pendingCount: pendingCount,
        message: 'Inicia sesión para sincronizar el perfil del bebé.',
      );
    }
    return RegisterSyncState(
      phase: RegisterSyncPhase.failed,
      pendingCount: pendingCount,
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
      pendingCount: pendingCount,
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
    this._parentSyncBarrier,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SqliteRegisterEventRepository _local;
  final RegisterEventRemoteDataSource _remote;
  final ParentSyncBarrier? _parentSyncBarrier;
  final DateTime Function() _clock;
  final _states = StreamController<RegisterSyncState>.broadcast();
  RegisterSyncState _state = const RegisterSyncState.idle();
  Future<RegisterSyncState>? _running;
  bool _rerunRequested = false;
  static const pullPageSize = 200;

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
    var pendingCount = await _local.countPending();
    if (!_remote.isConfigured) {
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.disabled,
          pendingCount: pendingCount,
          message: 'Supabase no está configurado; los datos siguen locales.',
        ),
      );
    }
    if (!await _remote.isAuthenticated()) {
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.waitingForAuthentication,
          pendingCount: pendingCount,
          message: 'Inicia sesión para sincronizar los registros.',
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
    DateTime? newestRemoteTimestamp = await _local.readSyncCursor();
    RemoteSyncCursor? completedPullCursor;
    var pullCompleted = false;
    while (pendingCount > 0 && failedCount == 0) {
      final pending = await _local.listPending();
      if (pending.isEmpty) break;
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
      pendingCount = await _local.countPending();
    }

    try {
      final storedTimestamp = await _local.readSyncCursor();
      if (_remote case final PagedRegisterEventRemoteDataSource paged) {
        var cursor = storedTimestamp == null
            ? null
            : RemoteSyncCursor(
                updatedAt: storedTimestamp,
                id: await _local.readSyncCursorId() ?? '',
              );
        while (true) {
          final pulled = await paged.pullPage(
            after: cursor,
            limit: pullPageSize,
          );
          for (final event in pulled) {
            await _local.mergeRemote(event);
            newestRemoteTimestamp = _newest(
              newestRemoteTimestamp,
              event.updatedAt,
            );
            cursor = RemoteSyncCursor(updatedAt: event.updatedAt, id: event.id);
          }
          if (pulled.length < pullPageSize) break;
        }
        completedPullCursor = cursor;
      } else {
        final pulled = await _remote.pull(updatedAfter: storedTimestamp);
        for (final event in pulled) {
          await _local.mergeRemote(event);
          newestRemoteTimestamp = _newest(
            newestRemoteTimestamp,
            event.updatedAt,
          );
        }
      }
      pullCompleted = true;
    } on Object catch (error) {
      failedCount += 1;
      lastError = error;
    }

    // A successful push must not advance the pull cursor if the pull failed:
    // doing so could skip remote rows written by another caregiver.
    if (pullCompleted) {
      final cursor = completedPullCursor;
      if (cursor != null) {
        await _local.writeSyncCursor(cursor.updatedAt, id: cursor.id);
      } else if (newestRemoteTimestamp != null) {
        await _local.writeSyncCursor(newestRemoteTimestamp);
      }
    }
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
    if (failedCount > 0) {
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.failed,
          pendingCount: pendingCount,
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
