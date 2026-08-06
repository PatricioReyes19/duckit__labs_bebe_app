import 'package:family/family.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

typedef SettingsBlocFactory = SettingsBloc Function(BuildContext context);

class SettingsPage extends GoRoute {
  SettingsPage({
    required SettingsBlocFactory settingsBloc,
    super.name,
    super.routes,
  }) : super(
         path: relativePath,
         pageBuilder: (context, state) {
           return CupertinoPage<void>(
             key: const ValueKey('settings'),
             name: name ?? nameRoute,
             child: BlocProvider(
               create: (context) =>
                   settingsBloc(context)..add(const SettingsEvent.started()),
               child: const SettingsView(),
             ),
           );
         },
       );

  static const nameRoute = 'Settings';
  static const relativePath = 'settings';
  static const fullPath = '${FamilyPage.fullPath}/$relativePath';
  static const legacyFullPath = '/settings';

  static void open(BuildContext context) => context.push(fullPath);
}
