import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final startedAt = DateTime.utc(2026, 8, 15, 0);
  final endedAt = DateTime.utc(2026, 8, 16, 12);

  test('UT-REG-ACT-001 ACTIVE when the ongoing sleep has no end', () {
    final event = _sleep(id: 'active', babyId: 'baby-a', startedAt: startedAt);

    expect(event.startedAt, startedAt);
    expect(event.endedAt, isNull);
    expect(event.isActive, isTrue);
    expect(event.isFinished, isFalse);
  });

  test('UT-REG-ACT-002 FINISHED when endedAt exists', () {
    final event = _sleep(
      id: 'finished',
      babyId: 'baby-a',
      startedAt: startedAt,
      endedAt: endedAt,
    );

    expect(event.endedAt, endedAt);
    expect(event.isActive, isFalse);
    expect(event.isFinished, isTrue);
  });

  test(
    'UT-REG-ACT-003/004 finish preserves start and writes the end',
    () async {
      final repository = _MemoryRegisterRepository([
        _sleep(id: 'active', babyId: 'baby-a', startedAt: startedAt),
      ]);
      final finish = FinishActiveRegisterEvent(repository);

      final result = await finish(
        eventId: 'active',
        babyId: 'baby-a',
        endedAt: endedAt,
      );

      expect(result, isNotNull);
      expect(result!.id, 'active');
      expect(result.startedAt, startedAt);
      expect(result.endedAt, endedAt);
      expect(result.details['duration_minutes'], 2160);
      expect(result.details['sleep_status'], 'completed');
      expect(repository.events, hasLength(1));
    },
  );

  test('UT-REG-ACT-005 deleted event is not returned as active', () async {
    final repository = _MemoryRegisterRepository([
      _sleep(
        id: 'deleted',
        babyId: 'baby-a',
        startedAt: startedAt,
        deletedAt: endedAt,
      ),
    ]);

    final active = await GetActiveRegisterEvents(repository)('baby-a');

    expect(active, isEmpty);
  });

  test('UT-REG-ACT-006 baby A does not receive baby B active events', () async {
    final repository = _MemoryRegisterRepository([
      _sleep(id: 'a', babyId: 'baby-a', startedAt: startedAt),
      _sleep(id: 'b', babyId: 'baby-b', startedAt: startedAt),
    ]);

    final active = await GetActiveRegisterEvents(repository)('baby-a');

    expect(active.map((event) => event.id), ['a']);
  });

  test('finish rejects an event from another baby context', () async {
    final repository = _MemoryRegisterRepository([
      _sleep(id: 'active', babyId: 'baby-b', startedAt: startedAt),
    ]);

    expect(
      () => FinishActiveRegisterEvent(repository)(
        eventId: 'active',
        babyId: 'baby-a',
        endedAt: endedAt,
      ),
      throwsStateError,
    );
  });

  test('feeding duration does not imply an active lifecycle', () {
    final event = RegisteredEvent(
      id: 'feeding',
      babyId: 'baby-a',
      type: RegisterEventType.feeding,
      occurredAt: startedAt,
      createdAt: startedAt,
      details: const {'duration_minutes': 20, 'end_at': null},
    );

    expect(event.type.supportsActiveLifecycle, isFalse);
    expect(event.isActive, isFalse);
  });
}

RegisteredEvent _sleep({
  required String id,
  required String babyId,
  required DateTime startedAt,
  DateTime? endedAt,
  DateTime? deletedAt,
}) => RegisteredEvent(
  id: id,
  babyId: babyId,
  type: RegisterEventType.sleep,
  occurredAt: startedAt,
  createdAt: startedAt,
  deletedAt: deletedAt,
  details: {
    'sleep_status': endedAt == null ? 'ongoing' : 'completed',
    'duration_minutes': endedAt?.difference(startedAt).inMinutes,
    'end_at': endedAt?.toIso8601String(),
  },
);

class _MemoryRegisterRepository implements RegisterEventRepository {
  _MemoryRegisterRepository(Iterable<RegisteredEvent> seed)
    : events = seed.toList();

  final List<RegisteredEvent> events;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<void> delete(String id) async {}

  @override
  Future<RegisteredEvent?> findById(String id) async =>
      events.where((event) => event.id == id && !event.isDeleted).firstOrNull;

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async {
    final matching = events
        .where((event) => event.babyId == babyId && !event.isDeleted)
        .where((event) => type == null || event.type == type)
        .toList(growable: false);
    return limit == null ? matching : matching.take(limit).toList();
  }

  @override
  Stream<List<RegisteredEvent>> observeByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async* {
    yield await listByBaby(babyId, type: type, limit: limit);
  }

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<RegisteredEvent?> update(String id, RegisterEventPatch patch) async {
    final index = events.indexWhere((event) => event.id == id);
    if (index < 0) return null;
    final current = events[index];
    final updated = RegisteredEvent(
      id: current.id,
      babyId: current.babyId,
      type: current.type,
      occurredAt: patch.occurredAt ?? current.occurredAt,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt.add(const Duration(milliseconds: 1)),
      details: {...current.details, ...?patch.details},
      notes: current.notes,
      caregiverId: current.caregiverId,
      syncStatus: RegisterSyncStatus.pending,
      schemaVersion: current.schemaVersion,
    );
    events[index] = updated;
    return updated;
  }
}
