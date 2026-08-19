import '../../entities/family/family.dart';
import '../../repositories/family/family_repository.dart';

class GetFamilyOverview {
  GetFamilyOverview(this._repository);

  final FamilyRepository _repository;
  FamilyOverviewEntity? _cached;

  FamilyOverviewEntity? get cached => _cached;

  Stream<String> get activeBabyChanges => _repository.activeBabyChanges;

  Future<FamilyOverviewEntity> call() async {
    final overview = await _repository.getCurrent();
    _cached = overview;
    return overview;
  }
}
