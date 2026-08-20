import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('conserva el snapshot de una inmunización administrada', () async {
    final database = BebeDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
      seedDemoData: true,
    );
    addTearDown(database.close);
    final repository = SqliteHealthRepository(
      database,
      idGenerator: () => 'nirsevimab-record',
      clock: () => DateTime.utc(2026, 5, 2),
    );

    await repository.createEvent(
      HealthEventDraft(
        babyId: BebeSeedData.activeBabyId,
        type: HealthEventType.immunization,
        title: 'Nirsevimab contra VRS (Dosis única)',
        description: 'Dosis única',
        startsAt: DateTime.utc(2026, 5, 1),
        attendedAt: DateTime.utc(2026, 5, 1),
        completedAt: DateTime.utc(2026, 5, 1),
        status: HealthEventStatus.completed,
        facility: 'Hospital local',
        professionalName: 'Dra. Rivera',
        lotNumber: 'LOT-42',
        notesBeforeVisit: 'Sin reacciones',
        immunizationCatalogItemId: 'nirsevimab-2026-newborn',
        immunizationNameSnapshot: 'Nirsevimab contra VRS',
        immunizationItemType: ImmunizationItemType.monoclonalAntibody,
        immunizationSourceType: ImmunizationSourceType.minsalCampaign,
        immunizationSourceVersion: 'Campaña VRS 2026',
        immunizationDoseLabel: 'Dosis única',
        createdBy: 'caregiver-1',
      ),
    );

    final saved = (await repository.getOverview(
      BebeSeedData.activeBabyId,
    )).events.singleWhere((event) => event.id == 'nirsevimab-record');
    final record = saved.immunizationRecord;

    expect(record, isNotNull);
    expect(record!.nameSnapshot, 'Nirsevimab contra VRS');
    expect(record.doseLabel, 'Dosis única');
    expect(record.itemType, ImmunizationItemType.monoclonalAntibody);
    expect(record.sourceType, ImmunizationSourceType.minsalCampaign);
    expect(record.sourceVersion, 'Campaña VRS 2026');
    expect(record.lotNumber, 'LOT-42');
  });
}
