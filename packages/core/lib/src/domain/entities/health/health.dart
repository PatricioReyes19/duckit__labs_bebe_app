import '../family/family.dart';

enum HealthEventType { vaccine, pediatricControl, growthControl }

enum HealthEventStatus { scheduled, completed, cancelled }

enum HealthMeasurementType { weight, height }

enum HealthSyncStatus { synced, pending, syncing, failed }

class HealthEventEntity {
  const HealthEventEntity({
    required this.id,
    required this.babyId,
    required this.type,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.status,
    this.caregiver,
    String? caregiverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = HealthSyncStatus.pending,
    this.syncError,
  }) : _caregiverId = caregiverId,
       createdAt = createdAt ?? startsAt,
       updatedAt = updatedAt ?? createdAt ?? startsAt;

  final String id;
  final String babyId;
  final HealthEventType type;
  final String title;
  final String description;
  final DateTime startsAt;
  final HealthEventStatus status;
  final FamilyMemberEntity? caregiver;
  final String? _caregiverId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HealthSyncStatus syncStatus;
  final String? syncError;

  String? get caregiverId => _caregiverId ?? caregiver?.id;
}

class HealthMeasurementEntity {
  const HealthMeasurementEntity({
    required this.id,
    required this.babyId,
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.source,
  });

  final String id;
  final String babyId;
  final HealthMeasurementType type;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String source;
}

class HealthOverviewEntity {
  const HealthOverviewEntity({
    required this.events,
    required this.measurements,
  });

  final List<HealthEventEntity> events;
  final List<HealthMeasurementEntity> measurements;

  int get completedVaccines => events
      .where(
        (event) =>
            event.type == HealthEventType.vaccine &&
            event.status == HealthEventStatus.completed,
      )
      .length;

  int get pendingVaccines => events
      .where(
        (event) =>
            event.type == HealthEventType.vaccine &&
            event.status == HealthEventStatus.scheduled,
      )
      .length;
}

class HealthEventDraft {
  const HealthEventDraft({
    required this.babyId,
    required this.type,
    required this.title,
    required this.description,
    required this.startsAt,
    this.caregiverId,
    this.status = HealthEventStatus.scheduled,
  });

  final String babyId;
  final HealthEventType type;
  final String title;
  final String description;
  final DateTime startsAt;
  final String? caregiverId;
  final HealthEventStatus status;
}

class HealthEventPatch {
  const HealthEventPatch({
    this.type,
    this.title,
    this.description,
    this.startsAt,
    this.caregiverId,
    this.clearCaregiver = false,
    this.status,
  }) : assert(caregiverId == null || !clearCaregiver);

  final HealthEventType? type;
  final String? title;
  final String? description;
  final DateTime? startsAt;
  final String? caregiverId;
  final bool clearCaregiver;
  final HealthEventStatus? status;
}
