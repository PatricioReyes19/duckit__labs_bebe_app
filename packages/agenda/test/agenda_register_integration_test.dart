import 'dart:async';
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
          for (var index = 0; index < 6; index++)
            AgendaEventEntity(
              id: 'upcoming-$index',
              babyId: 'baby-1',
              category: AgendaCategory.medication,
              title: 'Dosis ${index + 1}',
              description: 'Medicamento programado',
              startsAt: now.add(Duration(days: index + 1)),
              syncStatus: AgendaSyncStatus.synced,
            ),
          for (var index = 0; index < 4; index++)
            AgendaEventEntity(
              id: 'recurring-dose-$index',
              babyId: 'baby-1',
              category: AgendaCategory.medication,
              title: 'Próxima dosis: Vitamina D',
              description: '5 gotas · Una vez al día',
              startsAt: now.add(Duration(days: index + 10)),
              sourceRegisterEventId: 'medication-vitamin-d',
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
    expect(
      find.byKey(const ValueKey('agenda-upcoming-scroll-viewport')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('agenda-upcoming-scroll-list')),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('agenda-upcoming-scroll-viewport')),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('agenda-upcoming-scroll-list')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('agenda-upcoming-scroll-list')),
        matching: find.text('Próxima dosis: Vitamina D'),
      ),
      findsOneWidget,
    );
    expect(find.text('Diario · 4x'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'4 ocurrencias agrupadas')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Registrar evento ahora'));
    await tester.tap(find.text('Registrar evento ahora'));
    expect(registerPressed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups recurring events for the selected day into one card', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 10, 8);
    final agendaRepository = _FakeAgendaRepository(
      AgendaOverviewEntity(
        events: [
          for (var index = 0; index < 2; index++)
            AgendaEventEntity(
              id: 'today-recurring-dose-$index',
              babyId: 'baby-1',
              category: AgendaCategory.medication,
              title: 'Dosis: Hierro',
              description: '2 gotas · Una vez al día',
              startsAt: now.add(Duration(hours: index + 1)),
              sourceRegisterEventId: 'medication-iron',
              syncStatus: AgendaSyncStatus.synced,
            ),
        ],
        remindersEnabled: true,
        isOffline: false,
      ),
    );
    final bloc = AgendaBloc(
      getAgendaOverview: GetAgendaOverview(
        agendaRepository,
        _FakeRegisterRepository(const []),
      ),
      babyId: 'baby-1',
      clock: () => now,
    )..add(const AgendaEvent.started());
    addTearDown(bloc.close);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: AgendaView(
              onRegisterPressed: () {},
              onRegisterHistoryPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dosis: Hierro'), findsOneWidget);
    expect(find.text('Diario · 2x'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'2 ocurrencias agrupadas')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows component skeletons during the initial load', (
    tester,
  ) async {
    final bloc = AgendaBloc(
      getAgendaOverview: GetAgendaOverview(
        _FakeAgendaRepository(
          const AgendaOverviewEntity(
            events: [],
            remindersEnabled: true,
            isOffline: false,
          ),
        ),
        _FakeRegisterRepository(const []),
      ),
      babyId: 'baby-1',
    );
    addTearDown(bloc.close);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(value: bloc, child: const AgendaView()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(BebeSkeleton), findsWidgets);
    expect(
      find.byKey(const ValueKey('agenda-loading-week-picker')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('agenda-loading-filters')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('agenda-loading-today')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('agenda-loading-upcoming')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('agenda-loading-monthly')),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the agenda visible when there are no events', (
    tester,
  ) async {
    final bloc = AgendaBloc(
      getAgendaOverview: GetAgendaOverview(
        _FakeAgendaRepository(
          const AgendaOverviewEntity(
            events: [],
            remindersEnabled: true,
            isOffline: false,
          ),
        ),
        _FakeRegisterRepository(const []),
      ),
      babyId: 'baby-1',
      clock: () => DateTime(2026, 8, 10, 10),
    )..add(const AgendaEvent.started());
    addTearDown(bloc.close);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(value: bloc, child: const AgendaView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BebeAgendaWeekPicker), findsOneWidget);
    expect(find.text('Programado'), findsOneWidget);
    expect(find.text('Registros del día'), findsOneWidget);
    expect(find.text('Próximos días'), findsOneWidget);
    expect(find.text('Tu agenda está vacía'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test(
    'opening and refreshing Agenda never creates a sync feedback loop',
    () async {
      final syncService = _FakeAgendaSyncService();
      final bloc = AgendaBloc(
        getAgendaOverview: GetAgendaOverview(
          _FakeAgendaRepository(
            const AgendaOverviewEntity(
              events: [],
              remindersEnabled: true,
              isOffline: false,
            ),
          ),
          _FakeRegisterRepository(const []),
        ),
        syncService: syncService,
        babyId: 'baby-1',
      );
      addTearDown(() async {
        await bloc.close();
        await syncService.close();
      });

      final opened = bloc.stream.firstWhere((state) => state is AgendaEmpty);
      bloc.add(const AgendaEvent.started());
      await opened.timeout(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(syncService.synchronizeCalls, 1);
      expect(bloc.state, isA<AgendaEmpty>());

      await bloc.refreshFromRemote().timeout(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(syncService.synchronizeCalls, 2);
      expect(bloc.state, isA<AgendaEmpty>());
    },
  );
}

class _FakeAgendaSyncService implements AgendaEventSyncService {
  final _states = StreamController<RegisterSyncState>.broadcast();
  RegisterSyncState _state = const RegisterSyncState.idle();
  int synchronizeCalls = 0;

  @override
  RegisterSyncState get state => _state;

  @override
  Stream<RegisterSyncState> get states => _states.stream;

  @override
  Future<RegisterSyncState> synchronize() async {
    synchronizeCalls += 1;
    _emit(const RegisterSyncState(phase: RegisterSyncPhase.syncing));
    await Future<void>.delayed(Duration.zero);
    return _emit(
      RegisterSyncState(
        phase: RegisterSyncPhase.synced,
        lastSyncedAt: DateTime.utc(2026, 8, 11),
      ),
    );
  }

  RegisterSyncState _emit(RegisterSyncState state) {
    _state = state;
    _states.add(state);
    return state;
  }

  @override
  Future<void> close() => _states.close();
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
