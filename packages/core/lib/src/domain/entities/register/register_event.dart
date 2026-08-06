enum RegisterEventType {
  feeding,
  sleep,
  diaper,
  clinicalObservation,
  medication,
  measurement;

  String get storageKey => switch (this) {
    RegisterEventType.feeding => 'feeding',
    RegisterEventType.sleep => 'sleep',
    RegisterEventType.diaper => 'diaper',
    RegisterEventType.clinicalObservation => 'clinical_observation',
    RegisterEventType.medication => 'medication',
    RegisterEventType.measurement => 'measurement',
  };

  static RegisterEventType fromStorageKey(String value) {
    return RegisterEventType.values.firstWhere(
      (type) => type.storageKey == value,
      orElse: () =>
          throw FormatException('Unknown register event type: $value'),
    );
  }
}

/// Input accepted by the register domain.
///
/// Feature Cubits own validation and convert their typed state to this draft.
/// The details map is persisted as versioned JSON so new form fields do not
/// require duplicating a SQLite table per event type.
class RegisterEventDraft {
  RegisterEventDraft({
    required this.babyId,
    required this.type,
    required this.occurredAt,
    required Map<String, Object?> details,
    this.notes,
    this.caregiverId,
    this.schemaVersion = 1,
  }) : details = Map.unmodifiable(details);

  final String babyId;
  final RegisterEventType type;
  final DateTime occurredAt;
  final Map<String, Object?> details;
  final String? notes;
  final String? caregiverId;
  final int schemaVersion;
}

class RegisteredEvent {
  RegisteredEvent({
    required this.id,
    required this.babyId,
    required this.type,
    required this.occurredAt,
    required this.createdAt,
    required Map<String, Object?> details,
    this.notes,
    this.caregiverId,
    this.schemaVersion = 1,
  }) : details = Map.unmodifiable(details);

  final String id;
  final String babyId;
  final RegisterEventType type;
  final DateTime occurredAt;
  final DateTime createdAt;
  final Map<String, Object?> details;
  final String? notes;
  final String? caregiverId;
  final int schemaVersion;
}
