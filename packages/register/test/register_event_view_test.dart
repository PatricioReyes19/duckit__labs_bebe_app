import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:register/register.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BebeTheme bebeTheme;

  setUpAll(() {
    final candidates = [
      File('../design_system/assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ];
    final file = candidates.firstWhere((candidate) => candidate.existsSync());
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    bebeTheme = BebeTheme.fromJson(json);
  });

  testWidgets('renders each public form without business dependencies',
      (tester) async {
    final forms = <Widget>[
      FeedingRegisterForm(onSideChanged: (_) {}, onMoodChanged: (_) {}),
      SleepRegisterForm(onPlaceChanged: (_) {}, onMoodChanged: (_) {}),
      DiaperRegisterForm(
        onAppearanceChanged: (_) {},
        onColorChanged: (_) {},
        onAmountChanged: (_) {},
      ),
      ClinicalObservationRegisterForm(
        onObservationTypeChanged: (_) {},
        onSeverityChanged: (_) {},
        onShareChanged: (_) {},
        onCaregiverChanged: (_) {},
      ),
      MedicationRegisterForm(
        onScheduleChanged: (_) {},
        onCaregiverChanged: (_) {},
      ),
      MeasurementRegisterForm(onSourceChanged: (_) {}),
    ];

    for (final form in forms) {
      await tester.pumpWidget(
        _FormTestApp(theme: bebeTheme.lightTheme(), child: form),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('ongoing sleep asks only for its start time', (tester) async {
    await tester.pumpWidget(
      _FormTestApp(
        theme: bebeTheme.lightTheme(),
        child: const SleepRegisterForm(),
      ),
    );

    expect(find.text('Se durmió ahora'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('sleep-ongoing-guidance')), findsOneWidget);
    expect(find.text('Hora de inicio'), findsOneWidget);
    expect(find.text('Duración'), findsNothing);
    expect(find.text('Hora de despertar'), findsNothing);
    expect(find.text('Estado de ánimo al despertar'), findsNothing);
  });

  testWidgets('past sleep exposes completion information', (tester) async {
    await tester.pumpWidget(
      _FormTestApp(
        theme: bebeTheme.lightTheme(),
        child: const SleepRegisterForm(mode: 'completed'),
      ),
    );

    expect(find.text('Sueño pasado'), findsOneWidget);
    expect(find.text('Duración'), findsOneWidget);
    expect(find.text('Hora de despertar'), findsOneWidget);
    expect(find.text('Estado de ánimo al despertar'), findsOneWidget);
    expect(find.byKey(const ValueKey('sleep-ongoing-guidance')), findsNothing);
  });

  testWidgets('category and actions forward callbacks', (tester) async {
    RegisterEventKind? selected;
    var saved = false;
    var cancelled = false;

    await tester.pumpWidget(
      _RegisterTestApp(
        theme: bebeTheme.lightTheme(),
        child: _feedingView(
          onKindChanged: (value) => selected = value,
          onSavePressed: () => saved = true,
          onCancelPressed: () => cancelled = true,
        ),
      ),
    );

    await tester.drag(
      find.byType(BebeRegisterCategorySelector<RegisterEventKind>),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medición'));
    expect(selected, RegisterEventKind.measurement);

    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -2400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar registro').last);
    await tester.tap(find.text('Cancelar').last);
    expect(saved, isTrue);
    expect(cancelled, isTrue);
  });

  for (final brightness in Brightness.values) {
    for (final width in [320.0, 375.0, 390.0, 430.0, 768.0]) {
      testWidgets(
        'responsive ${brightness.name} at ${width.toInt()} px has no overflow',
        (tester) async {
          tester.view.physicalSize = Size(width, width < 500 ? 932 : 1024);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final theme = brightness == Brightness.light
              ? bebeTheme.lightTheme()
              : bebeTheme.darkTheme();
          await tester.pumpWidget(
            _RegisterTestApp(theme: theme, child: _feedingView()),
          );

          expect(tester.takeException(), isNull);
          expect(find.text('Registrar evento'), findsOneWidget);
        },
      );
    }
  }

  testWidgets('supports 200 percent text scale at narrow width',
      (tester) async {
    tester.view.physicalSize = const Size(320, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _RegisterTestApp(
        theme: bebeTheme.lightTheme(),
        textScaler: const TextScaler.linear(2),
        child: _feedingView(),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Alimentación'), findsOneWidget);
  });

  testWidgets('mood labels with icons stay on one line at narrow width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _FormTestApp(
        theme: bebeTheme.lightTheme(),
        child: FeedingRegisterForm(onMoodChanged: (_) {}),
      ),
    );

    for (final label in const ['Tranquilo', 'Dormido', 'Irritable']) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.maxLines, 1, reason: label);
      expect(text.softWrap, isFalse, reason: label);
      expect(text.overflow, TextOverflow.ellipsis, reason: label);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('category carousel scrolls across the full screen width',
      (tester) async {
    tester.view.physicalSize = const Size(320, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _RegisterTestApp(
        theme: bebeTheme.lightTheme(),
        child: _feedingView(),
      ),
    );

    final carousel = find.descendant(
      of: find.byType(
        BebeRegisterCategorySelector<RegisterEventKind>,
      ),
      matching: find.byType(SingleChildScrollView),
    );
    expect(carousel, findsOneWidget);
    expect(tester.getTopLeft(carousel).dx, 0);
    expect(tester.getSize(carousel).width, 320);

    final scrollView = tester.widget<SingleChildScrollView>(carousel);
    final spacing = tester.element(carousel).theme.spacing;
    expect(
      scrollView.padding,
      EdgeInsets.symmetric(horizontal: spacing.spacingXl),
    );
  });

  testWidgets('exposes page and action semantics', (tester) async {
    await tester.pumpWidget(
      _RegisterTestApp(
        theme: bebeTheme.darkTheme(),
        child: _feedingView(),
      ),
    );

    expect(find.bySemanticsLabel('Registrar evento'), findsWidgets);
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -2400),
    );
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}

RegisterEventView _feedingView({
  ValueChanged<RegisterEventKind>? onKindChanged,
  VoidCallback? onSavePressed,
  VoidCallback? onCancelPressed,
}) {
  return RegisterEventView(
    title: 'Registrar evento',
    selectedKind: RegisterEventKind.feeding,
    onKindChanged: onKindChanged ?? (_) {},
    subcategories: const [
      BebeSegmentedItem(value: 'breast', label: 'Pecho'),
      BebeSegmentedItem(value: 'bottle', label: 'Mamadera'),
      BebeSegmentedItem(value: 'expressed', label: 'Leche extraída'),
      BebeSegmentedItem(value: 'formula', label: 'Fórmula'),
    ],
    selectedSubcategory: 'breast',
    onSubcategoryChanged: (_) {},
    contextTitle: 'Última toma hace 2 h 10 min',
    contextDescription: 'Sugerido cada 2–3 horas',
    form: FeedingRegisterForm(
      onSideChanged: (_) {},
      onStartTimePressed: () {},
      onDurationPressed: () {},
      onEndTimePressed: () {},
      onMoodChanged: (_) {},
    ),
    onBackPressed: () {},
    onNotificationsPressed: () {},
    onBabyPressed: () {},
    onSavePressed: onSavePressed ?? () {},
    onCancelPressed: onCancelPressed ?? () {},
  );
}

class _RegisterTestApp extends StatelessWidget {
  const _RegisterTestApp({
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
        child: child,
      ),
    );
  }
}

class _FormTestApp extends StatelessWidget {
  const _FormTestApp({required this.theme, required this.child});

  final ThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}
