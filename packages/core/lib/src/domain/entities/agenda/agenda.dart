import '../family/family.dart';

enum AgendaCategory { vaccines, controls, medication, exams }

enum AgendaSyncStatus { synced, pending, failed }

class AgendaEventEntity {
  const AgendaEventEntity({
    required this.id,
    required this.babyId,
    required this.category,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.syncStatus,
    this.caregiver,
  });

  final String id;
  final String babyId;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final FamilyMemberEntity? caregiver;
  final AgendaSyncStatus syncStatus;
}

class AgendaOverviewEntity {
  const AgendaOverviewEntity({
    required this.events,
    required this.remindersEnabled,
    required this.isOffline,
  });

  final List<AgendaEventEntity> events;
  final bool remindersEnabled;
  final bool isOffline;
}

class AgendaEventDraft {
  const AgendaEventDraft({
    required this.babyId,
    required this.category,
    required this.title,
    required this.description,
    required this.startsAt,
    this.caregiverId,
    this.syncStatus = AgendaSyncStatus.pending,
  });

  final String babyId;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final String? caregiverId;
  final AgendaSyncStatus syncStatus;
}

class AgendaEventPatch {
  const AgendaEventPatch({
    this.category,
    this.title,
    this.description,
    this.startsAt,
    this.caregiverId,
    this.clearCaregiver = false,
    this.syncStatus,
  }) : assert(caregiverId == null || !clearCaregiver);

  final AgendaCategory? category;
  final String? title;
  final String? description;
  final DateTime? startsAt;
  final String? caregiverId;
  final bool clearCaregiver;
  final AgendaSyncStatus? syncStatus;
}
