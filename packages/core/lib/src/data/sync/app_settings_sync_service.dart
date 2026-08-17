import 'dart:async';

import '../datasources/remote/app_settings_remote_data_source.dart';
import '../models/app_settings_model.dart';
import '../repositories/sqlite_app_settings_repository.dart';
import 'register_event_sync_service.dart';

class AppSettingsSyncService {
  AppSettingsSyncService(
    this._local,
    this._remote, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SqliteAppSettingsRepository _local;
  final AppSettingsRemoteDataSource _remote;
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
    final local = await _local.readSyncRecord();
    final pendingCount =
        local == null || local.syncStatus == AppSettingsSyncStatus.synced
        ? 0
        : 1;
    if (!_remote.isConfigured) {
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.disabled,
          pendingCount: pendingCount,
          message:
              'Supabase no está configurado; las preferencias siguen locales.',
        ),
      );
    }
    if (!await _remote.isAuthenticated()) {
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.waitingForAuthentication,
          pendingCount: pendingCount,
          message: 'Inicia sesión para sincronizar las preferencias.',
        ),
      );
    }
    if (local == null) {
      _emit(const RegisterSyncState(phase: RegisterSyncPhase.syncing));
      try {
        final remote = await _remote.pull();
        if (remote != null) await _local.mergeRemote(remote);
        return _emit(
          RegisterSyncState(
            phase: RegisterSyncPhase.synced,
            lastSyncedAt: _clock().toUtc(),
          ),
        );
      } on Object catch (error) {
        return _emit(
          RegisterSyncState(
            phase: RegisterSyncPhase.failed,
            failedCount: 1,
            message: error.toString(),
          ),
        );
      }
    }

    _emit(
      RegisterSyncState(
        phase: RegisterSyncPhase.syncing,
        pendingCount: pendingCount,
      ),
    );
    try {
      if (local.syncStatus != AppSettingsSyncStatus.synced) {
        await _local.markSyncing(local);
        final remote = await _remote.push(local);
        await _local.markSynced(local);
        await _local.mergeRemote(remote);
      } else {
        final remote = await _remote.pull();
        if (remote != null) await _local.mergeRemote(remote);
      }
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.synced,
          lastSyncedAt: _clock().toUtc(),
        ),
      );
    } on Object catch (error) {
      if (local.syncStatus != AppSettingsSyncStatus.synced) {
        await _local.markFailed(local, error);
      }
      final remaining = await _local.readSyncRecord();
      return _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.failed,
          pendingCount:
              remaining == null ||
                  remaining.syncStatus == AppSettingsSyncStatus.synced
              ? 0
              : 1,
          failedCount: 1,
          message: error.toString(),
        ),
      );
    }
  }

  RegisterSyncState _emit(RegisterSyncState value) {
    _state = value;
    if (!_states.isClosed) _states.add(value);
    return value;
  }

  Future<void> close() => _states.close();
}
