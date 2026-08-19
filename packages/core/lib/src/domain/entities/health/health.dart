import '../family/family.dart';

enum HealthEventType { vaccine, pediatricControl, growthControl, consultation }

/// Estado persistido del ciclo de atención.
///
/// `due` y `attendancePending` también pueden derivarse desde `scheduled` para
/// no depender de un proceso en segundo plano que cambie filas por el paso del
/// tiempo. Nunca se deriva `notAttended`: requiere una decisión del cuidador.
enum HealthEventStatus {
  draft,
  scheduled,
  due,
  attendancePending,
  attendedPendingSummary,
  completed,
  notAttended,
  cancelled,
  rescheduled,
}

enum HealthAppointmentKind { wellChildControl, consultation }

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
    this.appointmentKind,
    this.reason,
    this.timezone,
    this.attendedAt,
    this.completedAt,
    this.professionalName,
    this.specialty,
    this.facility,
    this.caregiverIds = const [],
    this.notesBeforeVisit,
    this.questionsToAsk = const [],
    this.clinicalSummary,
    this.professionalAssessment,
    this.indications,
    this.medications = const [],
    this.measurements = const [],
    this.attachments = const [],
    this.nextAppointmentId,
    this.createdBy,
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
  final HealthAppointmentKind? appointmentKind;
  final String? reason;
  final String? timezone;
  final DateTime? attendedAt;
  final DateTime? completedAt;
  final String? professionalName;
  final String? specialty;
  final String? facility;
  final List<String> caregiverIds;
  final String? notesBeforeVisit;
  final List<String> questionsToAsk;
  final String? clinicalSummary;
  final String? professionalAssessment;
  final String? indications;
  final List<Map<String, Object?>> medications;
  final List<Map<String, Object?>> measurements;
  final List<String> attachments;
  final String? nextAppointmentId;
  final String? createdBy;
  final FamilyMemberEntity? caregiver;
  final String? _caregiverId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HealthSyncStatus syncStatus;
  final String? syncError;

  String? get caregiverId => _caregiverId ?? caregiver?.id;

  bool get isAppointment => appointmentKind != null;

  /// Estado visible según la fecha actual, sin mutar ni sincronizar la fila.
  HealthEventStatus effectiveStatus(DateTime now) {
    if (status != HealthEventStatus.scheduled) return status;
    final scheduledLocal = startsAt.toLocal();
    final nowLocal = now.toLocal();
    final scheduledDay = DateTime(
      scheduledLocal.year,
      scheduledLocal.month,
      scheduledLocal.day,
    );
    final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    if (scheduledDay.isBefore(today)) {
      return HealthEventStatus.attendancePending;
    }
    if (scheduledDay == today) return HealthEventStatus.due;
    return status;
  }
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
    this.appointmentKind,
    this.reason,
    this.timezone,
    this.attendedAt,
    this.completedAt,
    this.professionalName,
    this.specialty,
    this.facility,
    this.caregiverIds = const [],
    this.notesBeforeVisit,
    this.questionsToAsk = const [],
    this.clinicalSummary,
    this.professionalAssessment,
    this.indications,
    this.medications = const [],
    this.measurements = const [],
    this.attachments = const [],
    this.nextAppointmentId,
    this.createdBy,
  });

  final String babyId;
  final HealthEventType type;
  final String title;
  final String description;
  final DateTime startsAt;
  final String? caregiverId;
  final HealthEventStatus status;
  final HealthAppointmentKind? appointmentKind;
  final String? reason;
  final String? timezone;
  final DateTime? attendedAt;
  final DateTime? completedAt;
  final String? professionalName;
  final String? specialty;
  final String? facility;
  final List<String> caregiverIds;
  final String? notesBeforeVisit;
  final List<String> questionsToAsk;
  final String? clinicalSummary;
  final String? professionalAssessment;
  final String? indications;
  final List<Map<String, Object?>> medications;
  final List<Map<String, Object?>> measurements;
  final List<String> attachments;
  final String? nextAppointmentId;
  final String? createdBy;
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
    this.appointmentKind,
    this.reason,
    this.timezone,
    this.attendedAt,
    this.completedAt,
    this.professionalName,
    this.specialty,
    this.facility,
    this.caregiverIds,
    this.notesBeforeVisit,
    this.questionsToAsk,
    this.clinicalSummary,
    this.professionalAssessment,
    this.indications,
    this.medications,
    this.measurements,
    this.attachments,
    this.nextAppointmentId,
    this.createdBy,
  }) : assert(caregiverId == null || !clearCaregiver);

  final HealthEventType? type;
  final String? title;
  final String? description;
  final DateTime? startsAt;
  final String? caregiverId;
  final bool clearCaregiver;
  final HealthEventStatus? status;
  final HealthAppointmentKind? appointmentKind;
  final String? reason;
  final String? timezone;
  final DateTime? attendedAt;
  final DateTime? completedAt;
  final String? professionalName;
  final String? specialty;
  final String? facility;
  final List<String>? caregiverIds;
  final String? notesBeforeVisit;
  final List<String>? questionsToAsk;
  final String? clinicalSummary;
  final String? professionalAssessment;
  final String? indications;
  final List<Map<String, Object?>>? medications;
  final List<Map<String, Object?>>? measurements;
  final List<String>? attachments;
  final String? nextAppointmentId;
  final String? createdBy;
}
