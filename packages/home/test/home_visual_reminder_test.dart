import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart' hide HomeMetricType;
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home/home.dart';
import 'package:home/models/home_overview_vm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final startsAt = DateTime(2026, 8, 11, 12, 10);
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

  test('visual reminder exists only during the ten minutes before its time',
      () {
    final reminder = HomeVisualReminderVm.fromEntity(
      HomeCareReminderEntity(
        id: 'formula-1',
        type: HomeCareReminderType.feeding,
        startsAt: startsAt,
        title: 'Próxima toma',
        subtype: 'formula',
      ),
    );

    expect(
      HomeVisualReminderVm.activeAt(
          [reminder],
          startsAt.subtract(
            const Duration(minutes: 10, seconds: 1),
          )),
      isNull,
    );
    expect(
      HomeVisualReminderVm.activeAt(
        [reminder],
        startsAt.subtract(const Duration(minutes: 10)),
      ),
      reminder,
    );
    expect(
      HomeVisualReminderVm.activeAt(
        [reminder],
        startsAt.subtract(const Duration(seconds: 1)),
      ),
      reminder,
    );
    expect(HomeVisualReminderVm.activeAt([reminder], startsAt), isNull);
    expect(reminder.title, 'Se aproxima un relleno');
  });

  test('next transition covers appearance and automatic removal', () {
    final reminder = HomeVisualReminderVm.fromEntity(
      HomeCareReminderEntity(
        id: 'diaper-1',
        type: HomeCareReminderType.diaper,
        startsAt: startsAt,
        title: 'Próximo cambio de pañal',
      ),
    );

    expect(
      HomeVisualReminderVm.nextTransitionAt(
        [reminder],
        startsAt.subtract(const Duration(minutes: 15)),
      ),
      startsAt.subtract(const Duration(minutes: 10)),
    );
    expect(
      HomeVisualReminderVm.nextTransitionAt(
        [reminder],
        startsAt.subtract(const Duration(minutes: 5)),
      ),
      startsAt,
    );
  });

  test('medication reminder keeps the medicine name', () {
    final reminder = HomeVisualReminderVm.fromEntity(
      HomeCareReminderEntity(
        id: 'medicine-1',
        type: HomeCareReminderType.medication,
        startsAt: startsAt,
        title: 'Próxima dosis: Vitamina D',
      ),
    );

    expect(reminder.kind, HomeVisualReminderKind.medication);
    expect(reminder.title, 'Se aproxima una medicina');
    expect(reminder.detail, 'Próxima dosis de Vitamina D');
  });

  testWidgets('home shows the reminder and removes it when time is reached', (
    tester,
  ) async {
    var now = startsAt.subtract(const Duration(minutes: 5));
    final reminder = HomeVisualReminderVm.fromEntity(
      HomeCareReminderEntity(
        id: 'formula-visual',
        type: HomeCareReminderType.feeding,
        startsAt: startsAt,
        title: 'Próxima toma',
        subtype: 'formula',
      ),
    );
    final overview = HomeOverviewVm(
      activeBaby: const HomeActiveBabyVm(
        name: 'Mateo',
        ageLabel: '6 meses',
        avatarAssetPath: null,
        familyContextLabel: 'Familia de Mateo',
      ),
      todayMetrics: const [
        HomeTodayMetricVm(
          type: HomeMetricType.feeding,
          label: 'Alimentación',
          value: '1',
          unit: 'toma',
          lastLabel: 'Última vez',
          lastValue: 'Hace 4 h',
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
      visualReminders: [reminder],
      hasCareData: true,
    );
    final state = HomeState.loaded(overview: overview);
    final bloc = _MockHomeBloc();
    whenListen(bloc, const Stream<HomeState>.empty(), initialState: state);
    String? openedRegister;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: BlocProvider<HomeBloc>.value(
          value: bloc,
          child: HomeView(
            clock: () => now,
            openRegister: (_, action) => openedRegister = action,
            openAgenda: (_) {},
            openHealth: (_) {},
            openTodayHistory: (_) {},
            switchBaby: (_) async {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('home-visual-reminder')),
      findsOneWidget,
    );
    expect(find.text('Se aproxima un relleno'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-visual-reminder')));
    expect(openedRegister, 'feeding');

    now = startsAt;
    await tester.pump(const Duration(minutes: 5, milliseconds: 100));
    expect(
      find.byKey(const ValueKey('home-visual-reminder')),
      findsNothing,
    );
  });
}

class _MockHomeBloc extends MockBloc<HomeEvent, HomeState>
    implements HomeBloc {}
