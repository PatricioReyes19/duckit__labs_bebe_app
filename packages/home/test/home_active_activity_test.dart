import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home/home.dart';
import 'package:home/models/home_overview_vm.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThemeData theme;
  final now = DateTime(2026, 8, 16, 12);

  setUpAll(() {
    final file = [
      File('../design_system/assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ].firstWhere((candidate) => candidate.existsSync());
    theme = BebeTheme.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    ).lightTheme();
  });

  testWidgets('WT-HOME-ACT-001 Home shows an active activity', (tester) async {
    final bloc = _MockHomeBloc();
    final state = HomeState.loaded(overview: _overview(now: now));
    whenListen(bloc, const Stream<HomeState>.empty(), initialState: state);

    await tester.pumpWidget(_app(theme, bloc, now));

    expect(
        find.byKey(const ValueKey('home-active-activities')), findsOneWidget);
    expect(find.text('ACTIVIDAD EN CURSO'), findsOneWidget);
    expect(find.text('Sueño en curso'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('home-active-sleep-1')),
        matching: find.textContaining('36 h'),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('WT-HOME-ACT-002 Home hides the section without active records', (
    tester,
  ) async {
    final bloc = _MockHomeBloc();
    final state = HomeState.loaded(
      overview: _overview(now: now, includeActive: false),
    );
    whenListen(bloc, const Stream<HomeState>.empty(), initialState: state);

    await tester.pumpWidget(_app(theme, bloc, now));

    expect(find.byKey(const ValueKey('home-active-activities')), findsNothing);
  });

  testWidgets('WT-HOME-ACT-003 finish button invokes the Home action', (
    tester,
  ) async {
    final bloc = _MockHomeBloc();
    final state = HomeState.loaded(overview: _overview(now: now));
    whenListen(bloc, const Stream<HomeState>.empty(), initialState: state);
    when(() => bloc.finishActiveActivity('sleep-1'))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(_app(theme, bloc, now));
    await tester.tap(find.byKey(const ValueKey('finish-active-sleep-1')));
    await tester.pumpAndSettle();

    verify(() => bloc.finishActiveActivity('sleep-1')).called(1);
    expect(find.text('Actividad finalizada'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('WT-HOME-ACT-004 loading is not rendered as empty', (
    tester,
  ) async {
    final bloc = _MockHomeBloc();
    whenListen(
      bloc,
      const Stream<HomeState>.empty(),
      initialState: const HomeState.loading(),
    );

    await tester.pumpWidget(_app(theme, bloc, now));

    expect(find.textContaining('Aún no hay registros'), findsNothing);
    expect(find.byType(BebeActiveBabyHeaderSkeleton), findsOneWidget);
  });

  testWidgets('WT-HOME-ACT-005 error offers retry', (tester) async {
    final bloc = _MockHomeBloc();
    whenListen(
      bloc,
      const Stream<HomeState>.empty(),
      initialState: const HomeState.failure(message: 'Sin datos'),
    );

    await tester.pumpWidget(_app(theme, bloc, now));
    await tester.tap(find.text('Reintentar'));

    verify(() => bloc.add(const HomeEvent.retried())).called(1);
  });
}

Widget _app(ThemeData theme, HomeBloc bloc, DateTime now) => MaterialApp(
      theme: theme,
      home: BlocProvider<HomeBloc>.value(
        value: bloc,
        child: Scaffold(
          body: HomeView(
            clock: () => now,
            openRegister: (_, __) {},
            openAgenda: (_) {},
            openHealth: (_) {},
            openTodayHistory: (_) {},
            switchBaby: (_) async {},
          ),
        ),
      ),
    );

HomeOverviewVm _overview({
  required DateTime now,
  bool includeActive = true,
}) =>
    HomeOverviewVm(
      activeBaby: const HomeActiveBabyVm(
        id: 'baby-1',
        name: 'Mateo',
        ageLabel: '6 meses',
        avatarAssetPath: null,
        familyContextLabel: 'Familia Mateo',
      ),
      todayMetrics: const [
        HomeTodayMetricVm(
          type: HomeMetricType.sleep,
          label: 'Sueño',
          value: 'En curso',
          unit: 'ahora',
          lastLabel: 'Última vez',
          lastValue: 'Hace 36 h',
        ),
      ],
      quickActions: const [
        HomeQuickActionVm(
          id: 'sleep',
          type: HomeQuickActionKind.sleep,
          label: 'Sueño',
        ),
      ],
      upcomingHealth: const HomeUpcomingHealthVm(
        title: 'Sin próximos controles',
        dateLabel: 'Agenda al día',
        timeLabel: '--:--',
        caregiverLabel: 'Sin cuidador asignado',
        type: HomeUpcomingHealthKind.control,
      ),
      recentInformation: const HomeRecentInformationVm(
        title: 'Sueño registrado',
        dateLabel: '14 de agosto',
        description: 'El sueño sigue en curso.',
        status: HomeRecentStatus.information,
        statusLabel: 'En curso',
      ),
      visualReminders: const [],
      activeActivities: includeActive
          ? [
              HomeActiveActivityVm(
                id: 'sleep-1',
                kind: HomeActiveActivityKind.sleep,
                title: 'Sueño en curso',
                actionLabel: 'Finalizar sueño',
                startedAt: now.subtract(const Duration(hours: 36)),
              ),
            ]
          : const [],
      hasCareData: true,
    );

class _MockHomeBloc extends MockBloc<HomeEvent, HomeState>
    implements HomeBloc {}
