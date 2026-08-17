import 'package:agenda/agenda.dart';
import 'package:app_layout/app_layout.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:health/health.dart';
import 'package:home/home.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class BlocsModule {
  //============================================================================
  // App Theme
  //============================================================================

  @lazySingleton
  ThemeStorage themeStorage(
    SharedPreferences preferences,
  ) {
    return SharedPreferencesThemeStorage(preferences);
  }

  @lazySingleton
  AppThemeBloc appThemeBloc(
    BebeTheme theme,
    ThemeStorage themeStorage,
    @Named('initialIsDark') bool initialIsDark,
  ) {
    return AppThemeBloc(
      theme,
      isDark: initialIsDark,
      themeStorage: themeStorage,
    );
  }
  //============================================================================
  // App Layout
  //============================================================================

  AppLayoutBloc appLayoutBloc() {
    return AppLayoutBloc();
  }

  //============================================================================
  // Session
  //============================================================================
  @lazySingleton
  SessionBloc sessionBloc(
    ObserveSession observeSession,
    RefreshSession refreshSession,
    SignOutSession signOutSession,
  ) {
    return SessionBloc(
      observeSession: observeSession,
      refreshSession: refreshSession,
      signOutSession: signOutSession,
    );
  }

  //============================================================================
  // Home
  //============================================================================

  HomeBloc homeBloc(
    GetHomeOverview getHomeOverview,
    FinishActiveRegisterEvent finishActiveRegisterEvent,
    RegisterEventSyncService syncService,
    InitialDataSyncCoordinator initialDataSyncCoordinator,
  ) {
    return HomeBloc(
      getHomeOverview: getHomeOverview,
      finishActiveRegisterEvent: finishActiveRegisterEvent,
      syncService: syncService,
      initialDataSyncCoordinator: initialDataSyncCoordinator,
    );
  }

  //============================================================================
  // Agenda
  //============================================================================

  AgendaBloc agendaBloc(
    GetAgendaOverview getAgendaOverview,
    GetFamilyOverview getFamilyOverview,
    AgendaEventSyncService syncService,
    InitialDataSyncCoordinator initialDataSyncCoordinator,
  ) {
    return AgendaBloc(
      getAgendaOverview: getAgendaOverview,
      getFamilyOverview: getFamilyOverview,
      syncService: syncService,
      initialDataSyncCoordinator: initialDataSyncCoordinator,
    );
  }

  //============================================================================
  // Health
  //============================================================================

  HealthBloc healthBloc(
    GetHealthOverview getHealthOverview,
    GetRegisterEvents getRegisterEvents,
    GetFamilyOverview getFamilyOverview,
    InitialDataSyncCoordinator initialDataSyncCoordinator,
  ) {
    return HealthBloc(
      getHealthOverview: getHealthOverview,
      getRegisterEvents: getRegisterEvents,
      getFamilyOverview: getFamilyOverview,
      initialDataSyncCoordinator: initialDataSyncCoordinator,
    );
  }

  //============================================================================
  // Family
  //============================================================================

  FamilyBloc familyBloc(
    GetFamilyOverview getFamilyOverview,
    SetActiveFamilyBaby setActiveFamilyBaby,
  ) {
    return FamilyBloc(
      getFamilyOverview: getFamilyOverview,
      setActiveBaby: setActiveFamilyBaby,
    );
  }

  //============================================================================
  // Settings
  //============================================================================

  SettingsBloc settingsBloc(
    GetAppSettings getAppSettings,
    UpdateAppSettings updateAppSettings,
    GetCurrentSession getCurrentSession,
  ) {
    return SettingsBloc(
      getAppSettings: getAppSettings,
      updateAppSettings: updateAppSettings,
      getCurrentSession: getCurrentSession,
    );
  }
}
