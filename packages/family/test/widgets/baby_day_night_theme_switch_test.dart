import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('shows theme, sun, switch and moon in one row', (tester) async {
    bool? requestedDark;

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BabyDayNightThemeSwitch(
            isDark: false,
            onChanged: (value) => requestedDark = value,
          ),
        ),
      ),
    );

    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.textContaining('Usar tema del sistema'), findsNothing);

    final labelCenter = tester.getCenter(find.text('Tema'));
    final sunCenter = tester.getCenter(find.byIcon(Icons.light_mode_outlined));
    final switchCenter = tester.getCenter(find.byType(Switch));
    final moonCenter = tester.getCenter(find.byIcon(Icons.dark_mode_outlined));

    expect(labelCenter.dx, lessThan(sunCenter.dx));
    expect(sunCenter.dx, lessThan(switchCenter.dx));
    expect(switchCenter.dx, lessThan(moonCenter.dx));

    await tester.tap(find.byKey(const ValueKey('theme-mode-switch')));
    await tester.pump();

    expect(requestedDark, isTrue);
  });
}
