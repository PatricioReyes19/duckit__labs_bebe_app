import '../../entities/health/health.dart';
import '../../repositories/health/health_repository.dart';

class GetHealthOverview {
  const GetHealthOverview(this._repository);

  final HealthRepository _repository;

  Future<HealthOverviewEntity> call(String babyId) {
    if (babyId.trim().isEmpty) {
      throw ArgumentError.value(babyId, 'babyId', 'Cannot be empty.');
    }
    return _repository.getOverview(babyId);
  }
}
