import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

typedef FamilyBlocFactory = FamilyBloc Function(BuildContext context);
typedef FamilyRouteAction = void Function(BuildContext context);
typedef FamilyMemberRouteAction =
    void Function(BuildContext context, String memberId);
typedef FamilyBabyRouteAction =
    void Function(BuildContext context, String babyId);

class FamilyPage extends GoRoute {
  FamilyPage({
    required FamilyBlocFactory familyBloc,
    required FamilyRouteAction openPersonalSettings,
    required FamilyRouteAction openFamilySettings,
    required FamilyRouteAction openBabySelector,
    required FamilyRouteAction addBaby,
    required FamilyRouteAction manageCareCircle,
    required FamilyRouteAction inviteCaregiver,
    required FamilyMemberRouteAction openMember,
    required FamilyBabyRouteAction openBaby,
    super.name,
    super.routes,
  }) : super(
         path: fullPath,
         pageBuilder: (context, state) {
           return MaterialPage<void>(
             key: const ValueKey('family'),
             name: name ?? nameRoute,
             child: BlocProvider(
               create: (context) =>
                   familyBloc(context)..add(const FamilyEvent.started()),
               child: Builder(
                 builder: (viewContext) => FamilyView(
                   onFamilyContextPressed: () => openBabySelector(viewContext),
                   onAddBabyPressed: () => addBaby(viewContext),
                   onManageCareCirclePressed: () =>
                       manageCareCircle(viewContext),
                   onInviteCaregiverPressed: () => inviteCaregiver(viewContext),
                   onFamilySettingsPressed: () =>
                       openFamilySettings(viewContext),
                   onPersonalSettingsPressed: () =>
                       openPersonalSettings(viewContext),
                   onMemberPressed: (memberId) =>
                       openMember(viewContext, memberId),
                   onBabyPressed: (babyId) => openBaby(viewContext, babyId),
                 ),
               ),
             ),
           );
         },
       );

  static const nameRoute = 'Family';
  static const fullPath = '/family';

  static void open(BuildContext context) => context.go(fullPath);
}
