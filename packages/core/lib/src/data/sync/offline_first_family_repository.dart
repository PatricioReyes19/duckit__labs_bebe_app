import '../../domain/entities/family/family.dart';
import '../../domain/repositories/family/family_repository.dart';
import '../repositories/sqlite_family_repository.dart';
import 'background_sync.dart';
import 'family_sync_service.dart';
import 'register_event_sync_service.dart';

class OfflineFirstFamilyRepository implements FamilyRepository {
  const OfflineFirstFamilyRepository(this._local, this._syncService);

  final SqliteFamilyRepository _local;
  final FamilySyncService _syncService;

  @override
  Stream<String> get activeBabyChanges => _local.activeBabyChanges;

  @override
  Future<FamilyOverviewEntity> getCurrent() => _local.getCurrent();

  @override
  Future<FamilyOverviewEntity> setActiveBaby(String babyId) =>
      _local.setActiveBaby(babyId);

  @override
  Future<FamilyOverviewEntity> createInitialFamily(
    InitialFamilyDraft draft,
  ) async {
    final result = await _local.createInitialFamily(draft);
    _scheduleSync();
    return result;
  }

  @override
  Future<BabyEntity> createBaby(BabyDraft draft) async {
    final result = await _local.createBaby(draft);
    _scheduleSync();
    return result;
  }

  @override
  Future<BabyEntity?> updateBaby(String id, BabyPatch patch) async {
    final result = await _local.updateBaby(id, patch);
    if (result != null) _scheduleSync();
    return result;
  }

  @override
  Future<FamilyMemberEntity> sendInvitation(FamilyInvitationDraft draft) async {
    // The invitation RPC references the remote baby. Serialize both operations
    // so an invitation cannot race the first family upload.
    final syncState = await _syncService.synchronize();
    if (syncState.phase != RegisterSyncPhase.synced) {
      throw StateError(
        'No se pudo enviar la invitación. Conéctate a Internet e inténtalo nuevamente.',
      );
    }
    return _local.sendInvitation(draft);
  }

  @override
  Future<FamilyMemberEntity?> resendInvitation(String memberId) =>
      _local.resendInvitation(memberId);

  @override
  Future<void> cancelInvitation(String memberId) =>
      _local.cancelInvitation(memberId);

  @override
  Future<FamilyOverviewEntity> joinCareCircle(
    JoinedCareCircleDraft draft,
  ) async {
    final localResult = await _local.joinCareCircle(draft);
    _scheduleSync();
    return localResult;
  }

  void _scheduleSync() => scheduleBackgroundSync(
    _syncService.synchronize,
    operation: 'Family background synchronization',
  );
}
