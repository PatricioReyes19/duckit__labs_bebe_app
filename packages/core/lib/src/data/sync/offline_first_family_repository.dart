import 'dart:async';

import '../../domain/entities/family/family.dart';
import '../../domain/repositories/family/family_repository.dart';
import '../repositories/sqlite_family_repository.dart';
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
    unawaited(_syncService.synchronize());
    return result;
  }

  @override
  Future<BabyEntity> createBaby(BabyDraft draft) async {
    final result = await _local.createBaby(draft);
    unawaited(_syncService.synchronize());
    return result;
  }

  @override
  Future<BabyEntity?> updateBaby(String id, BabyPatch patch) async {
    final result = await _local.updateBaby(id, patch);
    unawaited(_syncService.synchronize());
    return result;
  }

  @override
  Future<FamilyMemberEntity> sendInvitation(FamilyInvitationDraft draft) async {
    // The invitation RPC references the remote baby. Serialize both operations
    // so an invitation cannot race the first family upload.
    await _syncService.synchronize();
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
    final syncState = await _syncService.synchronize();
    if (syncState.phase != RegisterSyncPhase.synced) return localResult;
    return _local.getCurrent();
  }
}
