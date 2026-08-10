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
}

class _FakeRegisterEventRepository implements RegisterEventRepository {
  const _FakeRegisterEventRepository(this.events);

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
  Future<RegisteredEvent?> update(String id, RegisterEventPatch patch) async =>
      null;
}
