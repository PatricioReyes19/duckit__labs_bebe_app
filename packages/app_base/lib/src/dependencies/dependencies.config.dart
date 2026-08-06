// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:agenda/agenda.dart' as _i914;
import 'package:app_layout/app_layout.dart' as _i961;
import 'package:auth/auth.dart' as _i662;
import 'package:core/core.dart' as _i494;
import 'package:design_system/design_system.dart' as _i1063;
import 'package:family/family.dart' as _i1027;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:health/health.dart' as _i237;
import 'package:home/home.dart' as _i1024;
import 'package:injectable/injectable.dart' as _i526;
import 'package:onboarding/onboarding.dart' as _i706;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'blocs_module.dart' as _i513;
import 'config_module.dart' as _i689;
import 'register_module.dart' as _i291;
import 'router_module.dart' as _i393;
import 'startup_module.dart' as _i462;
import 'vendors_module.dart' as _i16;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final blocsModule = _$BlocsModule();
    final vendorsModule = _$VendorsModule();
    final registerModule = _$RegisterModule();
    final startupModule = _$StartupModule();
    final routerModule = _$RouterModule();
    final configModule = _$ConfigModule();
    gh.factory<_i961.AppLayoutBloc>(() => blocsModule.appLayoutBloc());
    gh.factory<_i1024.HomeBloc>(() => blocsModule.homeBloc());
    gh.factory<_i914.AgendaBloc>(() => blocsModule.agendaBloc());
    gh.factory<_i237.HealthBloc>(() => blocsModule.healthBloc());
    gh.factory<_i1027.FamilyBloc>(() => blocsModule.familyBloc());
    gh.factory<_i1027.SettingsBloc>(() => blocsModule.settingsBloc());
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => vendorsModule.sharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i494.RegisterEventRepository>(
        () => registerModule.registerEventRepository());
    gh.lazySingleton<_i460.SharedPreferencesAsync>(
      () => startupModule.startupPreferences,
      instanceName: 'startupPreferences',
    );
    gh.lazySingleton<_i494.SaveRegisterEvent>(() =>
        registerModule.saveRegisterEvent(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.GetRegisterEvents>(() =>
        registerModule.getRegisterEvents(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.DeleteRegisterEvent>(() => registerModule
        .deleteRegisterEvent(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.ThemeStorage>(
        () => blocsModule.themeStorage(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i583.GoRouter>(
        () => routerModule.router(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i662.AuthGateway>(() => startupModule.authGateway(
        gh<_i460.SharedPreferencesAsync>(instanceName: 'startupPreferences')));
    gh.lazySingleton<_i706.OnboardingRepository>(() =>
        startupModule.onboardingRepository(gh<_i460.SharedPreferencesAsync>(
            instanceName: 'startupPreferences')));
    gh.lazySingleton<_i662.AuthService>(
        () => startupModule.authService(gh<_i662.AuthGateway>()));
    await gh.factoryAsync<bool>(
      () => configModule.initialIsDark(gh<_i494.ThemeStorage>()),
      instanceName: 'initialIsDark',
      preResolve: true,
    );
    gh.lazySingleton<_i494.ResolveEntryDestination>(
        () => startupModule.resolveEntryDestination(
              gh<_i662.AuthGateway>(),
              gh<_i706.OnboardingRepository>(),
            ));
    gh.lazySingleton<_i1063.AppThemeBloc>(() => blocsModule.appThemeBloc(
          gh<_i1063.BebeTheme>(),
          gh<_i494.ThemeStorage>(),
          gh<bool>(instanceName: 'initialIsDark'),
        ));
    return this;
  }
}

class _$BlocsModule extends _i513.BlocsModule {}

class _$VendorsModule extends _i16.VendorsModule {}

class _$RegisterModule extends _i291.RegisterModule {}

class _$StartupModule extends _i462.StartupModule {}

class _$RouterModule extends _i393.RouterModule {}

class _$ConfigModule extends _i689.ConfigModule {}
