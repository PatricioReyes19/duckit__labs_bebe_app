import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    bebeTheme = BebeTheme.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );
  });

  testWidgets('WT-FAMILY-BABY-001 edits the same baby profile', (tester) async {
    final repository = _FamilyRepository();
    final bloc = FamilyFlowBloc(
      initialBabyId: 'baby-1',
      repository: repository,
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: FamilyFlowView(
              kind: FamilySubpageKind.babyDetail,
              getFamilyOverview: GetFamilyOverview(repository),
              familyRepository: repository,
              babyId: 'baby-1',
              onClose: () {},
              onBabySelected: (_) {},
              onBabyCreated: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar datos'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Mateo'),
      'Mateo Andrés',
    );
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(repository.updatedIds, ['baby-1']);
    expect(repository.overview.activeBaby.id, 'baby-1');
    expect(repository.overview.activeBaby.name, 'Mateo Andrés');
    expect(find.text('Mateo Andrés'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('WT-FAMILY-SKELETON-001 hides data while loading', (
    tester,
  ) async {
    final repository = _FamilyRepository();
    final pending = Completer<FamilyOverviewEntity>();

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          body: FamilyFlowView(
            kind: FamilySubpageKind.babyDetail,
            getFamilyOverview: GetFamilyOverview(
              _PendingFamilyRepository(pending.future),
            ),
            familyRepository: repository,
            babyId: 'baby-1',
            onClose: () {},
            onBabySelected: (_) {},
            onBabyCreated: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('family-flow-skeleton')), findsOneWidget);
    expect(find.text('Mateo'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(repository.overview);
  });
}

class _PendingFamilyRepository extends Fake implements FamilyRepository {
  _PendingFamilyRepository(this.result);

  final Future<FamilyOverviewEntity> result;

  @override
  Future<FamilyOverviewEntity> getCurrent() => result;
}

class _FamilyRepository extends Fake implements FamilyRepository {
  _FamilyRepository()
    : overview = FamilyOverviewEntity(
        id: 'family-1',
        name: 'Familia Mateo',
        activeBabyId: 'baby-1',
        babies: [
          BabyEntity(
            id: 'baby-1',
            familyId: 'family-1',
            name: 'Mateo',
            birthDate: DateTime.utc(2026, 6, 1),
          ),
        ],
        members: const [],
      );

  FamilyOverviewEntity overview;
  final updatedIds = <String>[];

  @override
  Stream<String> get activeBabyChanges => const Stream.empty();

  @override
  Future<FamilyOverviewEntity> getCurrent() async => overview;

  @override
  Future<BabyEntity?> updateBaby(String id, BabyPatch patch) async {
    updatedIds.add(id);
    final current = overview.babies.singleWhere((baby) => baby.id == id);
    final updated = BabyEntity(
      id: current.id,
      familyId: current.familyId,
      name: patch.name ?? current.name,
      birthDate: patch.birthDate ?? current.birthDate,
      avatarAssetPath: patch.avatarAssetPath ?? current.avatarAssetPath,
    );
    overview = FamilyOverviewEntity(
      id: overview.id,
      name: overview.name,
      activeBabyId: overview.activeBabyId,
      babies: [updated],
      members: overview.members,
    );
    return updated;
  }
}
