import 'dart:convert';

import '../../domain/entities/register/register.dart';

class RegisterEventModel {
  const RegisterEventModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
    required this.schemaVersion,
    this.notes,
    this.caregiverId,
    this.deletedAt,
    this.syncStatus = RegisterSyncStatus.pending,
    this.syncError,
  });

  final String id;
  final String babyId;
  final RegisterEventType type;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, Object?> details;
  final String? notes;
  final String? caregiverId;
  final DateTime? deletedAt;
  final RegisterSyncStatus syncStatus;
  final String? syncError;
  final int schemaVersion;

  factory RegisterEventModel.fromEntity(RegisteredEvent entity) =>
      RegisterEventModel(
        id: entity.id,
        babyId: entity.babyId,
        type: entity.type,
        occurredAt: entity.occurredAt,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        details: entity.details,
        notes: entity.notes,
        caregiverId: entity.caregiverId,
        deletedAt: entity.deletedAt,
        syncStatus: entity.syncStatus,
        syncError: entity.syncError,
        schemaVersion: entity.schemaVersion,
      );

  factory RegisterEventModel.fromRemoteJson(Map<String, dynamic> json) {
    final rawDetails = json['details'];
    return RegisterEventModel(
      id: json['id']! as String,
      babyId: json['baby_id']! as String,
      type: _typeFromStorage(json['event_type']! as String),
      occurredAt: _remoteDate(json, 'occurred_at'),
      createdAt: _remoteDate(json, 'created_at'),
      updatedAt: _remoteDate(json, 'updated_at'),
      deletedAt: _nullableRemoteDate(json['deleted_at']),
      caregiverId: json['caregiver_id'] as String?,
      notes: json['notes'] as String?,
      details: rawDetails is Map
          ? Map<String, Object?>.from(rawDetails)
          : const <String, Object?>{},
      syncStatus: RegisterSyncStatus.synced,
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
    );
  }

  factory RegisterEventModel.fromRow(Map<String, Object?> row) {
    final decoded = jsonDecode(row['details_json']! as String);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid register event details.');
    }
    return RegisterEventModel(
      id: row['id']! as String,
      babyId: row['baby_id']! as String,
      type: _typeFromStorage(row['event_type']! as String),
      occurredAt: DateTime.fromMillisecondsSinceEpoch(
        row['occurred_at']! as int,
        isUtc: true,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at']! as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (row['updated_at'] as int?) ?? row['created_at']! as int,
        isUtc: true,
      ),
      caregiverId: row['caregiver_id'] as String?,
      notes: row['notes'] as String?,
      deletedAt: switch (row['deleted_at']) {
        final int value => DateTime.fromMillisecondsSinceEpoch(
          value,
          isUtc: true,
        ),
        _ => null,
      },
      syncStatus: _syncStatusFromStorage(
        (row['sync_status'] as String?) ?? 'pending',
      ),
      syncError: row['sync_error'] as String?,
      details: Map<String, Object?>.from(decoded),
      schemaVersion: row['schema_version']! as int,
    );
  }

  Map<String, Object?> toRow() => {
    'id': id,
    'baby_id': babyId,
    'event_type': _typeToStorage(type),
    'occurred_at': occurredAt.toUtc().millisecondsSinceEpoch,
    'created_at': createdAt.toUtc().millisecondsSinceEpoch,
    'updated_at': updatedAt.toUtc().millisecondsSinceEpoch,
    'deleted_at': deletedAt?.toUtc().millisecondsSinceEpoch,
    'sync_status': syncStatus.name,
    'sync_error': syncError,
    'caregiver_id': caregiverId,
    'notes': notes,
    'details_json': jsonEncode(details),
    'schema_version': schemaVersion,
  };

  Map<String, Object?> toRemoteJson() => {
    'id': id,
    'baby_id': babyId,
    'event_type': _typeToStorage(type),
    'occurred_at': occurredAt.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
    'caregiver_id': caregiverId,
    'notes': notes,
    'details': details,
    'schema_version': schemaVersion,
  };

  RegisteredEvent toEntity() => RegisteredEvent(
    id: id,
    babyId: babyId,
    type: type,
    occurredAt: occurredAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    caregiverId: caregiverId,
    deletedAt: deletedAt,
    syncStatus: syncStatus,
    syncError: syncError,
    notes: notes,
    details: details,
    schemaVersion: schemaVersion,
  );

  static String _typeToStorage(RegisterEventType type) => switch (type) {
    RegisterEventType.feeding => 'feeding',
    RegisterEventType.sleep => 'sleep',
    RegisterEventType.diaper => 'diaper',
    RegisterEventType.clinicalObservation => 'clinical_observation',
    RegisterEventType.medication => 'medication',
    RegisterEventType.measurement => 'measurement',
  };

  static RegisterEventType _typeFromStorage(String value) => switch (value) {
    'feeding' => RegisterEventType.feeding,
    'sleep' => RegisterEventType.sleep,
    'diaper' => RegisterEventType.diaper,
    'clinical_observation' => RegisterEventType.clinicalObservation,
    'medication' => RegisterEventType.medication,
    'measurement' => RegisterEventType.measurement,
    _ => throw FormatException('Unknown register event type: $value'),
  };

  static RegisterSyncStatus _syncStatusFromStorage(String value) =>
      RegisterSyncStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => RegisterSyncStatus.pending,
      );

  static DateTime _remoteDate(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Invalid or missing remote date: $key');
    }
    return DateTime.parse(value).toUtc();
  }

  static DateTime? _nullableRemoteDate(Object? value) => switch (value) {
    final String date when date.isNotEmpty => DateTime.parse(date).toUtc(),
    _ => null,
  };
}
