import 'package:agenda/agenda.dart';
import 'package:app_layout/app_layout.dart';
import 'package:family/family.dart';
import 'package:health/health.dart';
import 'package:home/home.dart';
import 'package:injectable/injectable.dart';

@module
abstract class BlocsModule {
  //============================================================================
  // App Layout
  //============================================================================

  AppLayoutBloc appLayoutBloc() {
    return AppLayoutBloc();
  }

  //============================================================================
  // Home
  //============================================================================

  HomeBloc homeBloc(
    LoadHomeOverview loadHomeOverview,
  ) {
    return HomeBloc(
      loadHomeOverview: loadHomeOverview,
    );
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
