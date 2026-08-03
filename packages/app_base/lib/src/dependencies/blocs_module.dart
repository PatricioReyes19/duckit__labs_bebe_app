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
    return SharedPreferencesThemeStorage(
      preferences: preferences,
    );
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
  // Home
  //============================================================================

  HomeBloc homeBloc() {
    return HomeBloc();
  }

  //============================================================================
  // Agenda
  //============================================================================

  AgendaBloc agendaBloc() {
    return AgendaBloc();
  }

  //============================================================================
  // Health
  //============================================================================

  HealthBloc healthBloc() {
    return HealthBloc();
  }

  //============================================================================
  // Family
  //============================================================================

  FamilyBloc familyBloc() {
    return FamilyBloc();
  }

  //============================================================================
  // Settings
  //============================================================================

  SettingsBloc settingsBloc() {
    return SettingsBloc();
  }
}
