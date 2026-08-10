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

    expect(
      router.routeInformationProvider.value.uri.path,
      '/register/medication',
    );
    expect(find.byType(MedicationRegisterForm), findsOneWidget);
    expect(find.byType(FeedingRegisterForm), findsNothing);
  });

  testWidgets('observation is a child route and back returns to register', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    final router = _router(
      repository: repository,
      initialLocation: RegisterPage.fullPath,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: bebeTheme.lightTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    final observation = find.byWidgetPredicate(
      (widget) =>
          widget is BebeCategoryActionTile && widget.label == 'Observación',
    );
    await tester.ensureVisible(observation);
    await tester.pumpAndSettle();
    tester.widget<BebeCategoryActionTile>(observation).onPressed!();
    await tester.pumpAndSettle();

    final observationForm = find.byType(ClinicalObservationRegisterForm);
    expect(observationForm, findsOneWidget);
    expect(
      GoRouterState.of(tester.element(observationForm)).uri.path,
      '/register/observation',
    );

    final back = find.byWidgetPredicate(
      (widget) => widget is BebeIconButton && widget.semanticLabel == 'Volver',
    );
    tester.widget<BebeIconButton>(back).onPressed!();
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      RegisterPage.fullPath,
    );
    expect(find.byType(FeedingRegisterForm), findsOneWidget);
    expect(find.byType(ClinicalObservationRegisterForm), findsNothing);
  });

  testWidgets('invalid register child redirects to the register root', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    final router = _router(
      repository: repository,
      initialLocation: '/register/unknown',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: bebeTheme.lightTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      RegisterPage.fullPath,
    );
    expect(find.byType(FeedingRegisterForm), findsOneWidget);
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
        onCancel: (context) {
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
    ],
  );
}

class _MemoryRepository implements RegisterEventRepository {
  final drafts = <RegisterEventDraft>[];

  @override
  Stream<void> get changes => const Stream.empty();

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
  Future<RegisteredEvent?> update(
    String id,
    RegisterEventPatch patch,
  ) async =>
      null;

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async =>
      const [];

  @override
  Stream<List<RegisteredEvent>> observeByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async* {
    yield await listByBaby(babyId, type: type, limit: limit);
  }
}
