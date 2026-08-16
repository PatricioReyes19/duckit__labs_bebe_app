enum RegisterEventType {
  feeding,
  sleep,
  diaper,
  clinicalObservation,
  medication,
  measurement,
}

extension RegisterEventTypeLifecycle on RegisterEventType {
  /// Whether records of this type can remain open after being created.
  ///
  /// Feeding stores a duration, but its form always records a completed fact;
  /// only sleep currently exposes an explicit ongoing/completed lifecycle.
  bool get supportsActiveLifecycle => this == RegisterEventType.sleep;
}

enum RegisterSyncStatus { pending, syncing, synced, failed }

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
    DateTime? updatedAt,
    this.notes,
    this.caregiverId,
    this.deletedAt,
    this.syncStatus = RegisterSyncStatus.pending,
    this.syncError,
    this.schemaVersion = 1,
  }) : updatedAt = updatedAt ?? createdAt,
       details = Map.unmodifiable(details);

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

  bool get isDeleted => deletedAt != null;

  /// Start of the temporal record in the existing persistence model.
  DateTime get startedAt => occurredAt;

  /// End of the temporal record, when the event type supports one.
  DateTime? get endedAt {
    final value = details['end_at'];
    return switch (value) {
      final DateTime date => date,
      final String date when date.isNotEmpty => DateTime.tryParse(date),
      _ => null,
    };
  }

  /// Canonical active-state rule shared by domain and presentation.
  ///
  /// `sleep_status` is retained because it is the existing persisted state;
  /// `end_at == null` prevents a malformed completed row from appearing active.
  bool get isActive =>
      !isDeleted &&
      type.supportsActiveLifecycle &&
      details['sleep_status'] == 'ongoing' &&
      endedAt == null;

  bool get isFinished =>
      type.supportsActiveLifecycle && !isDeleted && !isActive;
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
