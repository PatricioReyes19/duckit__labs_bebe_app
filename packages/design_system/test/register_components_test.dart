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

  testWidgets('BebePickerField exposes semantics and callback', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: BebePickerField(
          label: 'Hora',
          value: '09:30 AM',
          kind: BebePickerFieldKind.time,
          onPressed: () => pressed = true,
        ),
      ),
    );

    expect(find.bySemanticsLabel(RegExp('Hora')), findsWidgets);
    await tester.tap(find.text('09:30 AM'));
    expect(pressed, isTrue);
  });

  testWidgets('BebeSegmentedFormField forwards selection', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: BebeSegmentedFormField<String>(
          label: 'Fuente',
          items: const [
            BebeSegmentedItem(value: 'home', label: 'En casa'),
            BebeSegmentedItem(value: 'clinic', label: 'Consulta'),
          ],
          selectedValue: 'home',
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.text('Consulta'));
    expect(selected, 'clinic');
  });

  testWidgets(
    'register categories use semantic clinical palette in dark mode',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          theme: bebeTheme.darkTheme(),
          child: BebeRegisterCategorySelector<String>(
            items: const [
              BebeRegisterCategoryItem(
                value: 'medication',
                label: 'Medicina',
                icon: Icon(Icons.medication_outlined),
                variant: BebeCategoryActionTileVariant.medication,
              ),
              BebeRegisterCategoryItem(
                value: 'measurement',
                label: 'Medición',
                icon: Icon(Icons.straighten_outlined),
                variant: BebeCategoryActionTileVariant.measurement,
              ),
            ],
            selectedValue: 'medication',
            onChanged: (_) {},
          ),
        ),
      );

      final context = tester.element(find.text('Medicina'));
      expect(context.theme.colors.clinical.medicationSurface, isNotNull);
      expect(find.bySemanticsLabel(RegExp('Medicina')), findsWidgets);
    },
  );

  testWidgets('responsive grid collapses without overflow at 320 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: BebeResponsiveFormGrid(
          children: [
            for (final label in ['Inicio', 'Duración', 'Término'])
              BebePickerField(
                label: label,
                value: '09:30',
                kind: BebePickerFieldKind.time,
                onPressed: () {},
              ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('public register controls meet Android touch targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        theme: bebeTheme.lightTheme(),
        child: BebeRegisterActionBar(
          onSavePressed: () {},
          onCancelPressed: () {},
        ),
      ),
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.theme, required this.child});

  final ThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}
