import 'dart:async';
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

  testWidgets('tabs switch in place without rebuilding the register page', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    final getFamilyOverview = GetFamilyOverview(
      _FamilyRepository(_familyOverview()),
    );
    final router = _router(
      repository: repository,
      initialLocation: RegisterPage.fullPath,
      getFamilyOverview: getFamilyOverview,
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
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      GoRouterState.of(tester.element(observationForm)).uri.path,
      RegisterPage.fullPath,
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

  testWidgets('baby selector reloads forms with the selected baby id', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    final familyRepository =
        _FamilyRepository(_familyOverview(twoBabies: true));
    final router = _router(
      repository: repository,
      initialLocation: RegisterPage.fullPath,
      getFamilyOverview: GetFamilyOverview(familyRepository),
      onBabyPressed: () => familyRepository.switchTo('baby-2'),
    );
    addTearDown(router.dispose);
    addTearDown(familyRepository.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: bebeTheme.lightTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BebeBabySelector));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('register-baby-switch-loading')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('register-active-baby-baby-2')),
      findsOneWidget,
    );
    expect(find.textContaining('Emilia', findRichText: true), findsWidgets);
  });
}

GoRouter _router({
  required _MemoryRepository repository,
  required String initialLocation,
  ValueChanged<RegisteredEvent>? onSaved,
  GetFamilyOverview? getFamilyOverview,
  VoidCallback? onBabyPressed,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      RegisterPage(
        saveRegisterEvent: (_) => SaveRegisterEvent(repository),
        getFamilyOverview:
            getFamilyOverview == null ? null : (_) => getFamilyOverview,
        onSaved: (_, event) => onSaved?.call(event),
        onCancel: (context) {
          if (context.canPop()) {
            context.pop();
          }
        },
        onBabyPressed: onBabyPressed == null ? null : (_) => onBabyPressed(),
      ),
    ],
  );
}

FamilyOverviewEntity _familyOverview({bool twoBabies = false}) {
  final now = DateTime.now();
  final baby = BabyEntity(
    id: 'baby-1',
    familyId: 'family-1',
    name: 'Mateo',
    birthDate: DateTime(now.year, now.month - 2, now.day),
  );
  return FamilyOverviewEntity(
    id: 'family-1',
    name: 'Familia Mateo',
    activeBabyId: baby.id,
    babies: [
      baby,
      if (twoBabies)
        BabyEntity(
          id: 'baby-2',
          familyId: 'family-1',
          name: 'Emilia',
          birthDate: DateTime(now.year, now.month - 4, now.day),
        ),
    ],
    members: const [],
  );
}

class _FamilyRepository extends Fake implements FamilyRepository {
  _FamilyRepository(this.overview);

  FamilyOverviewEntity overview;
  final StreamController<String> _changes = StreamController.broadcast();

  @override
  Stream<String> get activeBabyChanges => _changes.stream;

  @override
  Future<FamilyOverviewEntity> getCurrent() async => overview;

  void switchTo(String babyId) {
    overview = FamilyOverviewEntity(
      id: overview.id,
      name: overview.name,
      activeBabyId: babyId,
      babies: overview.babies,
      members: overview.members,
    );
    _changes.add(babyId);
  }

  Future<void> dispose() => _changes.close();
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
