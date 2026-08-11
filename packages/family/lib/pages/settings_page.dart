import 'package:family/family.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

typedef SettingsBlocFactory = SettingsBloc Function(BuildContext context);
typedef SettingsRouteAction = void Function(BuildContext context);
typedef SettingsThemeAction =
    void Function(BuildContext context, BebeThemeModeOption value);

class SettingsPage extends GoRoute {
  SettingsPage({
    required SettingsBlocFactory settingsBloc,
    required SettingsRouteAction openAccount,
    required SettingsRouteAction openAppearance,
    required SettingsRouteAction openLanguage,
    required SettingsRouteAction openTimeFormat,
    required SettingsRouteAction openTextSize,
    required SettingsRouteAction openSecurity,
    required SettingsRouteAction openPrivacy,
    required SettingsRouteAction downloadData,
    required SettingsRouteAction openStorage,
    required SettingsRouteAction openHelpCenter,
    required SettingsRouteAction reportProblem,
    required SettingsRouteAction signOut,
    required SettingsThemeAction changeTheme,
    super.name,
    super.routes,
  }) : super(
         path: relativePath,
         pageBuilder: (context, state) {
           return MaterialPage<void>(
             key: const ValueKey('settings'),
             name: name ?? nameRoute,
             child: BlocProvider(
               create: (context) =>
                   settingsBloc(context)..add(const SettingsEvent.started()),
               child: SettingsView(
                 onAccountPressed: () => openAccount(context),
                 onAppearancePressed: () => openAppearance(context),
                 onLanguagePressed: () => openLanguage(context),
                 onTimeFormatPressed: () => openTimeFormat(context),
                 onTextSizePressed: () => openTextSize(context),
                 onSecurityPressed: () => openSecurity(context),
                 onPrivacyPressed: () => openPrivacy(context),
                 onDownloadDataPressed: () => downloadData(context),
                 onStoragePressed: () => openStorage(context),
                 onHelpCenterPressed: () => openHelpCenter(context),
                 onReportProblemPressed: () => reportProblem(context),
                 onSignOutPressed: () => signOut(context),
                 onThemeChanged: (value) => changeTheme(context, value),
               ),
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
