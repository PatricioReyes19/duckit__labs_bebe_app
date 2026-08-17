import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home/home.dart';
import 'package:home/models/home_overview_vm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThemeData theme;

  setUpAll(() {
    final file = [
      File('../design_system/assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ].firstWhere((candidate) => candidate.existsSync());
    theme = BebeTheme.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    ).lightTheme();
  });

  testWidgets(
    'baby selector is tappable, shows loading and replaces visible data',
    (tester) async {
      final first = _babyOverview(
        id: 'baby-emilia',
        name: 'Emilia',
        siblingId: 'baby-mateo',
        siblingName: 'Mateo',
        feedingCount: '1',
      );
      final second = _babyOverview(
        id: 'baby-mateo',
        name: 'Mateo',
        siblingId: 'baby-emilia',
        siblingName: 'Emilia',
        feedingCount: '7',
      );
      final states = StreamController<HomeState>.broadcast();
      addTearDown(states.close);
      final bloc = _MockHomeBloc();
      whenListen(
        bloc,
        states.stream,
        initialState: HomeState.loaded(overview: first),
      );
      final switchCompleted = Completer<void>();
      String? requestedBabyId;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: BlocProvider<HomeBloc>.value(
            value: bloc,
            child: HomeView(
              openRegister: (_, __) {},
              openAgenda: (_) {},
              openHealth: (_) {},
              openTodayHistory: (_, __) {},
              switchBaby: (babyId) {
                requestedBabyId = babyId;
                return switchCompleted.future;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BebeBabySelector));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('home-baby-choice-baby-mateo')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('home-baby-choice-baby-mateo')),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(requestedBabyId, 'baby-mateo');
      expect(
        find.byKey(const ValueKey('baby-selector-loading')),
        findsOneWidget,
      );

      states.add(HomeState.loaded(overview: second));
      await tester.pump();
      switchCompleted.complete();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('Mateo', findRichText: true), findsWidgets);
      expect(find.text('7'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('baby-selector-loading')),
        findsNothing,
      );
    },
  );
}

HomeOverviewVm _babyOverview({
  required String id,
  required String name,
  required String siblingId,
  required String siblingName,
  required String feedingCount,
}) {
  return HomeOverviewVm(
    activeBaby: HomeActiveBabyVm(
      id: id,
      name: name,
      ageLabel: '6 meses',
      avatarAssetPath: null,
      familyContextLabel: 'Familia Reyes',
      siblings: [
        HomeSiblingVm(
          id: siblingId,
          name: siblingName,
          ageLabel: '8 meses',
          avatarAssetPath: null,
        ),
      ],
    ),
    todayMetrics: [
      HomeTodayMetricVm(
        type: HomeMetricType.feeding,
        label: 'Alimentación',
        value: feedingCount,
        unit: 'tomas',
        lastLabel: 'Última vez',
        lastValue: 'Hace 1 h',
      ),
    ],
    quickActions: const [
      HomeQuickActionVm(
        id: 'feeding',
        type: HomeQuickActionKind.feeding,
        label: 'Alimentación',
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
      title: 'Sin actividad reciente',
      dateLabel: 'Hoy',
      description: 'Sin registros',
      status: HomeRecentStatus.information,
      statusLabel: 'Sin registros',
    ),
    visualReminders: const [],
    hasCareData: true,
  );
}

class _MockHomeBloc extends MockBloc<HomeEvent, HomeState>
    implements HomeBloc {}
