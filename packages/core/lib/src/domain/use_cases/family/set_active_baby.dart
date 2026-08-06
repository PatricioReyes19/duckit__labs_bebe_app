import '../../entities/family/family.dart';
import '../../repositories/family/family_repository.dart';

class SetActiveFamilyBaby {
  const SetActiveFamilyBaby(this._repository);

  final FamilyRepository _repository;

  Future<FamilyOverviewEntity> call(String babyId) {
    if (babyId.trim().isEmpty) {
      throw ArgumentError.value(babyId, 'babyId', 'Cannot be empty.');
    }
    return _repository.setActiveBaby(babyId);
  }
}
