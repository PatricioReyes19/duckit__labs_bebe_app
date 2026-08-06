import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('route query opens medication from the Home action id', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    final router = _router(
      repository: repository,
      initialLocation: '/register?type=medicine',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: bebeTheme.lightTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MedicationRegisterForm), findsOneWidget);
    expect(find.byType(FeedingRegisterForm), findsNothing);
  });

  testWidgets('measurement form saves through the routed use case', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    RegisteredEvent? savedEvent;
    final router = _router(
      repository: repository,
      initialLocation: '/register?type=measurement',
      onSaved: (event) => savedEvent = event,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: bebeTheme.lightTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementRegisterForm), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '5,9');
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -2400),
    );
    await tester.pumpAndSettle();
    final saveButton = find.text('Guardar registro').last;
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(repository.drafts, hasLength(1));
    expect(repository.drafts.single.type, RegisterEventType.measurement);
    expect(repository.drafts.single.details['value'], 5.9);
    expect(savedEvent?.type, RegisterEventType.measurement);
  });
}

GoRouter _router({
  required _MemoryRepository repository,
  required String initialLocation,
  ValueChanged<RegisteredEvent>? onSaved,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      RegisterPage(
        saveRegisterEvent: (_) => SaveRegisterEvent(repository),
        onSaved: (_, event) => onSaved?.call(event),
        onCancel: (_) {},
      ),
    ],
  );
}

class _MemoryRepository implements RegisterEventRepository {
  final drafts = <RegisterEventDraft>[];

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) async {
    drafts.add(draft);
    return RegisteredEvent(
      id: 'event-${drafts.length}',
      babyId: draft.babyId,
      type: draft.type,
      occurredAt: draft.occurredAt,
      createdAt: DateTime.utc(2026, 8, 5),
      details: draft.details,
      notes: draft.notes,
      caregiverId: draft.caregiverId,
      schemaVersion: draft.schemaVersion,
    );
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<RegisteredEvent?> findById(String id) async => null;

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async =>
      const [];
}
