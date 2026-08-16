import '../../entities/register/register.dart';
import '../../repositories/register_event/register_event.dart';

typedef FinishRegisterClock = DateTime Function();

/// Finishes an existing active event without creating a second record.
class FinishActiveRegisterEvent {
  FinishActiveRegisterEvent(this._repository, {FinishRegisterClock? clock})
    : _clock = clock ?? DateTime.now;

  final RegisterEventRepository _repository;
  final FinishRegisterClock _clock;

  Future<RegisteredEvent?> call({
    required String eventId,
    required String babyId,
    DateTime? endedAt,
  }) async {
    final normalizedEventId = eventId.trim();
    final normalizedBabyId = babyId.trim();
    if (normalizedEventId.isEmpty) {
      throw ArgumentError.value(eventId, 'eventId', 'Cannot be empty.');
    }
    if (normalizedBabyId.isEmpty) {
      throw ArgumentError.value(babyId, 'babyId', 'Cannot be empty.');
    }

    final event = await _repository.findById(normalizedEventId);
    if (event == null || !event.isActive) return null;
    if (event.babyId != normalizedBabyId) {
      throw StateError('The active event belongs to another baby.');
    }

    final resolvedEnd = (endedAt ?? _clock()).toUtc();
    final start = event.startedAt.toUtc();
    if (!resolvedEnd.isAfter(start)) {
      throw ArgumentError.value(
        endedAt,
        'endedAt',
        'Must be after the event start.',
      );
    }

    final elapsedMinutes = resolvedEnd.difference(start).inMinutes;
    final durationMinutes = elapsedMinutes < 1 ? 1 : elapsedMinutes;
    final details = switch (event.type) {
      RegisterEventType.sleep => <String, Object?>{
        'sleep_status': 'completed',
        'duration_minutes': durationMinutes,
        'end_at': resolvedEnd.toIso8601String(),
      },
      _ => throw StateError(
        '${event.type.name} does not define a finish transition.',
      ),
    };

    return _repository.update(event.id, RegisterEventPatch(details: details));
  }
}
