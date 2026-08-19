import 'dart:async';

import '../../entities/health/health.dart';

abstract interface class HealthRepository {
  Stream<void> get changes;

  Future<HealthOverviewEntity> getOverview(String babyId);

  Future<HealthEventEntity> createEvent(HealthEventDraft draft);

  Future<HealthEventEntity?> getEvent(String id);

  Future<HealthEventEntity?> updateEvent(String id, HealthEventPatch patch);

  /// Conserva la cita original como `rescheduled` y crea la nueva cita.
  Future<HealthEventEntity?> rescheduleEvent(String id, DateTime startsAt);
}
