import '../../entities/family/family.dart';

abstract interface class FamilyRepository {
  Future<FamilyOverviewEntity> getCurrent();

  Future<FamilyOverviewEntity> setActiveBaby(String babyId);

  Future<BabyEntity> createBaby(BabyDraft draft);

  Future<BabyEntity?> updateBaby(String id, BabyPatch patch);
}
