import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late BebeDatabase database;
  late SqliteFamilyRepository families;
  late SqliteAgendaRepository agenda;
  late SqliteHealthRepository health;
  late SqliteAppSettingsRepository settings;

  setUp(() {
    database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
      seedDemoData: true,
    );
    families = SqliteFamilyRepository(database);
    agenda = SqliteAgendaRepository(database, idGenerator: () => 'agenda-new');
    health = SqliteHealthRepository(database, idGenerator: () => 'health-new');
    settings = SqliteAppSettingsRepository(database);
  });

  tearDown(() => database.close());

  test('a production database starts without demo babies or records', () async {
    final productionDatabase = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(productionDatabase.close);

    final raw = await productionDatabase.database;
    final babyCount = (await raw.rawQuery(
      'SELECT COUNT(*) AS total FROM babies',
    )).single['total'];
    final agendaCount = (await raw.rawQuery(
      'SELECT COUNT(*) AS total FROM agenda_events',
    )).single['total'];
    final healthCount = (await raw.rawQuery(
      'SELECT COUNT(*) AS total FROM health_events',
    )).single['total'];

    expect(babyCount, 0);
    expect(agendaCount, 0);
    expect(healthCount, 0);
  });

  test(
    'production onboarding creates only the submitted family and baby',
    () async {
      final productionDatabase = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      addTearDown(productionDatabase.close);
      final repository = SqliteFamilyRepository(
        productionDatabase,
        idGenerator: (prefix) => '$prefix-created',
      );

      final family = await repository.createInitialFamily(
        InitialFamilyDraft(
          familyName: 'Círculo de Emilia',
          babyName: 'Emilia',
          birthDate: DateTime.utc(2026, 2, 3),
          ownerName: 'Paula Pérez',
          ownerEmail: 'paula@example.com',
          avatarAssetPath: r'C:\private\baby_profiles\emilia.png',
        ),
      );
      final raw = await productionDatabase.database;
      final agendaCount = (await raw.rawQuery(
        'SELECT COUNT(*) AS total FROM agenda_events',
      )).single['total'];
      final healthCount = (await raw.rawQuery(
        'SELECT COUNT(*) AS total FROM health_events',
      )).single['total'];

      expect(family.name, 'Círculo de Emilia');
      expect(family.babies, hasLength(1));
      expect(family.activeBaby.name, 'Emilia');
      expect(
        family.activeBaby.avatarAssetPath,
        r'C:\private\baby_profiles\emilia.png',
      );
      expect(family.members, hasLength(1));
      expect(agendaCount, 0);
      expect(healthCount, 0);
    },
  );

  test(
    'seeds the local application graph and resolves relationships',
    () async {
      final family = await families.getCurrent();
      final agendaOverview = await agenda.getOverview(family.activeBabyId);
      final healthOverview = await health.getOverview(family.activeBabyId);

      expect(family.activeBaby.name, 'Mateo Reyes');
      expect(family.pendingInvitations, 1);
      expect(agendaOverview.events, isNotEmpty);
      expect(
        agendaOverview.events
            .firstWhere((event) => event.caregiver != null)
            .caregiver!
            .familyId,
        family.id,
      );
      expect(healthOverview.completedVaccines, 4);
      expect(healthOverview.pendingVaccines, 1);
      expect(healthOverview.measurements, hasLength(2));
    },
  );

  test('persists, resends and cancels caregiver invitations', () async {
    final family = await families.getCurrent();
    final invitation = await families.sendInvitation(
      FamilyInvitationDraft(
        familyId: family.id,
        babyId: family.activeBaby.id,
        babyName: family.activeBaby.name,
        name: 'Paula Pérez',
        contact: 'paula@example.com',
        role: 'Tía',
        accessDescription: 'ver historial, recibir recordatorios',
        canWrite: false,
      ),
    );

    expect(invitation.status, FamilyMemberStatus.pending);
    expect(invitation.invitationCode, startsWith('BEBE-'));
    expect((await families.getCurrent()).pendingInvitations, 2);

    final resent = await families.resendInvitation(invitation.id);
    expect(resent?.invitedAt, isNotNull);
    expect(resent?.invitationExpiresAt, isNotNull);

    await families.cancelInvitation(invitation.id);
    expect((await families.getCurrent()).pendingInvitations, 1);
  });

  test(
    'joining an invitation creates an active care-circle membership',
    () async {
      final productionDatabase = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      addTearDown(productionDatabase.close);
      final repository = SqliteFamilyRepository(productionDatabase);

      final joined = await repository.joinCareCircle(
        JoinedCareCircleDraft(
          familyId: 'family-mateo',
          familyName: 'Círculo de Mateo',
          babyId: 'baby-mateo',
          babyName: 'Mateo',
          babyBirthDate: DateTime.utc(2026, 1, 1),
          memberId: 'user-paula',
          memberName: 'Paula Pérez',
          memberEmail: 'paula@example.com',
        ),
      );

      expect(joined.activeBaby.name, 'Mateo');
      expect(joined.members, hasLength(1));
      expect(joined.members.single.status, FamilyMemberStatus.active);
    },
  );

  test('the most recently joined care circle becomes current', () async {
    await families.joinCareCircle(
      JoinedCareCircleDraft(
        familyId: 'family-new',
        familyName: 'Círculo de Amanda',
        babyId: 'baby-amanda',
        babyName: 'Amanda',
        babyBirthDate: DateTime.utc(2026, 4, 2),
        memberId: 'member-user-family-new',
        memberName: 'Paula Pérez',
        memberEmail: 'paula@example.com',
      ),
    );

    expect((await families.getCurrent()).id, 'family-new');
  });

  test('supports POST and PATCH semantics for agenda and settings', () async {
    final created = await agenda.create(
      AgendaEventDraft(
        babyId: BebeSeedData.activeBabyId,
        category: AgendaCategory.controls,
        title: 'Control nuevo',
        description: 'Control local',
        startsAt: DateTime.utc(2026, 9, 1, 12),
      ),
    );
    final patched = await agenda.update(
      created.id,
      const AgendaEventPatch(
        title: 'Control actualizado',
        syncStatus: AgendaSyncStatus.synced,
      ),
    );
    final updatedSettings = await settings.update(
      const AppSettingsPatch(wifiOnly: true, dailySummary: true),
    );

    expect(patched?.title, 'Control actualizado');
    expect(patched?.description, 'Control local');
    // Toda edición local vuelve a la cola de sincronización.
    expect(patched?.syncStatus, AgendaSyncStatus.pending);
    expect(updatedSettings.wifiOnly, isTrue);
    expect(updatedSettings.dailySummary, isTrue);
  });

  test('agenda reflects persisted reminder preferences', () async {
    final registerRepository = SqliteRegisterEventRepository(
      database: database,
    );
    final getOverview = GetAgendaOverview(agenda, registerRepository, settings);

    expect(
      (await getOverview(BebeSeedData.activeBabyId)).remindersEnabled,
      isTrue,
    );
    final changed = settings.changes.first;
    await settings.update(const AppSettingsPatch(personalReminders: false));
    await changed;

    expect(
      (await getOverview(BebeSeedData.activeBabyId)).remindersEnabled,
      isFalse,
    );
  });

  test('supports POST and PATCH semantics for health events', () async {
    final created = await health.createEvent(
      HealthEventDraft(
        babyId: BebeSeedData.activeBabyId,
        type: HealthEventType.pediatricControl,
        title: 'Control',
        description: 'Pendiente',
        startsAt: DateTime.utc(2026, 9, 2, 12),
      ),
    );
    final patched = await health.updateEvent(
      created.id,
      const HealthEventPatch(status: HealthEventStatus.completed),
    );

    expect(patched?.status, HealthEventStatus.completed);
    expect(patched?.title, 'Control');
  });
}
