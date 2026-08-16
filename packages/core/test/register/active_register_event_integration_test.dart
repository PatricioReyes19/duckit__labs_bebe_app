import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/baby_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'IT-SLEEP-001/002 active sleep survives restart and finishes in place',
    () async {
      final temporary = await Directory.systemTemp.createTemp('bebe-sleep-');
      final databasePath = '${temporary.path}${Platform.pathSeparator}bebe.db';
      final startedAt = DateTime.utc(2026, 8, 15);
      final endedAt = DateTime.utc(2026, 8, 16, 12);

      final firstDatabase = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      await insertBabyFixture(firstDatabase);
      final firstRepository = SqliteRegisterEventRepository(
        database: firstDatabase,
        idGenerator: () => 'sleep-1',
        clock: () => startedAt,
      );
      await firstRepository.save(_activeSleep(startedAt));
      await firstRepository.close();
      await firstDatabase.close();

      final restartedDatabase = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      final restartedRepository = SqliteRegisterEventRepository(
        database: restartedDatabase,
        clock: () => endedAt,
      );
      final active = await GetActiveRegisterEvents(restartedRepository)(
        'baby-1',
      );

      expect(active.map((event) => event.id), ['sleep-1']);
      final finished = await FinishActiveRegisterEvent(restartedRepository)(
        eventId: 'sleep-1',
        babyId: 'baby-1',
        endedAt: endedAt,
      );
      expect(finished?.isFinished, isTrue);
      expect(finished?.startedAt, startedAt);
      expect(finished?.details['duration_minutes'], 2160);
      expect(await restartedRepository.listByBaby('baby-1'), hasLength(1));

      await restartedRepository.close();
      await restartedDatabase.close();

      final verificationDatabase = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      final verificationRepository = SqliteRegisterEventRepository(
        database: verificationDatabase,
      );
      final restored = await verificationRepository.findById('sleep-1');
      expect(restored?.isFinished, isTrue);
      expect(restored?.endedAt, endedAt);
      expect(
        await GetActiveRegisterEvents(verificationRepository)('baby-1'),
        isEmpty,
      );

      await verificationRepository.close();
      await verificationDatabase.close();
      await temporary.delete(recursive: true);
    },
  );

  test(
    'IT-SLEEP-003 offline start and finish sync as one completed row',
    () async {
      final now = DateTime.utc(2026, 8, 16, 12);
      final database = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      await insertBabyFixture(database);
      final local = SqliteRegisterEventRepository(
        database: database,
        idGenerator: () => 'sleep-offline',
        clock: () => now,
      );
      final remote = _SharedRemote()..online = false;
      final sync = RegisterEventSyncService(local, remote);
      final repository = OfflineFirstRegisterEventRepository(local, sync);

      await repository.save(
        _activeSleep(now.subtract(const Duration(hours: 2))),
      );
      final finished = await FinishActiveRegisterEvent(repository)(
        eventId: 'sleep-offline',
        babyId: 'baby-1',
        endedAt: now,
      );

      expect(finished?.syncStatus, RegisterSyncStatus.pending);
      expect(await local.listByBaby('baby-1'), hasLength(1));
      remote.online = true;
      final result = await sync.synchronize();

      expect(result.phase, RegisterSyncPhase.synced);
      expect(remote.rows, hasLength(1));
      expect(remote.rows['sleep-offline']?.isFinished, isTrue);
      expect(
        (await local.findById('sleep-offline'))?.syncStatus,
        RegisterSyncStatus.synced,
      );

      await sync.close();
      await local.close();
      await database.close();
    },
  );

  test(
    'IT-SLEEP-004/005/006 caregivers converge without duplicate rows',
    () async {
      var clockA = DateTime.utc(2026, 8, 16, 8);
      var clockB = DateTime.utc(2026, 8, 16, 10);
      final remote = _SharedRemote();
      final temporary = await Directory.systemTemp.createTemp(
        'bebe-caregivers-',
      );
      final databaseA = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: '${temporary.path}${Platform.pathSeparator}a.db',
      );
      final databaseB = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: '${temporary.path}${Platform.pathSeparator}b.db',
      );
      await insertBabyFixture(databaseA);
      await insertBabyFixture(databaseB);
      final localA = SqliteRegisterEventRepository(
        database: databaseA,
        idGenerator: () => 'shared-sleep',
        clock: () => clockA,
      );
      final localB = SqliteRegisterEventRepository(
        database: databaseB,
        clock: () => clockB,
      );
      final syncA = RegisterEventSyncService(localA, remote);
      final syncB = RegisterEventSyncService(localB, remote);
      final repositoryA = OfflineFirstRegisterEventRepository(localA, syncA);
      final repositoryB = OfflineFirstRegisterEventRepository(localB, syncB);

      await repositoryA.save(_activeSleep(clockA));
      await syncA.synchronize();
      await syncB.synchronize();
      expect(
        await GetActiveRegisterEvents(repositoryB)('baby-1'),
        hasLength(1),
      );

      await FinishActiveRegisterEvent(repositoryB)(
        eventId: 'shared-sleep',
        babyId: 'baby-1',
        endedAt: clockB,
      );
      await syncB.synchronize();
      clockA = clockB.add(const Duration(minutes: 1));
      await syncA.synchronize();

      expect((await localA.findById('shared-sleep'))?.isFinished, isTrue);
      expect((await localB.findById('shared-sleep'))?.isFinished, isTrue);
      expect(await localA.listByBaby('baby-1'), hasLength(1));
      expect(await localB.listByBaby('baby-1'), hasLength(1));
      expect(remote.rows, hasLength(1));

      await syncA.close();
      await syncB.close();
      await localA.close();
      await localB.close();
      await databaseA.close();
      await databaseB.close();
      await temporary.delete(recursive: true);
    },
  );
}

RegisterEventDraft _activeSleep(DateTime startedAt) => RegisterEventDraft(
  babyId: 'baby-1',
  type: RegisterEventType.sleep,
  occurredAt: startedAt,
  details: const {
    'sleep_status': 'ongoing',
    'duration_minutes': null,
    'end_at': null,
  },
);

class _SharedRemote implements RegisterEventRemoteDataSource {
  final Map<String, RegisteredEvent> rows = <String, RegisteredEvent>{};
  bool online = true;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<List<RegisteredEvent>> pull({DateTime? updatedAfter}) async {
    if (!online) throw StateError('offline');
    return rows.values
        .where(
          (event) =>
              updatedAfter == null || !event.updatedAt.isBefore(updatedAfter),
        )
        .toList(growable: false);
  }

  @override
  Future<RegisteredEvent> push(RegisteredEvent event) async {
    if (!online) throw StateError('offline');
    final existing = rows[event.id];
    if (existing != null && existing.updatedAt.isAfter(event.updatedAt)) {
      return existing;
    }
    final synced = RegisteredEvent(
      id: event.id,
      babyId: event.babyId,
      type: event.type,
      occurredAt: event.occurredAt,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      details: event.details,
      notes: event.notes,
      caregiverId: event.caregiverId,
      deletedAt: event.deletedAt,
      syncStatus: RegisterSyncStatus.synced,
      schemaVersion: event.schemaVersion,
    );
    rows[event.id] = synced;
    return synced;
  }
}
