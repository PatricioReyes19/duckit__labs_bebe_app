import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ImmunizationCatalog catalog;
  const planner = ImmunizationSchedulePlanner();

  setUpAll(() async {
    catalog = await BundledImmunizationCatalog.load();
  });

  List<String> ids({
    required DateTime birthDate,
    required DateTime now,
    bool premature = false,
    bool rapaNui = false,
    bool rsvRisk = false,
    List<ImmunizationRecord> records = const [],
  }) => planner
      .plan(
        catalog: catalog,
        context: ImmunizationEligibilityContext(
          birthDate: birthDate,
          isPremature: premature,
          livesInRapaNui: rapaNui,
          hasRsvRisk: rsvRisk,
        ),
        records: records,
        now: now,
      )
      .map((item) => item.item.id)
      .toList(growable: false);

  test('carga un catálogo vigente, versionado y con fuente', () {
    expect(catalog.version, 'PNI-2026.1');
    expect(catalog.sourceName, isNotEmpty);
    expect(catalog.items, isNotEmpty);
  });

  test('recién nacido incluye BCG y Hepatitis B', () {
    final result = ids(
      birthDate: DateTime(2026, 8, 20),
      now: DateTime(2026, 8, 20),
    );

    expect(result, containsAll(['bcg-rn', 'hep-b-rn']));
  });

  test('a los dos meses deriva MenB, hexavalente y PCV13', () {
    final result = ids(
      birthDate: DateTime(2026, 6, 20),
      now: DateTime(2026, 8, 20),
    );

    expect(result, containsAll(['men-b-1', 'hexavalent-1', 'pcv13-1']));
    expect(result, isNot(contains('pcv20-1')));
  });

  test('a los seis meses de término incluye influenza, no PCV adicional', () {
    final result = ids(
      birthDate: DateTime(2026, 2, 20),
      now: DateTime(2026, 8, 20),
    );

    expect(
      result,
      containsAll([
        'hexavalent-3',
        'influenza-2026-dose-1',
        'influenza-2026-dose-2',
      ]),
    );
    expect(result, isNot(contains('pcv13-3-preterm')));
  });

  test('a los seis meses prematuro incluye tercera neumocócica', () {
    final result = ids(
      birthDate: DateTime(2026, 2, 20),
      now: DateTime(2026, 8, 20),
      premature: true,
    );

    expect(result, contains('pcv13-3-preterm'));
  });

  test('a los doce meses incluye SRP, ACWY y refuerzo neumocócico', () {
    final result = ids(
      birthDate: DateTime(2025, 8, 20),
      now: DateTime(2026, 8, 20),
    );

    expect(result, containsAll(['srp-1', 'men-acwy-1', 'pcv13-booster']));
  });

  test('a los dieciocho meses incluye refuerzos, Hep A y Varicela', () {
    final result = ids(
      birthDate: DateTime(2025, 2, 20),
      now: DateTime(2026, 8, 20),
    );

    expect(
      result,
      containsAll([
        'hexavalent-booster',
        'hep-a',
        'varicella-1',
        'men-b-booster',
      ]),
    );
    expect(result, isNot(contains('yellow-fever-rapa-nui')));
  });

  test('Rapa Nui agrega fiebre amarilla a los dieciocho meses', () {
    final result = ids(
      birthDate: DateTime(2025, 2, 20),
      now: DateTime(2026, 8, 20),
      rapaNui: true,
    );

    expect(result, contains('yellow-fever-rapa-nui'));
  });

  test('a los treinta y seis meses incluye segunda SRP y Varicela', () {
    final result = ids(
      birthDate: DateTime(2023, 8, 20),
      now: DateTime(2026, 8, 20),
    );

    expect(result, containsAll(['srp-2', 'varicella-2']));
  });

  test(
    'el corte de vigencia conserva PCV13 antes y usa PCV20 desde septiembre',
    () {
      final august = ids(
        birthDate: DateTime(2026, 6, 30),
        now: DateTime(2026, 8, 30),
      );
      final september = ids(
        birthDate: DateTime(2026, 7, 1),
        now: DateTime(2026, 9, 1),
      );

      expect(august, contains('pcv13-1'));
      expect(august, isNot(contains('pcv20-1')));
      expect(september, contains('pcv20-1'));
      expect(september, isNot(contains('pcv13-1')));
    },
  );

  test('Nirsevimab conserva tipo monoclonal y una sola cohorte aplicable', () {
    final planned = planner.plan(
      catalog: catalog,
      context: ImmunizationEligibilityContext(
        birthDate: DateTime(2026, 5, 1),
        hasRsvRisk: true,
      ),
      records: const [],
      now: DateTime(2026, 5, 2),
    );
    final nirsevimab = planned
        .where((item) => item.item.id.startsWith('nirsevimab-'))
        .toList(growable: false);

    expect(nirsevimab, hasLength(1));
    expect(
      nirsevimab.single.item.itemType,
      ImmunizationItemType.monoclonalAntibody,
    );
  });

  test('influenza previa completa deja una dosis anual de campaña', () {
    final result = ids(
      birthDate: DateTime(2025, 2, 20),
      now: DateTime(2026, 8, 20),
      records: [
        _record('influenza-2025-dose-1'),
        _record('influenza-2025-dose-2'),
      ],
    );

    expect(result, contains('influenza-2026-dose-1'));
    expect(result, isNot(contains('influenza-2026-dose-2')));
  });
}

ImmunizationRecord _record(String catalogItemId) => ImmunizationRecord(
  id: catalogItemId,
  babyId: 'baby-1',
  catalogItemId: catalogItemId,
  nameSnapshot: 'Influenza',
  doseLabel: 'Dosis',
  administeredAt: DateTime(2025, 8, 20),
  createdBy: 'caregiver-1',
);
