import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
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

  Future<void> pumpStatus(
    WidgetTester tester,
    SyncUxState state, {
    VoidCallback? onRetry,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: bebeTheme.lightTheme(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FamilySyncStatusSection(
            state: state,
            onRetry: onRetry,
            clock: () => DateTime.utc(2026, 8, 16, 18),
          ),
        ),
      ),
    ),
  );

  testWidgets('WT-FAMILY-SYNC-001 shows synced and last update', (
    tester,
  ) async {
    await pumpStatus(
      tester,
      SyncUxState(
        status: SyncUxStatus.synced,
        lastSuccessfulSyncAt: DateTime.utc(2026, 8, 16, 17, 58),
      ),
    );

    expect(find.byKey(const Key('family-sync-synced')), findsOneWidget);
    expect(find.text('Sincronizado'), findsOneWidget);
    expect(find.text('Última actualización: hace 2 min'), findsOneWidget);
  });

  testWidgets('WT-FAMILY-SYNC-002 shows syncing', (tester) async {
    await pumpStatus(
      tester,
      const SyncUxState(status: SyncUxStatus.syncing, pendingOperations: 2),
    );

    expect(find.byKey(const Key('family-sync-syncing')), findsOneWidget);
    expect(find.text('Sincronizando'), findsOneWidget);
    expect(find.text('2 cambios pendientes.'), findsOneWidget);
  });

  testWidgets('WT-FAMILY-SYNC-003 shows offline without an alert', (
    tester,
  ) async {
    await pumpStatus(
      tester,
      const SyncUxState(status: SyncUxStatus.offline, pendingOperations: 3),
    );

    expect(find.byKey(const Key('family-sync-offline')), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.textContaining('3 cambios pendientes.'), findsOneWidget);
  });

  testWidgets('WT-FAMILY-SYNC-004 shows pending', (tester) async {
    await pumpStatus(
      tester,
      const SyncUxState(status: SyncUxStatus.pending, pendingOperations: 1),
    );

    expect(find.byKey(const Key('family-sync-pending')), findsOneWidget);
    expect(find.text('Sincronización pendiente'), findsOneWidget);
    expect(find.text('1 cambio pendiente.'), findsOneWidget);
  });

  testWidgets('WT-FAMILY-SYNC-005 shows error and retries', (tester) async {
    var retries = 0;
    await pumpStatus(
      tester,
      const SyncUxState(status: SyncUxStatus.error, pendingOperations: 1),
      onRetry: () => retries += 1,
    );

    expect(find.byKey(const Key('family-sync-error')), findsOneWidget);
    expect(find.text('Error de sincronización'), findsOneWidget);
    expect(
      find.text('Tus cambios siguen guardados en este dispositivo.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();

    expect(retries, 1);
  });
}
