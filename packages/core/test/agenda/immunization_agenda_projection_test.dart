import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'proyecta dosis futuras en agenda y las retira al registrarlas',
    () async {
      final database = BebeDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
        seedDemoData: true,
      );
      addTearDown(database.close);
      final families = SqliteFamilyRepository(database);
      final health = SqliteHealthRepository(
        database,
        idGenerator: () => 'applied-immunization',
      );
      final overview = GetAgendaOverview(
      SqliteAgendaRepository(database),
      SqliteRegisterEventRepository(database: database),
        SqliteAppSettingsRepository(database),
        health,
        GetFamilyOverview(families),
      );

      final before = await overview(BebeSeedData.activeBabyId);
      final projected = before.events.firstWhere(
        (event) => event.id.startsWith('immunization:'),
      );
      final payload = projected.id.substring('immunization:'.length);
      final catalogItemId = payload.substring(0, payload.indexOf(':'));
      final catalog = await BundledImmunizationCatalog.load();
      final item = catalog.items.singleWhere(
        (item) => item.id == catalogItemId,
      );

      await health.createEvent(
        HealthEventDraft(
          babyId: BebeSeedData.activeBabyId,
          type: item.itemType == ImmunizationItemType.monoclonalAntibody
              ? HealthEventType.immunization
              : HealthEventType.vaccine,
          title: item.displayName,
          description: item.doseLabel,
          startsAt: projected.startsAt,
          attendedAt: projected.startsAt,
          status: HealthEventStatus.completed,
          immunizationCatalogItemId: item.id,
          immunizationNameSnapshot: item.displayName,
          immunizationItemType: item.itemType,
          immunizationSourceType: item.sourceType,
          immunizationSourceVersion: item.sourceVersion,
          immunizationDoseLabel: item.doseLabel,
        ),
      );

      final after = await overview(BebeSeedData.activeBabyId);
      expect(
        after.events.map((event) => event.id),
        isNot(contains(projected.id)),
      );
    },
  );
}
