import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:health/models/health_overview_vm.dart';
import 'package:health/pages/views/health_section_views.dart';
import 'package:health/pages/views/health_flow_widgets.dart';
import 'package:health/pages/views/health_flow_detail_views.dart';
import 'package:health/services/health_report_exporter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteRegisterEventRepository syncLocalRepository;
  late HealthFlowController controller;
  late BebeTheme bebeTheme;

  setUpAll(() {
    final candidates = [
      File('packages/design_system/assets/json/bebe_theme.json'),
      File('../design_system/assets/json/bebe_theme.json'),
    ];
    final file = candidates.firstWhere((candidate) => candidate.existsSync());
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    bebeTheme = BebeTheme.fromJson(json);
  });

  setUp(() async {
    final now = DateTime.now();
    final baby = BabyEntity(
      id: 'baby-1',
      familyId: 'family-1',
      name: 'Mateo',
      birthDate: DateTime(now.year, now.month - 2, now.day),
    );
    final familyRepository = _FamilyRepository(
      FamilyOverviewEntity(
        id: 'family-1',
        name: 'Familia Mateo',
        activeBabyId: baby.id,
        babies: [baby],
        members: const [],
      ),
    );
    final healthRepository = _HealthRepository(
      HealthOverviewEntity(
        events: [
          HealthEventEntity(
            id: 'vaccine-1',
            babyId: baby.id,
            type: HealthEventType.vaccine,
            title: 'Neumococo (2da dosis)',
            description: 'Próxima vacuna',
            startsAt: now.add(const Duration(days: 5)),
            status: HealthEventStatus.scheduled,
          ),
        ],
        measurements: [
          HealthMeasurementEntity(
            id: 'weight-1',
            babyId: baby.id,
            type: HealthMeasurementType.weight,
            value: 7.25,
            unit: 'kg',
            recordedAt: now,
            source: 'Control pediátrico',
          ),
        ],
      ),
    );
    final registerRepository = _RegisterRepository([
      RegisteredEvent(
        id: 'feeding-1',
        babyId: baby.id,
        type: RegisterEventType.feeding,
        occurredAt: now,
        createdAt: now,
        details: const {'amount_ml': 120, 'unit': 'mL'},
        syncStatus: RegisterSyncStatus.synced,
      ),
      RegisteredEvent(
        id: 'observation-1',
        babyId: baby.id,
        type: RegisterEventType.clinicalObservation,
        occurredAt: now,
        createdAt: now,
        details: const {
          'title': 'Alergia en mejillas',
          'description': 'Enrojecimiento leve.',
        },
        syncStatus: RegisterSyncStatus.pending,
      ),
      RegisteredEvent(
        id: 'measurement-1',
        babyId: baby.id,
        type: RegisterEventType.measurement,
        occurredAt: now.add(const Duration(minutes: 1)),
        createdAt: now,
        details: const {
          'measurement_type': 'weight',
          'value': 8.1,
          'unit': 'kg',
        },
        syncStatus: RegisterSyncStatus.pending,
      ),
    ]);
    syncLocalRepository = SqliteRegisterEventRepository(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    final syncService = RegisterEventSyncService(
      syncLocalRepository,
      const _OfflineRemoteDataSource(),
    );
    controller = HealthFlowController(
      getFamilyOverview: GetFamilyOverview(familyRepository),
      getHealthOverview: GetHealthOverview(healthRepository),
      getRegisterEvents: GetRegisterEvents(registerRepository),
      saveRegisterEvent: SaveRegisterEvent(registerRepository),
      healthRepository: healthRepository,
      registerSyncService: syncService,
    );
    await controller.load();
  });

  tearDown(() async {
    controller.dispose();
    await syncLocalRepository.close();
  });

  testWidgets('los flujos principales renderizan en ancho móvil', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final views = <Widget>[
      VaccinesSectionView(controller: controller, openFlow: _ignoreAction),
      ControlsSectionView(controller: controller, openFlow: _ignoreAction),
      GrowthSectionView(controller: controller, openFlow: _ignoreAction),
      ConsultationsSectionView(controller: controller, openFlow: _ignoreAction),
      PediatricCareSectionView(controller: controller, openFlow: _ignoreAction),
      ClinicalHistorySectionView(
        controller: controller,
        openFlow: _ignoreAction,
      ),
      ReportsSectionView(controller: controller, openFlow: _ignoreAction),
      SyncSectionView(controller: controller, openFlow: _ignoreAction),
    ];

    for (final view in views) {
      await tester.pumpWidget(
        MaterialApp(
          theme: bebeTheme.lightTheme(),
          home: Scaffold(body: view),
        ),
      );
      await tester.pump();
      expect(find.byType(ListView), findsWidgets);
      expect(
        find.text('Mateo'),
        findsNothing,
        reason: '${view.runtimeType} no debe repetir el encabezado del bebé.',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'Falló ${view.runtimeType} en 430 px de ancho.',
      );
    }
  });

  testWidgets('crecimiento muestra la medición real más reciente', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: GrowthSectionView(
            controller: controller,
            openFlow: _ignoreAction,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('8.10 kg'), findsWidgets);
    expect(find.text('P41'), findsNothing);
    expect(find.text('6.65 kg'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controles conserva separación entre tarjetas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: ControlsSectionView(
            controller: controller,
            openFlow: _ignoreAction,
          ),
        ),
      ),
    );
    await tester.pump();

    Finder row(String title) => find.byWidgetPredicate(
      (widget) => widget is HealthActionRow && widget.title == title,
    );
    final first = tester.getRect(row('Control de 4 meses'));
    final second = tester.getRect(row('Control de crecimiento'));

    expect(second.top - first.bottom, greaterThanOrEqualTo(12));
    expect(tester.takeException(), isNull);
  });

  testWidgets('el detalle de crecimiento tampoco usa datos mock', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: HealthFlowDetailView(
            kind: HealthSectionKind.growth,
            action: HealthFlowAction.detail,
            controller: controller,
            openFlow: _ignoreAction,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('8.10 kg'), findsOneWidget);
    expect(find.text('Mateo'), findsNothing);
    expect(find.text('Percentil P41'), findsNothing);
    expect(find.text('16 may 2025 · 10:30'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la tarjeta completa del pediatra abre el detalle', (
    tester,
  ) async {
    String? action;
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: PediatricCareSectionView(
            controller: controller,
            openFlow: (value) => action = value,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Dra. Valeria Ruiz'));

    expect(action, HealthFlowAction.detail);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reportes mantiene tres métricas en una fila y rotula ejes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: ReportsSectionView(
            controller: controller,
            openFlow: _ignoreAction,
          ),
        ),
      ),
    );
    await tester.pump();

    Finder metric(String label) => find.byWidgetPredicate(
      (widget) => widget is BebeCompactMetricCard && widget.label == label,
    );
    final topPositions = [
      tester.getTopLeft(metric('Alimentación')).dy,
      tester.getTopLeft(metric('Sueño')).dy,
      tester.getTopLeft(metric('Pañales')).dy,
    ];

    expect(topPositions.toSet(), hasLength(1));
    expect(find.text('Cantidad'), findsOneWidget);
    expect(find.text('Día'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'genera los reportes PDF y CSV completamente en el dispositivo',
    () async {
      final exporter = HealthReportExporter(loadAsset: _loadReportAsset);

      final pdf = await exporter.buildPdf(controller);
      final csv = utf8.decode(exporter.buildCsv(controller));

      expect(pdf.take(4), orderedEquals('%PDF'.codeUnits));
      expect(pdf.length, greaterThan(1000));
      expect(csv, contains('fecha'));
      expect(csv, contains('Alimentación'));
    },
  );

  test('el resumen de salud usa mediciones guardadas por Registro', () {
    final now = DateTime.now();
    final overview = HealthOverviewVm.fromEntity(
      const HealthOverviewEntity(events: [], measurements: []),
      registerEvents: [
        RegisteredEvent(
          id: 'measurement-summary',
          babyId: 'baby-1',
          type: RegisterEventType.measurement,
          occurredAt: now,
          createdAt: now,
          details: const {
            'measurement_type': 'weight',
            'value': 8.4,
            'unit': 'kg',
          },
        ),
      ],
    );

    expect(overview.growthSummary.weightKg, 8.4);
    expect(overview.growthSummary.recordedAtLabel, isNotNull);
  });
}

void _ignoreAction(String _) {}

Future<ByteData> _loadReportAsset(String key) async {
  final fileName = key.split('/').last;
  final candidates = [
    File('packages/design_system/assets/fonts/$fileName'),
    File('../design_system/assets/fonts/$fileName'),
  ];
  final file = candidates.firstWhere((candidate) => candidate.existsSync());
  return ByteData.sublistView(await file.readAsBytes());
}

class _FamilyRepository extends Fake implements FamilyRepository {
  _FamilyRepository(this.overview);

  final FamilyOverviewEntity overview;

  @override
  Future<FamilyOverviewEntity> getCurrent() async => overview;
}

class _HealthRepository extends Fake implements HealthRepository {
  _HealthRepository(this.overview);

  final HealthOverviewEntity overview;

  @override
  Future<HealthOverviewEntity> getOverview(String babyId) async => overview;
}

class _RegisterRepository extends Fake implements RegisterEventRepository {
  _RegisterRepository(this.events);

  final List<RegisteredEvent> events;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async => events
      .where((event) => type == null || event.type == type)
      .take(limit ?? events.length)
      .toList(growable: false);

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) async =>
      throw UnimplementedError();
}

class _OfflineRemoteDataSource implements RegisterEventRemoteDataSource {
  const _OfflineRemoteDataSource();

  @override
  bool get isConfigured => false;

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<List<RegisteredEvent>> pull({DateTime? updatedAfter}) async =>
      const [];

  @override
  Future<RegisteredEvent> push(RegisteredEvent event) async => event;
}
