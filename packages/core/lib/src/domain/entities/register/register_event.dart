enum RegisterEventType {
  feeding,
  sleep,
  diaper,
  clinicalObservation,
  medication,
  measurement,
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

/// Partial changes accepted by the register domain.
///
/// The explicit clear flags preserve PATCH semantics: an omitted nullable
/// value is different from intentionally setting that value to `null`.
class RegisterEventPatch {
  RegisterEventPatch({
    this.occurredAt,
    this.details,
    this.notes,
    this.clearNotes = false,
    this.caregiverId,
    this.clearCaregiverId = false,
    this.schemaVersion,
  }) : assert(notes == null || !clearNotes),
       assert(caregiverId == null || !clearCaregiverId);

  final DateTime? occurredAt;
  final Map<String, Object?>? details;
  final String? notes;
  final bool clearNotes;
  final String? caregiverId;
  final bool clearCaregiverId;
  final int? schemaVersion;

  bool get isEmpty =>
      occurredAt == null &&
      details == null &&
      notes == null &&
      !clearNotes &&
      caregiverId == null &&
      !clearCaregiverId &&
      schemaVersion == null;
}
