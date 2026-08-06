import 'dart:convert';

import 'package:app_layout/app_layout.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ThemeData lightTheme;

  setUpAll(() async {
    final rawTheme = await rootBundle.loadString(
      'packages/design_system/assets/json/bebe_theme.json',
    );
    lightTheme = BebeTheme.fromJson(
      jsonDecode(rawTheme) as Map<String, dynamic>,
    ).lightTheme();
  });

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
}
