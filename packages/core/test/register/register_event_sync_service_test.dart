import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/baby_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late SqliteRegisterEventRepository local;
  late BebeDatabase database;
  late _MemoryRemote remote;
  late RegisterEventSyncService syncService;
  late RegisterSyncState parentState;
  var sequence = 0;
  var now = DateTime.utc(2026, 8, 10, 12);

  setUp(() async {
    database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    await insertBabyFixture(database);
    local = SqliteRegisterEventRepository(
      database: database,
      idGenerator: () => 'event-${++sequence}',
      clock: () => now,
    );
    remote = _MemoryRemote();
    parentState = RegisterSyncState(
      phase: RegisterSyncPhase.synced,
      lastSyncedAt: now,
    );
    syncService = RegisterEventSyncService(
      local,
      remote,
      parentSyncBarrier: () async => parentState,
      clock: () => now,
    );
  });

  tearDown(() async {
    await syncService.close();
    await local.close();
    await database.close();
  });

  test('uploads a pending event and marks the local row as synced', () async {
    final saved = await local.save(_feedingDraft(now));

    final result = await syncService.synchronize();

    expect(result.phase, RegisterSyncPhase.synced);
    expect(remote.rows.keys, contains(saved.id));
    expect(
      (await local.findById(saved.id))?.syncStatus,
      RegisterSyncStatus.synced,
    );
  });

  test('pulls remote events into the observable local history', () async {
    final remoteEvent = RegisteredEvent(
      id: 'remote-1',
      babyId: 'baby-1',
      type: RegisterEventType.measurement,
      occurredAt: now,
      createdAt: now,
      updatedAt: now,
      details: const {'measurement_type': 'weight', 'value': 5.9, 'unit': 'kg'},
      syncStatus: RegisterSyncStatus.synced,
    );
    remote.rows[remoteEvent.id] = remoteEvent;

    await syncService.synchronize();

    final history = await local.listByBaby('baby-1');
    expect(history.single.id, remoteEvent.id);
    expect(history.single.syncStatus, RegisterSyncStatus.synced);
  });

  test('keeps failures retryable without losing the local event', () async {
    final saved = await local.save(_feedingDraft(now));
    remote.failPushes = true;

    final failed = await syncService.synchronize();

    expect(failed.phase, RegisterSyncPhase.failed);
    expect(
      (await local.findById(saved.id))?.syncStatus,
      RegisterSyncStatus.failed,
    );

    remote.failPushes = false;
    now = now.add(const Duration(minutes: 1));
    final retried = await syncService.synchronize();

    expect(retried.phase, RegisterSyncPhase.synced);
    expect(remote.rows.keys, contains(saved.id));
  });

  test('waits for the Baby profile before uploading child rows', () async {
    final saved = await local.save(_feedingDraft(now));
    parentState = const RegisterSyncState(
      phase: RegisterSyncPhase.failed,
      message: 'Family unavailable',
    );

    final blocked = await syncService.synchronize();

    expect(blocked.phase, RegisterSyncPhase.failed);
    expect(blocked.message, contains('perfil del bebé'));
    expect(remote.rows, isEmpty);
    expect(
      (await local.findById(saved.id))?.syncStatus,
      RegisterSyncStatus.pending,
    );

    parentState = RegisterSyncState(
      phase: RegisterSyncPhase.synced,
      lastSyncedAt: now,
    );
    final retried = await syncService.synchronize();

    expect(retried.phase, RegisterSyncPhase.synced);
    expect(remote.rows.keys, contains(saved.id));
  });

  test('propagates a deletion tombstone and hides it from history', () async {
    final saved = await local.save(_feedingDraft(now));
    await syncService.synchronize();
    now = now.add(const Duration(minutes: 1));
    await local.delete(saved.id);

    await syncService.synchronize();

    expect(await local.findById(saved.id), isNull);
    expect(remote.rows[saved.id]?.isDeleted, isTrue);
    expect(await local.listByBaby('baby-1'), isEmpty);
  });
}

RegisterEventDraft _feedingDraft(DateTime now) => RegisterEventDraft(
  babyId: 'baby-1',
  type: RegisterEventType.feeding,
  occurredAt: now,
  details: const {'subtype': 'bottle', 'amount_ml': 90},
);

class _MemoryRemote implements RegisterEventRemoteDataSource {
  final rows = <String, RegisteredEvent>{};
  bool failPushes = false;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<List<RegisteredEvent>> pull({DateTime? updatedAfter}) async => rows
      .values
      .where(
        (event) =>
            updatedAfter == null || event.updatedAt.isAfter(updatedAfter),
      )
      .toList(growable: false);

  @override
  Future<RegisteredEvent> push(RegisteredEvent event) async {
    if (failPushes) throw StateError('offline');
    final remote = RegisteredEvent(
      id: event.id,
      babyId: event.babyId,
      type: event.type,
      occurredAt: event.occurredAt,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      deletedAt: event.deletedAt,
      caregiverId: event.caregiverId,
      notes: event.notes,
      details: event.details,
      schemaVersion: event.schemaVersion,
      syncStatus: RegisterSyncStatus.synced,
    );
    rows[event.id] = remote;
    return remote;
  }
}
