import '../../entities/family/family.dart';
import '../../repositories/family/family_repository.dart';

class GetFamilyOverview {
  const GetFamilyOverview(this._repository);

  final FamilyRepository _repository;

  Stream<String> get activeBabyChanges => _repository.activeBabyChanges;

  Future<FamilyOverviewEntity> call() => _repository.getCurrent();
}
