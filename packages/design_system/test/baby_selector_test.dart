import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeData theme;

  setUpAll(() {
    final candidates = [
      File('assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ];
    final file = candidates.firstWhere((candidate) => candidate.existsSync());
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    theme = BebeTheme.fromJson(data).lightTheme();
  });

  testWidgets('the complete selector surface responds to tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _TestApp(
        theme: theme,
        child: BebeBabySelector(
          name: 'Emilia',
          ageLabel: '4 meses',
          avatar: const CircleAvatar(child: Text('EM')),
          isSelected: true,
          onPressed: () => taps += 1,
        ),
      ),
    );

    await tester.tap(find.byType(BebeBabySelector));
    await tester.pump();

    expect(taps, 1);
    expect(
      find.byKey(const ValueKey('baby-selector-trailing')),
      findsOneWidget,
    );
  });

  testWidgets('loading state animates and prevents repeated changes', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _TestApp(
        theme: theme,
        child: BebeBabySelector(
          name: 'Mateo',
          ageLabel: '8 meses',
          avatar: const CircleAvatar(child: Text('MA')),
          isSelected: false,
          isLoading: true,
          onPressed: () => taps += 1,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('baby-selector-loading')), findsOneWidget);
    await tester.tap(find.byType(BebeBabySelector));
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('long identity copy stays inside a narrow layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        theme: theme,
        textScaler: const TextScaler.linear(1.8),
        child: const SizedBox(
          width: 288,
          child: BebeBabySelector(
            name: 'Josefina MarÃ­a de los Ãngeles',
            ageLabel: '11 meses y 3 semanas',
            contextLabel: 'Familia con varios perfiles de cuidado compartido',
            avatar: CircleAvatar(child: Text('JM')),
            isSelected: true,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

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
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }
}
