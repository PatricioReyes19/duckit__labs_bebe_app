import '../family/family.dart';
import '../register/register.dart';

enum AgendaCategory { vaccines, controls, medication, exams }

enum AgendaSyncStatus { synced, pending, syncing, failed }

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
    String? caregiverId,
    this.sourceRegisterEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.syncError,
  }) : _caregiverId = caregiverId,
       createdAt = createdAt ?? startsAt,
       updatedAt = updatedAt ?? createdAt ?? startsAt;

  final String id;
  final String babyId;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final FamilyMemberEntity? caregiver;
  final String? _caregiverId;
  final AgendaSyncStatus syncStatus;
  final String? sourceRegisterEventId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? syncError;

  bool get isDeleted => deletedAt != null;
  bool get isDerivedFromRegister => sourceRegisterEventId != null;
  String? get caregiverId => _caregiverId ?? caregiver?.id;
}

class AgendaOverviewEntity {
  const AgendaOverviewEntity({
    required this.events,
    required this.remindersEnabled,
    required this.isOffline,
    this.registerEvents = const [],
  });

  final List<AgendaEventEntity> events;
  final bool remindersEnabled;
  final bool isOffline;
  final List<RegisteredEvent> registerEvents;

  AgendaOverviewEntity copyWith({
    List<AgendaEventEntity>? events,
    bool? remindersEnabled,
    bool? isOffline,
    List<RegisteredEvent>? registerEvents,
  }) => AgendaOverviewEntity(
    events: events ?? this.events,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    isOffline: isOffline ?? this.isOffline,
    registerEvents: registerEvents ?? this.registerEvents,
  );
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
    this.id,
    this.sourceRegisterEventId,
  });

  final String babyId;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final String? caregiverId;
  final AgendaSyncStatus syncStatus;
  final String? id;
  final String? sourceRegisterEventId;
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
