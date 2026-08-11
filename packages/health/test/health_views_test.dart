import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:health/pages/views/health_section_views.dart';
import 'package:health/services/health_report_exporter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteRegisterEventRepository syncLocalRepository;
  late HealthFlowController controller;

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
        details: const {'amount': 120, 'unit': 'ml'},
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
          theme: ThemeData.light(),
          home: Scaffold(body: view),
        ),
      );
      await tester.pump();
      expect(find.byType(ListView), findsWidgets);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Falló ${view.runtimeType} en 430 px de ancho.',
      );
    }
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
