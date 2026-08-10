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

  HomeBloc homeBloc(GetHomeOverview getHomeOverview) {
    return HomeBloc(getHomeOverview: getHomeOverview);
  }

  //============================================================================
  // Agenda
  //============================================================================

  AgendaBloc agendaBloc(
    GetAgendaOverview getAgendaOverview,
    GetFamilyOverview getFamilyOverview,
    AgendaEventSyncService syncService,
  ) {
    return AgendaBloc(
      getAgendaOverview: getAgendaOverview,
      getFamilyOverview: getFamilyOverview,
      syncService: syncService,
    );
  }

  //============================================================================
  // Health
  //============================================================================

  HealthBloc healthBloc(
    GetHealthOverview getHealthOverview,
    GetFamilyOverview getFamilyOverview,
  ) {
    return HealthBloc(
      getHealthOverview: getHealthOverview,
      getFamilyOverview: getFamilyOverview,
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
