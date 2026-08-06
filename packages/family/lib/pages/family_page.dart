import 'package:family/family.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

typedef FamilyBlocFactory = FamilyBloc Function(BuildContext context);
typedef FamilyRouteAction = void Function(BuildContext context);

class FamilyPage extends GoRoute {
  FamilyPage({
    required FamilyBlocFactory familyBloc,
    required FamilyRouteAction openSettings,
    super.name,
    super.routes,
  }) : super(
         path: fullPath,
         pageBuilder: (context, state) {
           return CupertinoPage<void>(
             key: const ValueKey('family'),
             name: name ?? nameRoute,
             child: BlocProvider(
               create: (context) =>
                   familyBloc(context)..add(const FamilyEvent.started()),
               child: FamilyView(
                 onFamilySettingsPressed: () => openSettings(context),
               ),
             ),
           );
         },
       );

  static const nameRoute = 'Family';
  static const fullPath = '/family';

  static void open(BuildContext context) => context.go(fullPath);
}
