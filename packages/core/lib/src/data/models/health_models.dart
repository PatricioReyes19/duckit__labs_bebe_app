import 'dart:convert';

import '../../domain/entities/family/family.dart';
import '../../domain/entities/health/health.dart';
import '../../domain/entities/immunization/immunization.dart';

class HealthEventModel {
  const HealthEventModel({
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
    this.immunizationCatalogItemId,
    this.immunizationNameSnapshot,
    this.immunizationItemType,
    this.immunizationSourceType,
    this.immunizationSourceVersion,
    this.immunizationDoseLabel,
    this.lotNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = HealthSyncStatus.pending,
    this.caregiverId,
    this.caregiver,
    this.syncError,
  }) : createdAt = createdAt ?? startsAt,
       updatedAt = updatedAt ?? createdAt ?? startsAt;

  final String id;
  final String babyId;
  final HealthEventType type;
  final String title;
  final String description;
  final DateTime startsAt;
  final String? caregiverId;
  final FamilyMemberEntity? caregiver;
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
  final String? immunizationCatalogItemId;
  final String? immunizationNameSnapshot;
  final ImmunizationItemType? immunizationItemType;
  final ImmunizationSourceType? immunizationSourceType;
  final String? immunizationSourceVersion;
  final String? immunizationDoseLabel;
  final String? lotNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HealthSyncStatus syncStatus;
  final String? syncError;

  factory HealthEventModel.fromEntity(HealthEventEntity entity) =>
      HealthEventModel(
        id: entity.id,
        babyId: entity.babyId,
        type: entity.type,
        title: entity.title,
        description: entity.description,
        startsAt: entity.startsAt,
        caregiverId: entity.caregiverId,
        caregiver: entity.caregiver,
        status: entity.status,
        appointmentKind: entity.appointmentKind,
        reason: entity.reason,
        timezone: entity.timezone,
        attendedAt: entity.attendedAt,
        completedAt: entity.completedAt,
        professionalName: entity.professionalName,
        specialty: entity.specialty,
        facility: entity.facility,
        caregiverIds: entity.caregiverIds,
        notesBeforeVisit: entity.notesBeforeVisit,
        questionsToAsk: entity.questionsToAsk,
        clinicalSummary: entity.clinicalSummary,
        professionalAssessment: entity.professionalAssessment,
        indications: entity.indications,
        medications: entity.medications,
        measurements: entity.measurements,
        attachments: entity.attachments,
        nextAppointmentId: entity.nextAppointmentId,
        createdBy: entity.createdBy,
        immunizationCatalogItemId: entity.immunizationCatalogItemId,
        immunizationNameSnapshot: entity.immunizationNameSnapshot,
        immunizationItemType: entity.immunizationItemType,
        immunizationSourceType: entity.immunizationSourceType,
        immunizationSourceVersion: entity.immunizationSourceVersion,
        immunizationDoseLabel: entity.immunizationDoseLabel,
        lotNumber: entity.lotNumber,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        syncStatus: entity.syncStatus,
        syncError: entity.syncError,
      );

  factory HealthEventModel.fromRemoteJson(Map<String, dynamic> json) {
    final appointment = _jsonObject(json['appointment_payload']);
    return HealthEventModel(
      id: json['id']! as String,
      babyId: json['baby_id']! as String,
      type: _enumByName(HealthEventType.values, json['event_type']! as String),
      title: json['title']! as String,
      description: (json['description'] as String?) ?? '',
      startsAt: _remoteDate(json, 'starts_at'),
      caregiverId: json['caregiver_id'] as String?,
      status: _enumByName(HealthEventStatus.values, json['status']! as String),
      appointmentKind: _nullableEnumByName(
        HealthAppointmentKind.values,
        json['appointment_kind'] as String?,
      ),
      reason: appointment['reason'] as String?,
      timezone: appointment['timezone'] as String?,
      attendedAt: _optionalDate(appointment['attended_at']),
      completedAt: _optionalDate(appointment['completed_at']),
      professionalName: appointment['professional_name'] as String?,
      specialty: appointment['specialty'] as String?,
      facility: appointment['facility'] as String?,
      caregiverIds: _stringList(appointment['caregiver_ids']),
      notesBeforeVisit: appointment['notes_before_visit'] as String?,
      questionsToAsk: _stringList(appointment['questions_to_ask']),
      clinicalSummary: appointment['clinical_summary'] as String?,
      professionalAssessment: appointment['professional_assessment'] as String?,
      indications: appointment['indications'] as String?,
      medications: _objectList(appointment['medications']),
      measurements: _objectList(appointment['measurements']),
      attachments: _stringList(appointment['attachments']),
      nextAppointmentId: appointment['next_appointment_id'] as String?,
      createdBy: appointment['created_by'] as String?,
      immunizationCatalogItemId:
          appointment['immunization_catalog_item_id'] as String?,
      immunizationNameSnapshot:
          appointment['immunization_name_snapshot'] as String?,
      immunizationItemType: _nullableEnumByName(
        ImmunizationItemType.values,
        appointment['immunization_item_type'] as String?,
      ),
      immunizationSourceType: _nullableEnumByName(
        ImmunizationSourceType.values,
        appointment['immunization_source_type'] as String?,
      ),
      immunizationSourceVersion:
          appointment['immunization_source_version'] as String?,
      immunizationDoseLabel: appointment['immunization_dose_label'] as String?,
      lotNumber: appointment['lot_number'] as String?,
      createdAt: _remoteDate(json, 'created_at'),
      updatedAt: _remoteDate(json, 'updated_at'),
      syncStatus: HealthSyncStatus.synced,
    );
  }

  factory HealthEventModel.fromRow(Map<String, Object?> row) {
    final caregiverName = row['caregiver_name'] as String?;
    final appointment = _jsonObject(row['appointment_json']);
    return HealthEventModel(
      id: row['id']! as String,
      babyId: row['baby_id']! as String,
      type: _enumByName(HealthEventType.values, row['event_type']! as String),
      title: row['title']! as String,
      description: row['description']! as String,
      startsAt: DateTime.fromMillisecondsSinceEpoch(
        row['starts_at']! as int,
        isUtc: true,
      ),
      caregiverId: row['caregiver_id'] as String?,
      caregiver: caregiverName == null
          ? null
          : FamilyMemberEntity(
              id: row['caregiver_id']! as String,
              familyId: row['caregiver_family_id']! as String,
              name: caregiverName,
              role: row['caregiver_role']! as String,
              accessDescription: row['caregiver_access_description']! as String,
              status: (row['caregiver_status']! as String) == 'pending'
                  ? FamilyMemberStatus.pending
                  : FamilyMemberStatus.active,
            ),
      status: _enumByName(HealthEventStatus.values, row['status']! as String),
      appointmentKind: _nullableEnumByName(
        HealthAppointmentKind.values,
        row['appointment_kind'] as String?,
      ),
      reason: appointment['reason'] as String?,
      timezone: appointment['timezone'] as String?,
      attendedAt: _optionalDate(appointment['attended_at']),
      completedAt: _optionalDate(appointment['completed_at']),
      professionalName: appointment['professional_name'] as String?,
      specialty: appointment['specialty'] as String?,
      facility: appointment['facility'] as String?,
      caregiverIds: _stringList(appointment['caregiver_ids']),
      notesBeforeVisit: appointment['notes_before_visit'] as String?,
      questionsToAsk: _stringList(appointment['questions_to_ask']),
      clinicalSummary: appointment['clinical_summary'] as String?,
      professionalAssessment: appointment['professional_assessment'] as String?,
      indications: appointment['indications'] as String?,
      medications: _objectList(appointment['medications']),
      measurements: _objectList(appointment['measurements']),
      attachments: _stringList(appointment['attachments']),
      nextAppointmentId: appointment['next_appointment_id'] as String?,
      createdBy: appointment['created_by'] as String?,
      immunizationCatalogItemId:
          appointment['immunization_catalog_item_id'] as String?,
      immunizationNameSnapshot:
          appointment['immunization_name_snapshot'] as String?,
      immunizationItemType: _nullableEnumByName(
        ImmunizationItemType.values,
        appointment['immunization_item_type'] as String?,
      ),
      immunizationSourceType: _nullableEnumByName(
        ImmunizationSourceType.values,
        appointment['immunization_source_type'] as String?,
      ),
      immunizationSourceVersion:
          appointment['immunization_source_version'] as String?,
      immunizationDoseLabel: appointment['immunization_dose_label'] as String?,
      lotNumber: appointment['lot_number'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (row['created_at'] as int?) ?? row['starts_at']! as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (row['updated_at'] as int?) ?? row['starts_at']! as int,
        isUtc: true,
      ),
      syncStatus: _enumByName(
        HealthSyncStatus.values,
        (row['sync_status'] as String?) ?? HealthSyncStatus.pending.name,
      ),
      syncError: row['sync_error'] as String?,
    );
  }

  Map<String, Object?> toRow() => {
    'id': id,
    'baby_id': babyId,
    'event_type': type.name,
    'title': title,
    'description': description,
    'starts_at': startsAt.toUtc().millisecondsSinceEpoch,
    'caregiver_id': caregiverId,
    'status': status.name,
    'appointment_kind': appointmentKind?.name,
    'appointment_json': jsonEncode(_appointmentPayload),
    'created_at': createdAt.toUtc().millisecondsSinceEpoch,
    'updated_at': updatedAt.toUtc().millisecondsSinceEpoch,
    'sync_status': syncStatus.name,
    'sync_error': syncError,
  };

  Map<String, Object?> toRemoteJson() => {
    'id': id,
    'baby_id': babyId,
    'event_type': type.name,
    'title': title,
    'description': description,
    'starts_at': startsAt.toUtc().toIso8601String(),
    'caregiver_id': caregiverId,
    'status': status.name,
    'appointment_kind': appointmentKind?.name,
    'appointment_payload': _appointmentPayload,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  HealthEventEntity toEntity() => HealthEventEntity(
    id: id,
    babyId: babyId,
    type: type,
    title: title,
    description: description,
    startsAt: startsAt,
    caregiver: caregiver,
    caregiverId: caregiverId,
    status: status,
    appointmentKind: appointmentKind,
    reason: reason,
    timezone: timezone,
    attendedAt: attendedAt,
    completedAt: completedAt,
    professionalName: professionalName,
    specialty: specialty,
    facility: facility,
    caregiverIds: caregiverIds,
    notesBeforeVisit: notesBeforeVisit,
    questionsToAsk: questionsToAsk,
    clinicalSummary: clinicalSummary,
    professionalAssessment: professionalAssessment,
    indications: indications,
    medications: medications,
    measurements: measurements,
    attachments: attachments,
    nextAppointmentId: nextAppointmentId,
    createdBy: createdBy,
    immunizationCatalogItemId: immunizationCatalogItemId,
    immunizationNameSnapshot: immunizationNameSnapshot,
    immunizationItemType: immunizationItemType,
    immunizationSourceType: immunizationSourceType,
    immunizationSourceVersion: immunizationSourceVersion,
    immunizationDoseLabel: immunizationDoseLabel,
    lotNumber: lotNumber,
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: syncStatus,
    syncError: syncError,
  );

  static DateTime _remoteDate(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Invalid or missing remote date: $key');
    }
    return DateTime.parse(value).toUtc();
  }

  Map<String, Object?> get _appointmentPayload => {
    if (reason != null) 'reason': reason,
    if (timezone != null) 'timezone': timezone,
    if (attendedAt != null)
      'attended_at': attendedAt!.toUtc().toIso8601String(),
    if (completedAt != null)
      'completed_at': completedAt!.toUtc().toIso8601String(),
    if (professionalName != null) 'professional_name': professionalName,
    if (specialty != null) 'specialty': specialty,
    if (facility != null) 'facility': facility,
    if (caregiverIds.isNotEmpty) 'caregiver_ids': caregiverIds,
    if (notesBeforeVisit != null) 'notes_before_visit': notesBeforeVisit,
    if (questionsToAsk.isNotEmpty) 'questions_to_ask': questionsToAsk,
    if (clinicalSummary != null) 'clinical_summary': clinicalSummary,
    if (professionalAssessment != null)
      'professional_assessment': professionalAssessment,
    if (indications != null) 'indications': indications,
    if (medications.isNotEmpty) 'medications': medications,
    if (measurements.isNotEmpty) 'measurements': measurements,
    if (attachments.isNotEmpty) 'attachments': attachments,
    if (nextAppointmentId != null) 'next_appointment_id': nextAppointmentId,
    if (createdBy != null) 'created_by': createdBy,
    if (immunizationCatalogItemId != null)
      'immunization_catalog_item_id': immunizationCatalogItemId,
    if (immunizationNameSnapshot != null)
      'immunization_name_snapshot': immunizationNameSnapshot,
    if (immunizationItemType != null)
      'immunization_item_type': immunizationItemType!.name,
    if (immunizationSourceType != null)
      'immunization_source_type': immunizationSourceType!.name,
    if (immunizationSourceVersion != null)
      'immunization_source_version': immunizationSourceVersion,
    if (immunizationDoseLabel != null)
      'immunization_dose_label': immunizationDoseLabel,
    if (lotNumber != null) 'lot_number': lotNumber,
  };
}

class HealthMeasurementModel {
  const HealthMeasurementModel({
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

  factory HealthMeasurementModel.fromEntity(HealthMeasurementEntity entity) =>
      HealthMeasurementModel(
        id: entity.id,
        babyId: entity.babyId,
        type: entity.type,
        value: entity.value,
        unit: entity.unit,
        recordedAt: entity.recordedAt,
        source: entity.source,
      );

  factory HealthMeasurementModel.fromRow(Map<String, Object?> row) =>
      HealthMeasurementModel(
        id: row['id']! as String,
        babyId: row['baby_id']! as String,
        type: _enumByName(
          HealthMeasurementType.values,
          row['measurement_type']! as String,
        ),
        value: (row['value']! as num).toDouble(),
        unit: row['unit']! as String,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(
          row['recorded_at']! as int,
          isUtc: true,
        ),
        source: row['source']! as String,
      );

  Map<String, Object?> toRow() => {
    'id': id,
    'baby_id': babyId,
    'measurement_type': type.name,
    'value': value,
    'unit': unit,
    'recorded_at': recordedAt.toUtc().millisecondsSinceEpoch,
    'source': source,
  };

  HealthMeasurementEntity toEntity() => HealthMeasurementEntity(
    id: id,
    babyId: babyId,
    type: type,
    value: value,
    unit: unit,
    recordedAt: recordedAt,
    source: source,
  );
}

T _enumByName<T extends Enum>(List<T> values, String name) => values.firstWhere(
  (value) => value.name == name,
  orElse: () => throw FormatException('Unknown ${T.toString()}: $name'),
);

T? _nullableEnumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null || name.isEmpty) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Unknown ${T.toString()}: $name');
}

Map<String, dynamic> _jsonObject(Object? value) {
  if (value == null) return const {};
  final decoded = value is String ? jsonDecode(value) : value;
  return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
}

List<String> _stringList(Object? value) => value is List
    ? value.whereType<String>().toList(growable: false)
    : const [];

List<Map<String, Object?>> _objectList(Object? value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, Object?>.from(item))
          .toList(growable: false)
    : const [];

DateTime? _optionalDate(Object? value) => value is String && value.isNotEmpty
    ? DateTime.tryParse(value)?.toUtc()
    : null;
