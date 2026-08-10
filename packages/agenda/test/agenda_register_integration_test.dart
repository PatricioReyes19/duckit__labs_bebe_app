import 'dart:convert';
import 'dart:io';

import 'package:agenda/agenda.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BebeTheme bebeTheme;

  setUpAll(() async {
    await initializeDateFormatting('es');
    final candidates = [
      File('../design_system/assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ];
    final file = candidates.firstWhere((candidate) => candidate.existsSync());
    bebeTheme = BebeTheme.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );
  });

  testWidgets('separates scheduled events from registered daily activity', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 10, 10);
    final agendaRepository = _FakeAgendaRepository(
      AgendaOverviewEntity(
        events: [
          AgendaEventEntity(
            id: 'control-1',
            babyId: 'baby-1',
            category: AgendaCategory.controls,
            title: 'Control pediátrico',
            description: 'Llevar carnet',
            startsAt: now.add(const Duration(hours: 2)),
            syncStatus: AgendaSyncStatus.synced,
          ),
        ],
        remindersEnabled: true,
        isOffline: false,
      ),
    );
    final registerRepository = _FakeRegisterRepository([
      RegisteredEvent(
        id: 'feeding-1',
        babyId: 'baby-1',
        type: RegisterEventType.feeding,
        occurredAt: now.subtract(const Duration(minutes: 20)),
        createdAt: now,
        details: const {'subtype': 'bottle', 'amount_ml': 90},
        syncStatus: RegisterSyncStatus.pending,
      ),
    ]);
    final bloc = AgendaBloc(
      getAgendaOverview: GetAgendaOverview(
        agendaRepository,
        registerRepository,
      ),
      babyId: 'baby-1',
      clock: () => now,
    )..add(const AgendaEvent.started());
    addTearDown(bloc.close);
    var registerPressed = false;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: AgendaView(
              onRegisterPressed: () => registerPressed = true,
              onRegisterHistoryPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Programado'), findsOneWidget);
    expect(find.text('Control pediátrico'), findsWidgets);
    expect(find.text('Registros del día'), findsOneWidget);
    expect(find.text('Alimentación'), findsOneWidget);
    expect(find.textContaining('90 mL'), findsOneWidget);

    await tester.ensureVisible(find.text('Registrar evento ahora'));
    await tester.tap(find.text('Registrar evento ahora'));
    expect(registerPressed, isTrue);
    expect(tester.takeException(), isNull);
  });
}

class _FakeAgendaRepository implements AgendaRepository {
  _FakeAgendaRepository(this.overview);

  final AgendaOverviewEntity overview;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<AgendaEventEntity> create(AgendaEventDraft draft) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}

  @override
  Future<AgendaEventEntity?> findById(String id) async => null;

  @override
  Future<AgendaOverviewEntity> getOverview(String babyId) async => overview;

  @override
  Stream<AgendaOverviewEntity> observeOverview(String babyId) =>
      Stream.value(overview);

  @override
  Future<AgendaEventEntity?> update(String id, AgendaEventPatch patch) async =>
      null;
}

class _FakeRegisterRepository implements RegisterEventRepository {
  _FakeRegisterRepository(this.events);

  final List<RegisteredEvent> events;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<void> delete(String id) async {}

  @override
  Future<RegisteredEvent?> findById(String id) async => null;

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async => events;

  @override
  Stream<List<RegisteredEvent>> observeByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) => Stream.value(events);

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) =>
      throw UnimplementedError();

  @override
  Future<RegisteredEvent?> update(String id, RegisterEventPatch patch) async =>
      null;
}
