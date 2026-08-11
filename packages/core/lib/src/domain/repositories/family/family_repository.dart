import '../../entities/family/family.dart';

abstract interface class FamilyRepository {
  Stream<String> get activeBabyChanges;

  Future<FamilyOverviewEntity> getCurrent();

  Future<FamilyOverviewEntity> setActiveBaby(String babyId);

  Future<FamilyOverviewEntity> createInitialFamily(InitialFamilyDraft draft);

  Future<BabyEntity> createBaby(BabyDraft draft);

  Future<BabyEntity?> updateBaby(String id, BabyPatch patch);

  Future<FamilyMemberEntity> sendInvitation(FamilyInvitationDraft draft);

  Future<FamilyMemberEntity?> resendInvitation(String memberId);

  Future<void> cancelInvitation(String memberId);

  Future<FamilyOverviewEntity> joinCareCircle(JoinedCareCircleDraft draft);
}
