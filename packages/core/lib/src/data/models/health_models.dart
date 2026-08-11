import '../../domain/entities/family/family.dart';
import '../../domain/entities/health/health.dart';

class HealthEventModel {
  const HealthEventModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.status,
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
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        syncStatus: entity.syncStatus,
        syncError: entity.syncError,
      );

  factory HealthEventModel.fromRemoteJson(
    Map<String, dynamic> json,
  ) => HealthEventModel(
    id: json['id']! as String,
    babyId: json['baby_id']! as String,
    type: _enumByName(HealthEventType.values, json['event_type']! as String),
    title: json['title']! as String,
    description: (json['description'] as String?) ?? '',
    startsAt: _remoteDate(json, 'starts_at'),
    caregiverId: json['caregiver_id'] as String?,
    status: _enumByName(HealthEventStatus.values, json['status']! as String),
    createdAt: _remoteDate(json, 'created_at'),
    updatedAt: _remoteDate(json, 'updated_at'),
    syncStatus: HealthSyncStatus.synced,
  );

  factory HealthEventModel.fromRow(Map<String, Object?> row) {
    final caregiverName = row['caregiver_name'] as String?;
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
