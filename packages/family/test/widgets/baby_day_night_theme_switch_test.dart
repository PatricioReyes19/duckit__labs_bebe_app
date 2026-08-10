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

  testWidgets('uses awake and sleeping baby labels and changes mode', (
    tester,
  ) async {
    bool? requestedDark;

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BabyDayNightThemeSwitch(
            isDark: false,
            followsSystem: false,
            onChanged: (value) => requestedDark = value,
            onUseSystem: () {},
          ),
        ),
      ),
    );

    expect(find.text('Despierto'), findsOneWidget);
    expect(find.text('Dormido'), findsOneWidget);
    expect(find.textContaining('pantalla clara'), findsOneWidget);

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();

    expect(requestedDark, isTrue);
  });
}
