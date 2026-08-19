import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/baby_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final now = DateTime.utc(2026, 8, 16, 12);

  test('Agenda drains more than one local pending batch', () async {
    final database = _database();
    await insertBabyFixture(database);
    var sequence = 0;
    final local = SqliteAgendaRepository(
      database,
      idGenerator: () => 'agenda-${++sequence}',
      clock: () => now,
    );
    final remote = _AgendaRemote();
    final sync = AgendaEventSyncService(local, remote, clock: () => now);
    addTearDown(sync.close);
    addTearDown(database.close);

    for (var index = 0; index < 101; index += 1) {
      await local.create(
        AgendaEventDraft(
          babyId: 'baby-1',
          category: AgendaCategory.controls,
          title: 'Control $index',
          description: 'Pendiente de sincronizar',
          startsAt: now.add(Duration(days: index)),
        ),
      );
    }

    final result = await sync.synchronize();

    expect(result.phase, RegisterSyncPhase.synced);
    expect(remote.rows, hasLength(101));
    expect(await local.countPending(), 0);
  });

  test('Health drains more than one local pending batch', () async {
    final database = _database();
    await insertBabyFixture(database);
    var sequence = 0;
    final local = SqliteHealthRepository(
      database,
      idGenerator: () => 'health-${++sequence}',
      clock: () => now,
    );
    final remote = _HealthRemote();
    final sync = HealthEventSyncService(local, remote, clock: () => now);
    addTearDown(sync.close);
    addTearDown(local.close);
    addTearDown(database.close);

    for (var index = 0; index < 101; index += 1) {
      await local.createEvent(
        HealthEventDraft(
          babyId: 'baby-1',
          type: HealthEventType.pediatricControl,
          title: 'Control $index',
          description: 'Pendiente de sincronizar',
          startsAt: now.add(Duration(days: index)),
          appointmentKind: HealthAppointmentKind.wellChildControl,
          reason: 'Seguimiento $index',
          caregiverIds: const ['caregiver-1'],
        ),
      );
    }

    final result = await sync.synchronize();

    expect(result.phase, RegisterSyncPhase.synced);
    expect(remote.rows, hasLength(101));
    expect(
      remote.rows['health-1']?.appointmentKind,
      HealthAppointmentKind.wellChildControl,
    );
    expect(remote.rows['health-1']?.reason, 'Seguimiento 0');
    expect(remote.rows['health-1']?.caregiverIds, ['caregiver-1']);
    expect(await local.countPending(), 0);
  });

  test(
    'every domain exposes its local pending count without a session',
    () async {
      final database = _database();
      await insertBabyFixture(database);
      final registers = SqliteRegisterEventRepository(
        database: database,
        idGenerator: () => 'register-1',
        clock: () => now,
      );
      final agenda = SqliteAgendaRepository(
        database,
        idGenerator: () => 'agenda-1',
        clock: () => now,
      );
      final health = SqliteHealthRepository(
        database,
        idGenerator: () => 'health-1',
        clock: () => now,
      );
      final family = SqliteFamilyRepository(database, clock: () => now);
      await registers.save(
        RegisterEventDraft(
          babyId: 'baby-1',
          type: RegisterEventType.feeding,
          occurredAt: now,
          details: const {'subtype': 'bottle', 'amount_ml': 90},
        ),
      );
      await agenda.create(
        AgendaEventDraft(
          babyId: 'baby-1',
          category: AgendaCategory.controls,
          title: 'Control',
          description: 'Pendiente',
          startsAt: now,
        ),
      );
      await health.createEvent(
        HealthEventDraft(
          babyId: 'baby-1',
          type: HealthEventType.pediatricControl,
          title: 'Control',
          description: 'Pendiente',
          startsAt: now,
        ),
      );
      final registerSync = RegisterEventSyncService(
        registers,
        _RegisterRemote(authenticated: false),
      );
      final agendaSync = AgendaEventSyncService(
        agenda,
        _AgendaRemote(authenticated: false),
      );
      final healthSync = HealthEventSyncService(
        health,
        _HealthRemote(authenticated: false),
      );
      final familySync = FamilySyncService(
        family,
        _FamilyRemote(authenticated: false),
      );
      addTearDown(registerSync.close);
      addTearDown(agendaSync.close);
      addTearDown(healthSync.close);
      addTearDown(familySync.close);
      addTearDown(registers.close);
      addTearDown(health.close);
      addTearDown(database.close);

      final states = await Future.wait([
        familySync.synchronize(),
        registerSync.synchronize(),
        agendaSync.synchronize(),
        healthSync.synchronize(),
      ]);

      expect(
        states.map((state) => state.phase),
        everyElement(RegisterSyncPhase.waitingForAuthentication),
      );
      expect(states.map((state) => state.pendingCount), everyElement(1));
    },
  );

  test('Preferences preserve and expose a pending local mutation', () async {
    final database = _database(seedDemoData: true);
    final local = SqliteAppSettingsRepository(database, clock: () => now);
    await local.update(const AppSettingsPatch(reduceMotion: true));
    final sync = AppSettingsSyncService(
      local,
      _SettingsRemote(authenticated: false),
    );
    addTearDown(sync.close);
    addTearDown(local.close);
    addTearDown(database.close);

    final result = await sync.synchronize();

    expect(result.phase, RegisterSyncPhase.waitingForAuthentication);
    expect(result.pendingCount, 1);
  });

  test(
    'Family mutations return locally while their upload is pending',
    () async {
      final database = _database();
      await insertBabyFixture(database);
      final local = SqliteFamilyRepository(database, clock: () => now);
      final remote = _BlockingFamilyRemote();
      final sync = FamilySyncService(local, remote, clock: () => now);
      final repository = OfflineFirstFamilyRepository(local, sync);
      addTearDown(() {
        if (!remote.releasePush.isCompleted) remote.releasePush.complete();
      });
      addTearDown(sync.close);
      addTearDown(database.close);

      final updated = await repository
          .updateBaby('baby-1', const BabyPatch(name: 'Emma'))
          .timeout(const Duration(seconds: 1));

      expect(updated?.name, 'Emma');
      await remote.pushStarted.future.timeout(const Duration(seconds: 1));
      expect(sync.state.phase, RegisterSyncPhase.syncing);
      expect(sync.state.pendingCount, 1);

      remote.releasePush.complete();
      final synchronized = await sync.synchronize();

      expect(synchronized.phase, RegisterSyncPhase.synced);
      expect(await local.readPendingSnapshot(), isNull);
    },
  );

  test(
    'a Preferences pull failure does not turn synced data pending',
    () async {
      final database = _database(seedDemoData: true);
      final local = SqliteAppSettingsRepository(database, clock: () => now);
      final record = (await local.readSyncRecord())!;
      await local.markSynced(record);
      final remote = _SettingsRemote()..failPull = true;
      final sync = AppSettingsSyncService(local, remote);
      addTearDown(sync.close);
      addTearDown(local.close);
      addTearDown(database.close);

      final result = await sync.synchronize();

      expect(result.phase, RegisterSyncPhase.failed);
      expect(result.pendingCount, 0);
      expect(
        (await local.readSyncRecord())?.syncStatus,
        AppSettingsSyncStatus.synced,
      );
    },
  );
}

BebeDatabase _database({bool seedDemoData = false}) => BebeDatabase(
  databaseFactory: databaseFactoryFfi,
  databasePath: inMemoryDatabasePath,
  seedDemoData: seedDemoData,
);

class _RegisterRemote implements RegisterEventRemoteDataSource {
  _RegisterRemote({this.authenticated = true});

  final bool authenticated;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => authenticated;

  @override
  Future<List<RegisteredEvent>> pull({DateTime? updatedAfter}) async => [];

  @override
  Future<RegisteredEvent> push(RegisteredEvent event) async => event;
}

class _AgendaRemote implements AgendaEventRemoteDataSource {
  _AgendaRemote({this.authenticated = true});

  final bool authenticated;
  final rows = <String, AgendaEventEntity>{};

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => authenticated;

  @override
  Future<List<AgendaEventEntity>> pull({DateTime? updatedAfter}) async => [];

  @override
  Future<AgendaEventEntity> push(AgendaEventEntity event) async {
    rows[event.id] = event;
    return event;
  }
}

class _HealthRemote implements HealthEventRemoteDataSource {
  _HealthRemote({this.authenticated = true});

  final bool authenticated;
  final rows = <String, HealthEventEntity>{};

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => authenticated;

  @override
  Future<List<HealthEventEntity>> pull({DateTime? updatedAfter}) async => [];

  @override
  Future<HealthEventEntity> push(HealthEventEntity event) async {
    rows[event.id] = event;
    return event;
  }
}

class _FamilyRemote implements FamilyRemoteDataSource {
  _FamilyRemote({this.authenticated = true});

  final bool authenticated;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => authenticated;

  @override
  Future<FamilySyncSnapshot> push(FamilySyncSnapshot snapshot) async =>
      snapshot;

  @override
  Future<List<FamilySyncSnapshot>> pull() async => [];

  @override
  Future<void> createInvitation(Map<String, Object?> parameters) async {}

  @override
  Future<void> resendInvitation({
    required String code,
    required String newCode,
  }) async {}

  @override
  Future<void> revokeInvitation(String code) async {}
}

class _BlockingFamilyRemote extends _FamilyRemote {
  final pushStarted = Completer<void>();
  final releasePush = Completer<void>();

  @override
  Future<FamilySyncSnapshot> push(FamilySyncSnapshot snapshot) async {
    if (!pushStarted.isCompleted) pushStarted.complete();
    await releasePush.future;
    return snapshot;
  }
}

class _SettingsRemote implements AppSettingsRemoteDataSource {
  _SettingsRemote({this.authenticated = true});

  final bool authenticated;
  bool failPull = false;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => authenticated;

  @override
  Future<AppSettingsSyncRecord?> pull() async {
    if (failPull) throw StateError('offline');
    return null;
  }

  @override
  Future<AppSettingsSyncRecord> push(AppSettingsSyncRecord record) async =>
      record;
}
