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

  testWidgets('static variant keeps its fixed height without adding a scroll', (
    tester,
  ) async {
    await _openSheet(
      tester,
      theme: bebeTheme.lightTheme(),
      variant: BebeBottomSheetVariant.staticContent,
      staticHeight: 260,
      body: const Align(
        alignment: Alignment.topLeft,
        child: Text('Contenido estático'),
      ),
    );

    final surface = find.byKey(const ValueKey('bebe-bottom-sheet-surface'));
    expect(tester.getSize(surface).height, 260);
    expect(
      find.byKey(const ValueKey('bebe-bottom-sheet-scroll')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrollable variant caps height and keeps footer fixed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _openSheet(
      tester,
      theme: bebeTheme.lightTheme(),
      variant: BebeBottomSheetVariant.scrollable,
      maximumHeightFactor: .5,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < 30; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Elemento $index'),
            ),
        ],
      ),
      footer: const Text('Acciones fijas', key: ValueKey('fixed-footer')),
    );

    final surface = find.byKey(const ValueKey('bebe-bottom-sheet-surface'));
    final scroll = find.byKey(const ValueKey('bebe-bottom-sheet-scroll'));
    final footer = find.byKey(const ValueKey('fixed-footer'));
    final firstItem = find.text('Elemento 0');
    final initialItemTop = tester.getTopLeft(firstItem).dy;
    final initialFooterTop = tester.getTopLeft(footer).dy;

    expect(tester.getSize(surface).height, 400);
    await tester.drag(scroll, const Offset(0, -240));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(firstItem).dy, lessThan(initialItemTop));
    expect(tester.getTopLeft(footer).dy, initialFooterTop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dynamic variant wraps short content instead of filling screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _openSheet(
      tester,
      theme: bebeTheme.lightTheme(),
      variant: BebeBottomSheetVariant.dynamic,
      maximumHeightFactor: .7,
      header: const Text('Detalle'),
      body: const SizedBox(height: 80, child: Text('Contenido breve')),
    );

    final surface = find.byKey(const ValueKey('bebe-bottom-sheet-surface'));
    final height = tester.getSize(surface).height;

    expect(height, greaterThan(80));
    expect(height, lessThan(560));
    expect(find.text('Contenido breve'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openSheet(
  WidgetTester tester, {
  required ThemeData theme,
  required BebeBottomSheetVariant variant,
  required Widget body,
  Widget? header,
  Widget? footer,
  double staticHeight = 320,
  double maximumHeightFactor = .72,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showBebeBottomSheet<void>(
                context: context,
                variant: variant,
                staticHeight: staticHeight,
                maximumHeightFactor: maximumHeightFactor,
                headerBuilder: header == null ? null : (_) => header,
                footerBuilder: footer == null ? null : (_) => footer,
                bodyBuilder: (_) => body,
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}
