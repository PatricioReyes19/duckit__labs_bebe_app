import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final now = DateTime.utc(2026, 8, 12, 12);

  test(
    'IT-RESTORE-002: clean local storage restores remote history before home',
    () async {
      final trace = <String>[];
      final harness = await _SyncHarness.create(now: now, trace: trace);
      addTearDown(harness.close);

      final result = await harness.initial.synchronize(
        startRealtime: () async => trace.add('realtime'),
      );

      expect(result.phase, InitialDataSyncPhase.ready);
      expect(await harness.families.containsBaby('baby-1'), isTrue);
      expect(
        await harness.registers.listByTypeIncludingDeleted(
          RegisterEventType.medication,
        ),
        hasLength(1),
      );
      expect(
        await harness.agenda.listDerivedBySource('remote-medication'),
        hasLength(1),
      );
      expect((await harness.health.getOverview('baby-1')).events, hasLength(1));
      expect((await harness.settings.get()).name, 'Remote Owner');
      expect(
        trace,
        containsAllInOrder([
          'profile',
          'family',
          'register',
          'agenda',
          'health',
          'preferences',
          'agenda-push',
          'realtime',
        ]),
      );
      expect(trace.last, 'realtime');
    },
  );

  test('context barrier stops child sync until context is valid', () async {
    final trace = <String>[];
    final harness = await _SyncHarness.create(now: now, trace: trace);
    addTearDown(harness.close);

    final result = await harness.initial.synchronize(
      beforeDomainSync: () async {
        trace.add('context');
        return false;
      },
      startRealtime: () async => trace.add('realtime'),
    );

    expect(result.phase, InitialDataSyncPhase.ready);
    expect(trace, ['profile', 'family', 'context']);
    expect(result.registerState, isNull);
    expect(result.agendaState, isNull);
    expect(result.healthState, isNull);
    expect(result.preferencesState, isNull);
  });

  test('out-of-order child waits for Family and later converges', () async {
    final trace = <String>[];
    final familyRemote = _FamilyRemote(trace, failPull: true);
    final harness = await _SyncHarness.create(
      now: now,
      trace: trace,
      familyRemote: familyRemote,
    );
    addTearDown(harness.close);

    await harness.initial.synchronizeFromRealtime(RealtimeSyncTarget.register);

    expect(await harness.families.containsBaby('baby-1'), isFalse);
    expect(
      await harness.registers.listByTypeIncludingDeleted(
        RegisterEventType.medication,
      ),
      isEmpty,
    );
    expect(trace, ['family']);

    familyRemote.failPull = false;
    await harness.initial.synchronizeFromRealtime(RealtimeSyncTarget.family);

    expect(await harness.families.containsBaby('baby-1'), isTrue);
    expect(
      await harness.registers.listByTypeIncludingDeleted(
        RegisterEventType.medication,
      ),
      hasLength(1),
    );
    expect(
      await harness.agenda.listDerivedBySource('remote-medication'),
      hasLength(1),
    );
  });

  test('IT-SYNCUX-003 retry success returns the status to synced', () async {
    final trace = <String>[];
    final familyRemote = _FamilyRemote(trace, failPull: true);
    final harness = await _SyncHarness.create(
      now: now,
      trace: trace,
      familyRemote: familyRemote,
    );
    addTearDown(harness.close);

    await harness.initial.synchronize();
    expect(harness.initial.syncUxState.status, SyncUxStatus.error);

    familyRemote.failPull = false;
    final recovered = await harness.initial.retry();

    expect(recovered.status, SyncUxStatus.synced);
    expect(recovered.lastSuccessfulSyncAt, now);
  });

  test(
    'repairs an incomplete remote Baby from the complete local graph',
    () async {
      final database = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      final families = SqliteFamilyRepository(
        database,
        idGenerator: (prefix) => '$prefix-repair',
        clock: () => now,
      );
      final created = await families.createInitialFamily(
        InitialFamilyDraft(
          familyName: 'Familia de Emilia',
          babyName: 'Emilia',
          birthDate: DateTime.utc(2026, 2, 3),
          ownerName: 'Paula',
          ownerEmail: 'paula@example.com',
        ),
      );
      final initial = (await families.readPendingSnapshot())!;
      await families.markSnapshotSynced(attempted: initial, accepted: initial);
      final remote = _RepairableFamilyRemote();
      final sync = FamilySyncService(families, remote, clock: () => now);
      addTearDown(() async {
        await sync.close();
        await database.close();
      });

      final result = await sync.synchronize();

      expect(result.phase, RegisterSyncPhase.synced);
      expect(remote.pushCount, 1);
      expect(remote.snapshot?.overview.id, created.id);
      expect(remote.snapshot?.overview.activeBaby.name, 'Emilia');
      expect(await families.readPendingSnapshot(), isNull);
    },
  );
}

class _SyncHarness {
  _SyncHarness({
    required this.database,
    required this.families,
    required this.registers,
    required this.agenda,
    required this.health,
    required this.settings,
    required this.familySync,
    required this.registerSync,
    required this.agendaSync,
    required this.healthSync,
    required this.settingsSync,
    required this.projection,
    required this.initial,
  });

  final BebeDatabase database;
  final SqliteFamilyRepository families;
  final SqliteRegisterEventRepository registers;
  final SqliteAgendaRepository agenda;
  final SqliteHealthRepository health;
  final SqliteAppSettingsRepository settings;
  final FamilySyncService familySync;
  final RegisterEventSyncService registerSync;
  final AgendaEventSyncService agendaSync;
  final HealthEventSyncService healthSync;
  final AppSettingsSyncService settingsSync;
  final RegisterAgendaCoordinator projection;
  final InitialDataSyncCoordinator initial;

  static Future<_SyncHarness> create({
    required DateTime now,
    required List<String> trace,
    _FamilyRemote? familyRemote,
  }) async {
    final database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    final families = SqliteFamilyRepository(database);
    final registers = SqliteRegisterEventRepository(database: database);
    final agenda = SqliteAgendaRepository(database, clock: () => now);
    final health = SqliteHealthRepository(database, clock: () => now);
    final settings = SqliteAppSettingsRepository(database, clock: () => now);
    final familySync = FamilySyncService(
      families,
      familyRemote ?? _FamilyRemote(trace),
      clock: () => now,
    );
    final registerSync = RegisterEventSyncService(
      registers,
      _RegisterRemote(trace, now),
      clock: () => now,
    );
    final agendaSync = AgendaEventSyncService(
      agenda,
      _AgendaRemote(trace),
      clock: () => now,
    );
    final healthSync = HealthEventSyncService(
      health,
      _HealthRemote(trace),
      clock: () => now,
    );
    final settingsSync = AppSettingsSyncService(
      settings,
      _SettingsRemote(trace),
      clock: () => now,
    );
    final projection = RegisterAgendaCoordinator(
      registers,
      agenda,
      agendaSync,
      familyRepository: families,
      clock: () => now,
    );
    final initial = InitialDataSyncCoordinator(
      const _SessionRepository(),
      _ProfileRemote(trace),
      familySync,
      registerSync,
      agendaSync,
      healthSync,
      settingsSync,
      projection,
    );
    await database.database;
    return _SyncHarness(
      database: database,
      families: families,
      registers: registers,
      agenda: agenda,
      health: health,
      settings: settings,
      familySync: familySync,
      registerSync: registerSync,
      agendaSync: agendaSync,
      healthSync: healthSync,
      settingsSync: settingsSync,
      projection: projection,
      initial: initial,
    );
  }

  Future<void> close() async {
    await initial.close();
    await projection.close();
    await familySync.close();
    await registerSync.close();
    await agendaSync.close();
    await healthSync.close();
    await settingsSync.close();
    await registers.close();
    await health.close();
    await settings.close();
    await database.close();
  }
}

class _ProfileRemote implements ProfileRemoteDataSource {
  _ProfileRemote(this.trace);

  final List<String> trace;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<void> syncAuthenticatedUser(AuthUser user) async {
    trace.add('profile');
  }
}

class _SessionRepository implements SessionRepository {
  const _SessionRepository();

  static const session = AuthSession(
    user: AuthUser(
      id: 'user-1',
      email: 'owner@example.com',
      displayName: 'Owner',
      emailVerification: true,
    ),
  );

  @override
  Future<AuthSession?> currentSession() async => session;

  @override
  Future<String?> getIdToken({required bool forceRefresh}) async => 'token';

  @override
  Future<void> logout() async {}

  @override
  Future<AuthSession?> refreshToken() async => session;

  @override
  Stream<AuthSession?> sessionChanges() => const Stream.empty();
}

class _FamilyRemote implements FamilyRemoteDataSource {
  _FamilyRemote(this.trace, {this.failPull = false});

  final List<String> trace;
  bool failPull;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<List<FamilySyncSnapshot>> pull() async {
    trace.add('family');
    if (failPull) throw StateError('Family unavailable');
    return [
      FamilySyncSnapshot(
        overview: FamilyOverviewEntity(
          id: 'family-1',
          name: 'Familia',
          activeBabyId: 'baby-1',
          babies: [
            BabyEntity(
              id: 'baby-1',
              familyId: 'family-1',
              name: 'Emma',
              birthDate: DateTime.utc(2026, 1, 1),
            ),
          ],
          members: const [
            FamilyMemberEntity(
              id: 'member-user-1',
              familyId: 'family-1',
              name: 'Owner',
              role: 'Madre',
              accessDescription: 'Acceso completo',
              status: FamilyMemberStatus.active,
              contact: 'owner@example.com',
            ),
          ],
        ),
        updatedAt: DateTime.utc(2026, 8, 12, 10),
      ),
    ];
  }

  @override
  Future<FamilySyncSnapshot> push(FamilySyncSnapshot snapshot) async =>
      snapshot;

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

class _RepairableFamilyRemote implements FamilyRemoteDataSource {
  FamilySyncSnapshot? snapshot;
  var pushCount = 0;
  var incomplete = true;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<List<FamilySyncSnapshot>> pull() async {
    if (incomplete) {
      throw const FormatException('Supabase Baby missing birth_date');
    }
    return [snapshot!];
  }

  @override
  Future<FamilySyncSnapshot> push(FamilySyncSnapshot value) async {
    pushCount += 1;
    incomplete = false;
    snapshot = value;
    return value;
  }

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

class _RegisterRemote implements RegisterEventRemoteDataSource {
  _RegisterRemote(this.trace, this.now);

  final List<String> trace;
  final DateTime now;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<List<RegisteredEvent>> pull({DateTime? updatedAfter}) async {
    trace.add('register');
    return [
      RegisteredEvent(
        id: 'remote-medication',
        babyId: 'baby-1',
        type: RegisterEventType.medication,
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
        details: {
          'name': 'Vitamina D',
          'frequency': 'Cada 8 horas',
          'schedule_next_doses': true,
          'end_date': now.add(const Duration(hours: 8)).toIso8601String(),
        },
        syncStatus: RegisterSyncStatus.synced,
      ),
    ];
  }

  @override
  Future<RegisteredEvent> push(RegisteredEvent event) async => event;
}

class _AgendaRemote implements AgendaEventRemoteDataSource {
  _AgendaRemote(this.trace);

  final List<String> trace;
  final rows = <String, AgendaEventEntity>{};

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<List<AgendaEventEntity>> pull({DateTime? updatedAfter}) async {
    trace.add('agenda');
    return rows.values.toList(growable: false);
  }

  @override
  Future<AgendaEventEntity> push(AgendaEventEntity event) async {
    trace.add('agenda-push');
    final synced = AgendaEventEntity(
      id: event.id,
      babyId: event.babyId,
      category: event.category,
      title: event.title,
      description: event.description,
      startsAt: event.startsAt,
      caregiverId: event.caregiverId,
      sourceRegisterEventId: event.sourceRegisterEventId,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      deletedAt: event.deletedAt,
      syncStatus: AgendaSyncStatus.synced,
    );
    rows[event.id] = synced;
    return synced;
  }
}

class _HealthRemote implements HealthEventRemoteDataSource {
  _HealthRemote(this.trace);

  final List<String> trace;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<List<HealthEventEntity>> pull({DateTime? updatedAfter}) async {
    trace.add('health');
    return [
      HealthEventEntity(
        id: 'remote-health',
        babyId: 'baby-1',
        type: HealthEventType.pediatricControl,
        title: 'Control remoto',
        description: 'Historial restaurado',
        startsAt: DateTime.utc(2026, 8, 10),
        status: HealthEventStatus.completed,
        syncStatus: HealthSyncStatus.synced,
      ),
    ];
  }

  @override
  Future<HealthEventEntity> push(HealthEventEntity event) async => event;
}

class _SettingsRemote implements AppSettingsRemoteDataSource {
  _SettingsRemote(this.trace);

  final List<String> trace;

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<AppSettingsSyncRecord?> pull() async {
    trace.add('preferences');
    return AppSettingsSyncRecord(
      settings: const AppSettingsEntity(
        theme: AppThemePreference.system,
        highContrast: false,
        personalReminders: true,
        familyActivity: true,
        dailySummary: false,
        reduceMotion: false,
        wifiOnly: false,
        name: 'Remote Owner',
        email: 'owner@example.com',
        language: 'Español',
        timeFormat: '24 horas',
        textSize: 'Predeterminado',
      ),
      updatedAt: DateTime.utc(2026, 8, 12),
      syncStatus: AppSettingsSyncStatus.synced,
    );
  }

  @override
  Future<AppSettingsSyncRecord> push(AppSettingsSyncRecord record) async =>
      record;
}
