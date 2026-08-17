import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home/home.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('shows today events, filters and opens the complete detail', (
    tester,
  ) async {
    final now = DateTime.now();
    String? editedEventId;
    final events = [
      RegisteredEvent(
        id: 'today-feeding',
        babyId: 'baby-1',
        type: RegisterEventType.feeding,
        occurredAt: now.subtract(const Duration(minutes: 25)),
        createdAt: now,
        details: const {
          'subtype': 'Lactancia',
          'duration_minutes': 18,
        },
        notes: 'Tomó leche con calma.',
      ),
      RegisteredEvent(
        id: 'yesterday-sleep',
        babyId: 'baby-1',
        type: RegisterEventType.sleep,
        occurredAt: now.subtract(const Duration(days: 1)),
        createdAt: now,
        details: const {'subtype': 'Siesta', 'duration_minutes': 45},
      ),
    ];
    final cubit = HomeDailyHistoryCubit(
      getRegisterEvents:
          GetRegisterEvents(_FakeRegisterEventRepository(events)),
      babyId: 'baby-1',
      clock: () => now,
    )..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: HomeDailyHistoryView(
              babyName: 'Mateo Reyes',
              onRegisterPressed: () {},
              onEditEvent: (event) => editedEventId = event.id,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mateo Reyes'), findsOneWidget);
    expect(find.text('1 registro'), findsOneWidget);
    expect(find.text('Alimentación'), findsWidgets);
    expect(find.text('Sueño'), findsOneWidget);
    expect(find.text('Gestionar'), findsOneWidget);

    await tester.tap(find.text('Sueño'));
    await tester.pumpAndSettle();
    expect(find.text('No hay registros de este tipo'), findsOneWidget);

    await tester.tap(find.text('Todos'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Lactancia'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('Detalle del registro')),
      findsOneWidget,
    );
    expect(find.text('Tomó leche con calma.'), findsOneWidget);
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final sheetHeight = tester
        .getSize(find.byKey(const ValueKey('bebe-bottom-sheet-surface')))
        .height;
    expect(find.byType(BebeBottomSheet), findsOneWidget);
    expect(sheetHeight, lessThanOrEqualTo(screenHeight * .68 + 1));
    expect(sheetHeight, lessThan(screenHeight));
    expect(
      find.byKey(const ValueKey('edit-register-today-feeding')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('delete-register-today-feeding')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('edit-register-today-feeding')),
    );
    await tester.pumpAndSettle();
    expect(editedEventId, 'today-feeding');
    expect(tester.takeException(), isNull);
  });

  testWidgets('deletes a mistaken record after explicit confirmation', (
    tester,
  ) async {
    final now = DateTime.now();
    final repository = _FakeRegisterEventRepository([
      RegisteredEvent(
        id: 'incorrect-sleep',
        babyId: 'baby-1',
        type: RegisterEventType.sleep,
        occurredAt: now.subtract(const Duration(hours: 3)),
        createdAt: now,
        details: const {
          'subtype': 'night',
          'sleep_status': 'completed',
          'duration_minutes': 6000,
        },
      ),
    ]);
    final cubit = HomeDailyHistoryCubit(
      getRegisterEvents: GetRegisterEvents(repository),
      deleteRegisterEvent: DeleteRegisterEvent(repository),
      babyId: 'baby-1',
      clock: () => now,
    )..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: HomeDailyHistoryView(
              babyName: 'Mateo Reyes',
              onRegisterPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('100 h'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('delete-register-incorrect-sleep')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Eliminar registro'), findsWidgets);
    final confirmButton = tester.widget<FilledButton>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Eliminar'),
      ),
    );
    confirmButton.onPressed!();
    await tester.pumpAndSettle();

    expect(repository.deletedId, 'incorrect-sleep');
    expect(find.text('Registro eliminado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty history forwards the register action', (tester) async {
    var registerPressed = false;
    final cubit = HomeDailyHistoryCubit(
      getRegisterEvents: GetRegisterEvents(
        _FakeRegisterEventRepository(const []),
      ),
      babyId: 'baby-1',
    )..load();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: HomeDailyHistoryView(
              babyName: 'Mateo Reyes',
              onRegisterPressed: () => registerPressed = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registrar ahora'));

    expect(registerPressed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ongoing sleep is visible and offers wake registration', (
    tester,
  ) async {
    final now = DateTime.now();
    final event = RegisteredEvent(
      id: 'ongoing-sleep',
      babyId: 'baby-1',
      type: RegisterEventType.sleep,
      occurredAt: now.subtract(const Duration(minutes: 30)),
      createdAt: now,
      details: const {
        'subtype': 'Siesta',
        'sleep_status': 'ongoing',
        'duration_minutes': null,
        'end_at': null,
      },
    );
    final repository = _FakeRegisterEventRepository([event]);
    final cubit = HomeDailyHistoryCubit(
      getRegisterEvents: GetRegisterEvents(repository),
      finishActiveRegisterEvent: FinishActiveRegisterEvent(repository),
      babyId: 'baby-1',
      clock: () => now,
    )..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: HomeDailyHistoryView(
              babyName: 'Mateo Reyes',
              onRegisterPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siesta · En curso'), findsOneWidget);
    await tester.tap(find.text('Siesta · En curso'));
    await tester.pumpAndSettle();

    expect(find.text('En curso'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('finish-sleep-ongoing-sleep')),
      findsOneWidget,
    );
    expect(find.text('Duración'), findsNothing);
    expect(find.text('Hora de despertar'), findsNothing);
  });

  test('finishing sleep patches the original record', () async {
    final startedAt = DateTime(2026, 8, 10, 23, 30);
    final endedAt = DateTime(2026, 8, 11, 1);
    final event = RegisteredEvent(
      id: 'ongoing-sleep',
      babyId: 'baby-1',
      type: RegisterEventType.sleep,
      occurredAt: startedAt,
      createdAt: startedAt,
      details: const {
        'subtype': 'night',
        'sleep_status': 'ongoing',
        'duration_minutes': null,
        'end_at': null,
      },
    );
    final repository = _FakeRegisterEventRepository([event]);
    final cubit = HomeDailyHistoryCubit(
      getRegisterEvents: GetRegisterEvents(repository),
      finishActiveRegisterEvent: FinishActiveRegisterEvent(repository),
      babyId: 'baby-1',
    );
    addTearDown(cubit.close);

    final completed = await cubit.finishSleep(event, endedAt);

    expect(completed, isTrue);
    expect(repository.updatedId, event.id);
    expect(repository.updatedPatch?.details?['sleep_status'], 'completed');
    expect(repository.updatedPatch?.details?['duration_minutes'], 90);
    expect(
      repository.updatedPatch?.details?['end_at'],
      endedAt.toUtc().toIso8601String(),
    );
  });
}

class _FakeRegisterEventRepository implements RegisterEventRepository {
  _FakeRegisterEventRepository(this.events);

  final List<RegisteredEvent> events;
  String? deletedId;
  String? updatedId;
  RegisterEventPatch? updatedPatch;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<void> delete(String id) async {
    deletedId = id;
    events.removeWhere((event) => event.id == id);
  }

  @override
  Future<RegisteredEvent?> findById(String id) async =>
      events.where((event) => event.id == id).firstOrNull;

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async {
    final filtered = type == null
        ? events
        : events.where((event) => event.type == type).toList(growable: false);
    return limit == null || filtered.length <= limit
        ? filtered
        : filtered.take(limit).toList(growable: false);
  }

  @override
  Stream<List<RegisteredEvent>> observeByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async* {
    yield await listByBaby(babyId, type: type, limit: limit);
  }

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<RegisteredEvent?> update(String id, RegisterEventPatch patch) async {
    updatedId = id;
    updatedPatch = patch;
    final current = await findById(id);
    if (current == null) return null;
    return RegisteredEvent(
      id: current.id,
      babyId: current.babyId,
      type: current.type,
      occurredAt: current.occurredAt,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt.add(const Duration(milliseconds: 1)),
      details: {...current.details, ...?patch.details},
      notes: current.notes,
      caregiverId: current.caregiverId,
      syncStatus: RegisterSyncStatus.pending,
      schemaVersion: current.schemaVersion,
    );
  }
}
