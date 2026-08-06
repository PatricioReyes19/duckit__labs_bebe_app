import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BebeTheme bebeTheme;

  setUpAll(() {
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

    expect(find.byType(ListView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'today summary becomes scrollable when width or text requires it',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          theme: bebeTheme.lightTheme(),
          textScaler: const TextScaler.linear(2),
          child: const SizedBox(
            width: 342,
            child: BebeTodaySummary(title: 'Resumen de hoy', items: _metrics),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
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
