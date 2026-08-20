import 'dart:async';
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
  late _HealthRepository healthRepository;
  late _RegisterRepository registerRepository;
  late HealthFlowController controller;
  late BebeTheme bebeTheme;
  late List<HealthEventEntity> scheduledAppointmentReminders;

  setUpAll(() {
    sqfliteFfiInit();
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
    healthRepository = _HealthRepository(
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
          HealthEventEntity(
            id: 'control-1',
            babyId: baby.id,
            type: HealthEventType.pediatricControl,
            title: 'Control pediátrico trimestral',
            description: 'Seguimiento programado',
            startsAt: now.subtract(const Duration(hours: 1)),
            status: HealthEventStatus.scheduled,
            appointmentKind: HealthAppointmentKind.wellChildControl,
          ),
          HealthEventEntity(
            id: 'control-2',
            babyId: baby.id,
            type: HealthEventType.growthControl,
            title: 'Evaluación de crecimiento',
            description: 'Control de peso y talla',
            startsAt: now.add(const Duration(days: 20)),
            status: HealthEventStatus.scheduled,
            appointmentKind: HealthAppointmentKind.wellChildControl,
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
    registerRepository = _RegisterRepository([
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
        id: 'pediatrician-1',
        babyId: baby.id,
        type: RegisterEventType.clinicalObservation,
        occurredAt: now.subtract(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 30)),
        details: const {
          'observation_type': 'pediatrician_profile',
          'name': 'Dra. Andrea Pérez',
          'specialty': 'Pediatría general',
          'phone': '+56 9 5555 0000',
          'place': 'Centro médico del barrio',
        },
        syncStatus: RegisterSyncStatus.synced,
      ),
      RegisteredEvent(
        id: 'consultation-1',
        babyId: baby.id,
        type: RegisterEventType.clinicalObservation,
        occurredAt: now.subtract(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 7)),
        details: const {
          'observation_type': 'medical_consultation',
          'title': 'Revisión de rutina',
          'description': 'Evolución acorde a lo esperado.',
          'pediatrician': 'Dra. Andrea Pérez',
          'follow_up': 'Nuevo control en tres meses.',
        },
        syncStatus: RegisterSyncStatus.synced,
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
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    scheduledAppointmentReminders = [];
    final syncService = RegisterEventSyncService(
      syncLocalRepository,
      const _OfflineRemoteDataSource(),
    );
    controller = HealthFlowController(
      getFamilyOverview: GetFamilyOverview(familyRepository),
      getHealthOverview: GetHealthOverview(healthRepository),
      getRegisterEvents: GetRegisterEvents(registerRepository),
      saveRegisterEvent: SaveRegisterEvent(registerRepository),
      deleteRegisterEvent: DeleteRegisterEvent(registerRepository),
      healthRepository: healthRepository,
      registerSyncService: syncService,
      scheduleAppointmentReminder: (event) async {
        scheduledAppointmentReminders.add(event);
      },
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

  testWidgets('WT-HEALTH-REFRESH-001 refresh keeps hydrated health data', (
    tester,
  ) async {
    final pending = Completer<HealthOverviewEntity>();
    healthRepository.nextOverview = pending.future;
    final loading = controller.load(force: true);

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

    expect(find.byKey(const ValueKey('health-flow-skeleton')), findsNothing);
    expect(find.text('8.10 kg'), findsWidgets);
    expect(controller.isRefreshing, isTrue);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    pending.complete(healthRepository.overview);
    await loading;
    await tester.pump();
    expect(find.byKey(const ValueKey('health-flow-skeleton')), findsNothing);
    expect(controller.isRefreshing, isFalse);
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
    final first = tester.getRect(row('Control pediátrico trimestral'));
    final second = tester.getRect(row('Evaluación de crecimiento'));

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

  testWidgets('un registro de Salud se puede editar y eliminar', (
    tester,
  ) async {
    final measurement = controller.measurements.firstWhere(
      (item) => item.id == 'measurement-1',
    );
    controller.selectMeasurement(measurement);
    String? action;
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: HealthFlowDetailView(
            kind: HealthSectionKind.growth,
            action: HealthFlowAction.detail,
            controller: controller,
            openFlow: (value) => action = value,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Editar registro'));
    expect(action, HealthFlowAction.edit);

    await tester.tap(find.byKey(const ValueKey('health-delete-record')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(
      registerRepository.events.map((event) => event.id),
      isNot(contains('measurement-1')),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('WT-HEALTH-APPT-001 confirma asistencia sin cerrar el resumen', (
    tester,
  ) async {
    controller.selectHealthEvent(
      controller.controls.firstWhere((event) => event.id == 'control-1'),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: HealthFlowDetailView(
            kind: HealthSectionKind.controls,
            action: HealthFlowAction.detail,
            controller: controller,
            openFlow: _ignoreAction,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('health-confirm-attendance-later')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('health-mark-not-attended')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('health-reschedule-appointment')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('health-confirm-attendance-later')),
    );
    await tester.pumpAndSettle();

    expect(
      controller.selectedHealthEvent?.status,
      HealthEventStatus.attendedPendingSummary,
    );
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

    await tester.tap(find.text('Dra. Andrea Pérez'));

    expect(action, HealthFlowAction.detail);
    expect(find.text('Dra. Valeria Ruiz'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('crecimiento muestra estado vacío sin inventar una curva', (
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

    await tester.tap(find.text('Talla'));
    await tester.pump();

    expect(find.text('Sin mediciones de talla'), findsOneWidget);
    expect(find.textContaining('P50'), findsNothing);
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

  testWidgets('reportes distingue un período vacío de un valor cero', (
    tester,
  ) async {
    registerRepository.events.clear();
    await controller.load(force: true);
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

    expect(find.text('Sin actividad en este período'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(3));
    expect(find.text('0'), findsNothing);
    expect(find.text('Tendencias del período'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reportes funciona en dark mode, pantalla pequeña y texto grande',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: bebeTheme.darkTheme(),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.8)),
              child: Scaffold(
                body: ReportsSectionView(
                  controller: controller,
                  openFlow: _ignoreAction,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1 día'), findsOneWidget);
      expect(find.text('7 días'), findsOneWidget);
      expect(find.text('30 días'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

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
    expect(
      overview.growthSummary.recordedAtLabel,
      isNot('Último registro disponible'),
    );
  });

  test('Salud proyecta datos de Core sin completar perfiles ficticios', () {
    expect(controller.measurements.first.value, 8.1);
    expect(controller.consultations.single.title, 'Revisión de rutina');
    expect(controller.clinicalNotes.single.id, 'observation-1');
    expect(controller.pediatricians.single.name, 'Dra. Andrea Pérez');
    expect(controller.pediatricians.single.consultationCount, 1);
  });

  test('guardar pediatra persiste mediante la capa Core de Registro', () async {
    await controller.savePediatrician(
      name: 'Dr. Tomás Silva',
      specialty: 'Neonatología',
      phone: '+56 9 4444 0000',
      place: 'Centro de salud familiar',
    );

    final saved = controller.pediatricians.firstWhere(
      (pediatrician) => pediatrician.name == 'Dr. Tomás Silva',
    );
    expect(saved.specialty, 'Neonatología');
    expect(saved.phone, '+56 9 4444 0000');
    expect(saved.consultationCount, 0);
  });

  test(
    'una cita futura programa el recordatorio sin esperar la sincronización',
    () async {
      final future = DateTime.now().add(const Duration(days: 3));

      await controller.saveConsultation(
        occurredAt: future,
        pediatrician: '',
        reason: '',
        summary: '',
        treatment: '',
        followUp: '',
        vigilance: '',
        appointmentKind: HealthAppointmentKind.consultation,
      );
      await Future<void>.delayed(Duration.zero);

      expect(scheduledAppointmentReminders, hasLength(1));
      expect(scheduledAppointmentReminders.single.title, 'Consulta pediátrica');
      expect(
        scheduledAppointmentReminders.single.status,
        HealthEventStatus.scheduled,
      );
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
  Stream<String> get activeBabyChanges => const Stream<String>.empty();

  @override
  Future<FamilyOverviewEntity> getCurrent() async => overview;
}

class _HealthRepository extends Fake implements HealthRepository {
  _HealthRepository(this.overview);

  final HealthOverviewEntity overview;
  Future<HealthOverviewEntity>? nextOverview;
  var _sequence = 0;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<HealthOverviewEntity> getOverview(String babyId) async {
    final pending = nextOverview;
    nextOverview = null;
    return pending ?? overview;
  }

  @override
  Future<HealthEventEntity?> getEvent(String id) async =>
      overview.events.where((event) => event.id == id).firstOrNull;

  @override
  Future<HealthEventEntity> createEvent(HealthEventDraft draft) async {
    final now = DateTime.now();
    final saved = HealthEventEntity(
      id: 'health-saved-${++_sequence}',
      babyId: draft.babyId,
      type: draft.type,
      title: draft.title,
      description: draft.description,
      startsAt: draft.startsAt,
      status: draft.status,
      appointmentKind: draft.appointmentKind,
      reason: draft.reason,
      timezone: draft.timezone,
      attendedAt: draft.attendedAt,
      completedAt: draft.completedAt,
      professionalName: draft.professionalName,
      clinicalSummary: draft.clinicalSummary,
      professionalAssessment: draft.professionalAssessment,
      indications: draft.indications,
      createdAt: now,
      updatedAt: now,
    );
    overview.events.add(saved);
    return saved;
  }

  @override
  Future<HealthEventEntity?> updateEvent(
    String id,
    HealthEventPatch patch,
  ) async {
    final index = overview.events.indexWhere((event) => event.id == id);
    if (index < 0) return null;
    final current = overview.events[index];
    final updated = HealthEventEntity(
      id: current.id,
      babyId: current.babyId,
      type: patch.type ?? current.type,
      title: patch.title ?? current.title,
      description: patch.description ?? current.description,
      startsAt: patch.startsAt ?? current.startsAt,
      status: patch.status ?? current.status,
      appointmentKind: patch.appointmentKind ?? current.appointmentKind,
      reason: patch.reason ?? current.reason,
      timezone: patch.timezone ?? current.timezone,
      attendedAt: patch.attendedAt ?? current.attendedAt,
      completedAt: patch.completedAt ?? current.completedAt,
      professionalName: patch.professionalName ?? current.professionalName,
      clinicalSummary: patch.clinicalSummary ?? current.clinicalSummary,
      professionalAssessment:
          patch.professionalAssessment ?? current.professionalAssessment,
      indications: patch.indications ?? current.indications,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    overview.events[index] = updated;
    return updated;
  }
}

class _RegisterRepository extends Fake implements RegisterEventRepository {
  _RegisterRepository(this.events);

  final List<RegisteredEvent> events;
  int _sequence = 0;

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
  Future<RegisteredEvent> save(RegisterEventDraft draft) async {
    final now = DateTime.now();
    final saved = RegisteredEvent(
      id: 'saved-${_sequence++}',
      babyId: draft.babyId,
      type: draft.type,
      occurredAt: draft.occurredAt,
      createdAt: now,
      details: draft.details,
      notes: draft.notes,
      caregiverId: draft.caregiverId,
      schemaVersion: draft.schemaVersion,
    );
    events.insert(0, saved);
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    events.removeWhere((event) => event.id == id);
  }
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
