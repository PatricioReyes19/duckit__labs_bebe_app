import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BebeTheme bebeTheme;

  setUpAll(() async {
    await initializeDateFormatting('es_CL');
    final candidates = [
      File('assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ];
    final file = candidates.firstWhere((candidate) => candidate.existsSync());
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    bebeTheme = BebeTheme.fromJson(json);
  });

  test('adaptive grid resolves one, two and three columns consistently', () {
    expect(
      BebeAdaptiveGrid.resolveMetrics(
        availableWidth: 300,
        itemCount: 3,
        minimumItemWidth: 152,
        maximumColumnCount: 3,
        horizontalGap: 8,
      ).columns,
      1,
    );
    expect(
      BebeAdaptiveGrid.resolveMetrics(
        availableWidth: 320,
        itemCount: 3,
        minimumItemWidth: 152,
        maximumColumnCount: 3,
        horizontalGap: 8,
      ).columns,
      2,
    );
    expect(
      BebeAdaptiveGrid.resolveMetrics(
        availableWidth: 768,
        itemCount: 4,
        minimumItemWidth: 168,
        maximumColumnCount: 3,
        horizontalGap: 12,
      ).columns,
      3,
    );
  });

  testWidgets('responsive content caps wide layouts', (tester) async {
    const childKey = Key('responsive-child');
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: const SizedBox(
          width: 1200,
          child: BebeResponsiveContent(
            maxWidth: 720,
            child: SizedBox(key: childKey, height: 24),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(childKey)).width, 720);
  });

  testWidgets('today summary stays inline on reference mobile width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: const SizedBox(
          width: 342,
          child: BebeTodaySummary(title: 'Resumen de hoy', items: _metrics),
        ),
      ),
    );

    final horizontalScroll = find.descendant(
      of: find.byType(BebeTodaySummary),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      ),
    );
    expect(horizontalScroll, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'today metric cards keep equal height after an empty metric is populated',
    (tester) async {
      Future<List<double>> render(List<BebeTodayMetricData> metrics) async {
        await tester.pumpWidget(
          _TestApp(
            theme: bebeTheme.lightTheme(),
            child: SizedBox(
              width: 342,
              child: BebeTodaySummary(title: 'Resumen de hoy', items: metrics),
            ),
          ),
        );
        await tester.pump();
        return tester
            .widgetList<BebeCompactMetricCard>(
              find.byType(BebeCompactMetricCard),
            )
            .map((card) => tester.getSize(find.byWidget(card)).height)
            .toList(growable: false);
      }

      final emptyHeights = await render([
        _metrics[0],
        _metrics[1],
        const BebeTodayMetricData(
          variant: BebeMetricCardVariant.diaper,
          label: 'Pañales',
          value: '—',
          lastLabel: 'Estado',
          lastValue: 'Sin registros hoy',
          icon: Icon(Icons.child_friendly_outlined),
        ),
      ]);
      final populatedHeights = await render(_metrics);

      expect(emptyHeights.toSet(), hasLength(1));
      expect(populatedHeights.toSet(), hasLength(1));
      expect(populatedHeights, emptyHeights);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'week calendar fits seven days at target widths and 1.3 text scale',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in <double>[320, 360, 390, 430]) {
        tester.view.physicalSize = Size(width, 640);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          _TestApp(
            theme: bebeTheme.lightTheme(),
            textScaler: const TextScaler.linear(1.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BebeAgendaWeekPicker(
                firstDay: DateTime(2026),
                lastDay: DateTime(2027),
                focusedDay: DateTime(2026, 8, 17),
                selectedDay: DateTime(2026, 8, 17),
                onDaySelected: (_, _) {},
                onPreviousWeekPressed: () {},
                onNextWeekPressed: () {},
                markersForDay: (_) => const [
                  BebeCalendarMarkerData(id: 'a', color: Colors.red),
                  BebeCalendarMarkerData(id: 'b', color: Colors.blue),
                  BebeCalendarMarkerData(id: 'c', color: Colors.green),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BebeWeekCalendarDay), findsNWidgets(7));
        for (final day in tester.widgetList<BebeWeekCalendarDay>(
          find.byType(BebeWeekCalendarDay),
        )) {
          expect(day.markers, hasLength(3));
        }
        expect(tester.takeException(), isNull, reason: 'width=$width');
      }
    },
  );

  testWidgets(
    'today summary becomes scrollable when width or text requires it',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          theme: bebeTheme.lightTheme(),
          textScaler: const TextScaler.linear(2),
          child: const SingleChildScrollView(
            child: SizedBox(
              width: 342,
              child: BebeTodaySummary(title: 'Resumen de hoy', items: _metrics),
            ),
          ),
        ),
      );

      final scrollViews = tester.widgetList<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(
        scrollViews.any(
          (scrollView) => scrollView.scrollDirection == Axis.horizontal,
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('home carousels use a full-width viewport with scrolling inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const activeHeaderKey = Key('active-header');

    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: Builder(
          builder: (context) {
            final contentPadding = EdgeInsets.symmetric(
              horizontal: context.theme.spacing.spacing2xl,
            );

            return BebeHomeTemplate(
              activeBabyHeader: const SizedBox(key: activeHeaderKey, height: 8),
              todaySummary: BebeTodaySummary(
                title: 'Actividad del día',
                contentPadding: contentPadding,
                items: const [
                  ..._metrics,
                  BebeTodayMetricData(
                    variant: BebeMetricCardVariant.information,
                    label: 'Medición',
                    value: '1',
                    lastLabel: 'Última hace',
                    lastValue: '1 h',
                    icon: Icon(Icons.straighten_outlined),
                  ),
                ],
              ),
              quickActions: BebeQuickRegistrationActions(
                contentPadding: contentPadding,
                items: const [
                  BebeQuickActionData(
                    id: 'feeding',
                    type: BebeQuickActionType.feeding,
                    label: 'Alimentación',
                    icon: Icon(Icons.local_drink_outlined),
                  ),
                  BebeQuickActionData(
                    id: 'sleep',
                    type: BebeQuickActionType.sleep,
                    label: 'Sueño',
                    icon: Icon(Icons.bedtime_outlined),
                  ),
                  BebeQuickActionData(
                    id: 'diaper',
                    type: BebeQuickActionType.diaper,
                    label: 'Pañal',
                    icon: Icon(Icons.child_friendly_outlined),
                  ),
                  BebeQuickActionData(
                    id: 'observation',
                    type: BebeQuickActionType.observation,
                    label: 'Observación',
                    icon: Icon(Icons.edit_outlined),
                  ),
                  BebeQuickActionData(
                    id: 'medicine',
                    type: BebeQuickActionType.medicine,
                    label: 'Medicina',
                    icon: Icon(Icons.medication_outlined),
                  ),
                  BebeQuickActionData(
                    id: 'measurement',
                    type: BebeQuickActionType.measurement,
                    label: 'Medición',
                    icon: Icon(Icons.straighten_outlined),
                  ),
                ],
                onItemPressed: (_) {},
              ),
              upcomingHealth: const SizedBox(height: 8),
              recentInformation: const SizedBox(height: 8),
            );
          },
        ),
      ),
    );

    final today = find.byType(BebeTodaySummary);
    final quickActions = find.byType(BebeQuickRegistrationActions);
    final horizontalScroll = find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    final todayScroll = find.descendant(of: today, matching: horizontalScroll);
    final quickActionsScroll = find.descendant(
      of: quickActions,
      matching: horizontalScroll,
    );
    final firstMetric = find
        .descendant(of: today, matching: find.byType(BebeCompactMetricCard))
        .first;
    final firstAction = find
        .descendant(
          of: quickActions,
          matching: find.byType(BebeCategoryActionTile),
        )
        .first;
    final gutter = tester
        .element(find.byKey(activeHeaderKey))
        .theme
        .spacing
        .spacing2xl;

    expect(tester.getSize(todayScroll).width, 390);
    expect(tester.getSize(quickActionsScroll).width, 390);
    expect(tester.getTopLeft(find.byKey(activeHeaderKey)).dx, gutter);
    expect(tester.getSize(find.byKey(activeHeaderKey)).width, 390 - gutter * 2);
    expect(
      tester.getTopLeft(firstMetric).dx - tester.getTopLeft(todayScroll).dx,
      gutter,
    );
    expect(
      tester.getTopLeft(firstAction).dx -
          tester.getTopLeft(quickActionsScroll).dx,
      gutter,
    );

    final todayViewportLeft = tester.getTopLeft(todayScroll).dx;
    await tester.drag(todayScroll, const Offset(-220, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(firstMetric).dx, lessThan(todayViewportLeft));

    final actionsViewportLeft = tester.getTopLeft(quickActionsScroll).dx;
    await tester.drag(quickActionsScroll, const Offset(-220, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(firstAction).dx, lessThan(actionsViewportLeft));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home loading composes component-owned skeletons', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: const BebeHomeTemplate(
          isLoading: true,
          activeBabyHeader: SizedBox.shrink(),
          todaySummary: SizedBox.shrink(),
          quickActions: SizedBox.shrink(),
          upcomingHealth: SizedBox.shrink(),
          recentInformation: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.byType(BebeActiveBabyHeaderSkeleton), findsOneWidget);
    expect(find.byType(BebeTodaySummarySkeleton), findsOneWidget);
    expect(find.byType(BebeQuickRegistrationActionsSkeleton), findsOneWidget);
    expect(find.byType(BebeUpcomingHealthSectionSkeleton), findsOneWidget);
    expect(find.byType(BebeRecentInformationSectionSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

const _metrics = <BebeTodayMetricData>[
  BebeTodayMetricData(
    variant: BebeMetricCardVariant.feeding,
    label: 'Alimentación',
    value: '5',
    lastLabel: 'Última hace',
    lastValue: '2 h 10 min',
    icon: Icon(Icons.local_drink_outlined),
  ),
  BebeTodayMetricData(
    variant: BebeMetricCardVariant.sleep,
    label: 'Sueño',
    value: '3 h',
    lastLabel: 'Último hoy',
    lastValue: '07:30',
    icon: Icon(Icons.bedtime_outlined),
  ),
  BebeTodayMetricData(
    variant: BebeMetricCardVariant.diaper,
    label: 'Pañales',
    value: '6',
    lastLabel: 'Último hace',
    lastValue: '45 min',
    icon: Icon(Icons.child_friendly_outlined),
  ),
];

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.theme,
    required this.child,
    this.textScaler = TextScaler.noScaling,
  });

  final ThemeData theme;
  final Widget child;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Scaffold(
          body: Align(alignment: Alignment.topCenter, child: child),
        ),
      ),
    );
  }
}
