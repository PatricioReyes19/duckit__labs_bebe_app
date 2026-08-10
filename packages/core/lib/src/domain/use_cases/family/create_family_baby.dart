import '../../entities/family/family.dart';
import '../../repositories/family/family_repository.dart';

class CreateFamilyBaby {
  const CreateFamilyBaby(this._repository);

  final FamilyRepository _repository;

  Future<BabyEntity> call(BabyDraft draft) => _repository.createBaby(draft);
}
