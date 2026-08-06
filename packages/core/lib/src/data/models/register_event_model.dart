import 'dart:convert';

import '../../domain/entities/register/register.dart';

class RegisterEventModel {
  const RegisterEventModel({
    required this.id,
    required this.babyId,
    required this.type,
    required this.occurredAt,
    required this.createdAt,
    required this.details,
    required this.schemaVersion,
    this.notes,
    this.caregiverId,
  });

  final String id;
  final String babyId;
  final RegisterEventType type;
  final DateTime occurredAt;
  final DateTime createdAt;
  final Map<String, Object?> details;
  final String? notes;
  final String? caregiverId;
  final int schemaVersion;

  factory RegisterEventModel.fromEntity(RegisteredEvent entity) =>
      RegisterEventModel(
        id: entity.id,
        babyId: entity.babyId,
        type: entity.type,
        occurredAt: entity.occurredAt,
        createdAt: entity.createdAt,
        details: entity.details,
        notes: entity.notes,
        caregiverId: entity.caregiverId,
        schemaVersion: entity.schemaVersion,
      );

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
      caregiverId: row['caregiver_id'] as String?,
      notes: row['notes'] as String?,
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
    'caregiver_id': caregiverId,
    'notes': notes,
    'details_json': jsonEncode(details),
    'schema_version': schemaVersion,
  };

  RegisteredEvent toEntity() => RegisteredEvent(
    id: id,
    babyId: babyId,
    type: type,
    occurredAt: occurredAt,
    createdAt: createdAt,
    caregiverId: caregiverId,
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
}
