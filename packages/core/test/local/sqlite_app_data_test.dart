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
    );
    families = SqliteFamilyRepository(database);
    agenda = SqliteAgendaRepository(database, idGenerator: () => 'agenda-new');
    health = SqliteHealthRepository(database, idGenerator: () => 'health-new');
    settings = SqliteAppSettingsRepository(database);
  });

  tearDown(() => database.close());

  test(
    'seeds the local application graph and resolves relationships',
    () async {
      final family = await families.getCurrent();
      final agendaOverview = await agenda.getOverview(family.activeBabyId);
      final healthOverview = await health.getOverview(family.activeBabyId);

      expect(family.activeBaby.name, 'Mateo Reyes');
      expect(family.pendingInvitations, 1);
      expect(agendaOverview.events, isNotEmpty);
      expect(agendaOverview.events.first.caregiver?.familyId, family.id);
      expect(healthOverview.completedVaccines, 4);
      expect(healthOverview.pendingVaccines, 1);
      expect(healthOverview.measurements, hasLength(2));
    },
  );

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
    expect(patched?.syncStatus, AgendaSyncStatus.synced);
    expect(updatedSettings.wifiOnly, isTrue);
    expect(updatedSettings.dailySummary, isTrue);
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
