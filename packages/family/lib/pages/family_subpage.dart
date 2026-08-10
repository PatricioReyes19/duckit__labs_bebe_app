import 'package:family/family.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum FamilySubpageKind {
  babySelector,
  addBaby,
  babyDetail,
  careCircle,
  inviteCaregiver,
  memberDetail,
  familyConfiguration,
}

extension FamilySubpageKindPresentation on FamilySubpageKind {
  String get relativePath => switch (this) {
    FamilySubpageKind.babySelector => 'babies',
    FamilySubpageKind.addBaby => 'babies/new',
    FamilySubpageKind.babyDetail => 'babies/:babyId',
    FamilySubpageKind.careCircle => 'care-circle',
    FamilySubpageKind.inviteCaregiver => 'care-circle/invite',
    FamilySubpageKind.memberDetail => 'members/:memberId',
    FamilySubpageKind.familyConfiguration => 'family-configuration',
  };

  String get title => switch (this) {
    FamilySubpageKind.babySelector => 'Seleccionar bebé',
    FamilySubpageKind.addBaby => 'Agregar bebé',
    FamilySubpageKind.babyDetail => 'Perfil del bebé',
    FamilySubpageKind.careCircle => 'Círculo de cuidado',
    FamilySubpageKind.inviteCaregiver => 'Invitar cuidador',
    FamilySubpageKind.memberDetail => 'Detalle del cuidador',
    FamilySubpageKind.familyConfiguration => 'Configuración familiar',
  };
}

class FamilyBabyDraftResult {
  const FamilyBabyDraftResult({required this.name, required this.birthDate});

  final String name;
  final DateTime birthDate;
}

class FamilySubpage extends GoRoute {
  FamilySubpage({required FamilySubpageKind kind, super.routes})
    : super(
        path: kind.relativePath,
        pageBuilder: (context, state) {
          final babyId = state.pathParameters['babyId'];
          final memberId = state.pathParameters['memberId'];
          return CupertinoPage<Object?>(
            key: ValueKey('family-${kind.name}-$babyId-$memberId'),
            name: 'Family${kind.name}',
            child: BlocProvider(
              create: (_) =>
                  FamilyFlowBloc(initialBabyId: babyId ?? 'local-active-baby'),
              child: FamilyFlowView(
                kind: kind,
                babyId: babyId,
                memberId: memberId,
                onClose: () => context.pop(),
                onBabySelected: (id) => context.pop(id),
                onBabyCreated: (draft) => context.pop(draft),
              ),
            ),
          );
        },
      );

  static const babySelectorPath = '/family/babies';
  static const addBabyPath = '/family/babies/new';
  static const careCirclePath = '/family/care-circle';
  static const inviteCaregiverPath = '/family/care-circle/invite';
  static const familyConfigurationPath = '/family/family-configuration';

  static String babyDetailPath(String babyId) =>
      '/family/babies/${Uri.encodeComponent(babyId)}';

  static String memberDetailPath(String memberId) =>
      '/family/members/${Uri.encodeComponent(memberId)}';
}
