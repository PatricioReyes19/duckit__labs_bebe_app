import '../../entities/health/health.dart';

abstract interface class HealthRepository {
  Future<HealthOverviewEntity> getOverview(String babyId);

  Future<HealthEventEntity> createEvent(HealthEventDraft draft);

  Future<HealthEventEntity?> updateEvent(String id, HealthEventPatch patch);
}
