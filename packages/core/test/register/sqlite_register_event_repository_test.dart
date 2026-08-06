import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late SqliteRegisterEventRepository repository;
  var sequence = 0;
  final createdAt = DateTime.utc(2026, 8, 5, 12);

  setUp(() {
    sequence = 0;
    repository = SqliteRegisterEventRepository(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
      idGenerator: () => 'event-${++sequence}',
      clock: () => createdAt,
    );
  });

  tearDown(() => repository.close());

  test('persists and restores a versioned event with JSON details', () async {
    final saved = await repository.save(
      RegisterEventDraft(
        babyId: 'baby-1',
        type: RegisterEventType.feeding,
        occurredAt: DateTime.utc(2026, 8, 5, 9, 30),
        caregiverId: 'mother',
        notes: '  Sin molestias  ',
        details: {
          'subtype': 'bottle',
          'duration_minutes': 20,
          'amount_ml': 90.5,
          'symptoms': <String>[],
        },
      ),
    );

    final restored = await repository.findById(saved.id);

    expect(restored, isNotNull);
    expect(restored!.id, 'event-1');
    expect(restored.babyId, 'baby-1');
    expect(restored.type, RegisterEventType.feeding);
    expect(restored.occurredAt, DateTime.utc(2026, 8, 5, 9, 30));
    expect(restored.createdAt, createdAt);
    expect(restored.caregiverId, 'mother');
    expect(restored.notes, 'Sin molestias');
    expect(restored.details['duration_minutes'], 20);
    expect(restored.details['amount_ml'], 90.5);
  });

  test('lists by baby and type in reverse chronological order', () async {
    await repository.save(
      RegisterEventDraft(
        babyId: 'baby-1',
        type: RegisterEventType.sleep,
        occurredAt: DateTime.utc(2026, 8, 5, 8),
        details: const {'duration_minutes': 60},
      ),
    );
    await repository.save(
      RegisterEventDraft(
        babyId: 'baby-1',
        type: RegisterEventType.measurement,
        occurredAt: DateTime.utc(2026, 8, 5, 10),
        details: const {'value': 5.8, 'unit': 'kg'},
      ),
    );
    await repository.save(
      RegisterEventDraft(
        babyId: 'baby-2',
        type: RegisterEventType.measurement,
        occurredAt: DateTime.utc(2026, 8, 5, 11),
        details: const {'value': 6.2, 'unit': 'kg'},
      ),
    );

    final allForBaby = await repository.listByBaby('baby-1');
    final measurements = await repository.listByBaby(
      'baby-1',
      type: RegisterEventType.measurement,
      limit: 1,
    );

    expect(allForBaby.map((event) => event.id), ['event-2', 'event-1']);
    expect(measurements, hasLength(1));
    expect(measurements.single.type, RegisterEventType.measurement);
  });

  test('deletes only the requested event', () async {
    final saved = await repository.save(
      RegisterEventDraft(
        babyId: 'baby-1',
        type: RegisterEventType.diaper,
        occurredAt: createdAt,
        details: const {'subtype': 'wet'},
      ),
    );

    await repository.delete(saved.id);

    expect(await repository.findById(saved.id), isNull);
  });
}
