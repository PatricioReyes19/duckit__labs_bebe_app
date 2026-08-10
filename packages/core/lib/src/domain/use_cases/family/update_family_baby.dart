import '../../entities/family/family.dart';
import '../../repositories/family/family_repository.dart';

class UpdateFamilyBaby {
  const UpdateFamilyBaby(this._repository);

  final FamilyRepository _repository;

  Future<BabyEntity?> call(String babyId, BabyPatch patch) =>
      _repository.updateBaby(babyId, patch);
}
