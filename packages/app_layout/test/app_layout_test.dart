import 'package:app_layout/app_layout.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lightTheme = ThemeData();

  testWidgets('AppHeader muestra la marca HD y el título', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: const Scaffold(appBar: AppHeader(title: 'Inicio')),
      ),
    );

    expect(find.byType(BebeBrandMark), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);

    final brandMark = tester.widget<BebeBrandMark>(find.byType(BebeBrandMark));
    expect(brandMark.variant, BebeBrandMarkVariant.master);
    expect(brandMark.size, 34);
    expect(brandMark.excludeFromSemantics, isTrue);
  });

  testWidgets('AppHeader permite ocultar la marca', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: const Scaffold(
          appBar: AppHeader(title: 'Detalle', showBrandMark: false),
        ),
      ),
    );

    expect(find.byType(BebeBrandMark), findsNothing);
    expect(find.text('Detalle'), findsOneWidget);
  });

  testWidgets('AppHeader delega la navegación hacia atrás', (tester) async {
    var backPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(
          appBar: AppHeader(
            title: 'Detalle',
            showBackButton: true,
            onBackPressed: () => backPressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));

    expect(backPressed, isTrue);
  });
}
