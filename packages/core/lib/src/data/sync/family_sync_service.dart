import 'dart:async';

import '../datasources/remote/family_remote_data_source.dart';
import '../models/family_models.dart';
import '../repositories/sqlite_family_repository.dart';
import 'register_event_sync_service.dart';

/// Synchronizes the Family aggregate (family plus babies) as one unit.
/// Invitations keep their dedicated transactional RPCs.
class FamilySyncService {
  FamilySyncService(this._local, this._remote, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final SqliteFamilyRepository _local;
  final FamilyRemoteDataSource _remote;
  final DateTime Function() _clock;
  final _states = StreamController<RegisterSyncState>.broadcast();
  RegisterSyncState _state = const RegisterSyncState.idle();
  List<FamilySyncSnapshot>? _lastPulledSnapshots;
  Future<RegisterSyncState>? _running;
  bool _rerunRequested = false;

  RegisterSyncState get state => _state;
  Stream<RegisterSyncState> get states => _states.stream;
  List<FamilySyncSnapshot>? get lastPulledSnapshots => _lastPulledSnapshots;

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
    _lastPulledSnapshots = null;
    if (!_remote.isConfigured) {
      return _emit(
        const RegisterSyncState(
          phase: RegisterSyncPhase.disabled,
          message: 'Supabase no está configurado; Familia sigue local.',
        ),
      );
    }
    if (!await _remote.isAuthenticated()) {
      return _emit(
        const RegisterSyncState(
          phase: RegisterSyncPhase.waitingForAuthentication,
          message: 'Inicia sesión para sincronizar Familia.',
        ),
      );
    }

    FamilySyncSnapshot? pending;
    try {
      pending = await _local.readPendingSnapshot();
      _emit(
        RegisterSyncState(
          phase: RegisterSyncPhase.syncing,
          pendingCount: pending == null ? 0 : 1,
        ),
      );
      if (pending != null) {
        final accepted = await _remote.push(pending);
        await _local.markSnapshotSynced(attempted: pending, accepted: accepted);
      }
      try {
        final snapshots = await _remote.pull();
        await _local.mergeRemote(snapshots);
        _lastPulledSnapshots = List.unmodifiable(snapshots);
      } on FormatException {
        if (pending != null) rethrow;
        // A released compatibility client could create an incomplete remote
        // Baby and still leave the local snapshot marked as synchronized.
        // Repair that same canonical id once from the complete local graph.
        final repair = await _local.readPendingSnapshot(force: true);
        if (repair == null) rethrow;
        final accepted = await _remote.push(repair);
        await _local.markSnapshotSynced(attempted: repair, accepted: accepted);
        final snapshots = await _remote.pull();
        await _local.mergeRemote(snapshots);
        _lastPulledSnapshots = List.unmodifiable(snapshots);
      }
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
          pendingCount: pending == null ? 0 : 1,
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
