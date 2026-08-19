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
import 'package:notifications/notifications.dart' as _i327;
import 'package:onboarding/onboarding.dart' as _i706;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../startup/startup.dart' as _i663;
import 'blocs_module.dart' as _i513;
import 'config_module.dart' as _i689;
import 'core_data_module.dart' as _i579;
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
    final coreDataModule = _$CoreDataModule();
    gh.factory<_i961.AppLayoutBloc>(() => blocsModule.appLayoutBloc());
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => vendorsModule.sharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i494.SupabaseConfiguration>(
        () => registerModule.supabaseConfiguration());
    gh.lazySingleton<_i662.FirebaseAuthGateway>(
        () => startupModule.firebaseAuthGateway());
    gh.lazySingleton<_i460.SharedPreferencesAsync>(
      () => startupModule.startupPreferences,
      instanceName: 'startupPreferences',
    );
    gh.lazySingleton<_i494.ThemeStorage>(
        () => blocsModule.themeStorage(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i583.GoRouter>(
        () => routerModule.router(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i662.AuthGateway>(
        () => startupModule.authGateway(gh<_i662.FirebaseAuthGateway>()));
    gh.lazySingleton<_i494.SessionRepository>(
        () => startupModule.sessionRepository(gh<_i662.FirebaseAuthGateway>()));
    gh.lazySingleton<_i494.ActiveContextRepository>(() =>
        startupModule.activeContextRepository(gh<_i460.SharedPreferencesAsync>(
            instanceName: 'startupPreferences')));
    await gh.factoryAsync<bool>(
      () => configModule.initialIsDark(gh<_i494.ThemeStorage>()),
      instanceName: 'initialIsDark',
      preResolve: true,
    );
    gh.lazySingleton<_i494.AccessTokenProvider>(() =>
        registerModule.accessTokenProvider(gh<_i494.SessionRepository>()));
    gh.lazySingleton<_i494.ObserveSession>(
        () => startupModule.observeSession(gh<_i494.SessionRepository>()));
    gh.lazySingleton<_i494.GetCurrentSession>(
        () => startupModule.getCurrentSession(gh<_i494.SessionRepository>()));
    gh.lazySingleton<_i494.RefreshSession>(
        () => startupModule.refreshSession(gh<_i494.SessionRepository>()));
    gh.lazySingleton<_i494.SignOutSession>(
        () => startupModule.signOutSession(gh<_i494.SessionRepository>()));
    gh.lazySingleton<_i494.SessionBloc>(() => blocsModule.sessionBloc(
          gh<_i494.ObserveSession>(),
          gh<_i494.RefreshSession>(),
          gh<_i494.SignOutSession>(),
        ));
    gh.lazySingleton<_i1063.AppThemeBloc>(() => blocsModule.appThemeBloc(
          gh<_i1063.BebeTheme>(),
          gh<_i494.ThemeStorage>(),
          gh<bool>(instanceName: 'initialIsDark'),
        ));
    gh.lazySingleton<_i494.BebeDatabase>(
        () => coreDataModule.bebeDatabase(gh<_i494.GetCurrentSession>()));
    gh.lazySingleton<_i494.SqliteAgendaRepository>(
        () => coreDataModule.localAgendaRepository(gh<_i494.BebeDatabase>()));
    gh.lazySingleton<_i494.SqliteHealthRepository>(
        () => coreDataModule.localHealthRepository(gh<_i494.BebeDatabase>()));
    gh.lazySingleton<_i494.SqliteAppSettingsRepository>(() =>
        coreDataModule.localAppSettingsRepository(gh<_i494.BebeDatabase>()));
    gh.lazySingleton<_i494.SqliteRegisterEventRepository>(() =>
        registerModule.localRegisterEventRepository(gh<_i494.BebeDatabase>()));
    gh.lazySingleton<_i494.SupabaseRestClient>(
        () => registerModule.supabaseRestClient(
              gh<_i494.SupabaseConfiguration>(),
              gh<_i494.AccessTokenProvider>(),
            ));
    gh.lazySingleton<_i494.FamilyRemoteDataSource>(() =>
        coreDataModule.familyRemoteDataSource(gh<_i494.SupabaseRestClient>()));
    gh.lazySingleton<_i494.ProfileRemoteDataSource>(() =>
        coreDataModule.profileRemoteDataSource(gh<_i494.SupabaseRestClient>()));
    gh.lazySingleton<_i494.HealthEventRemoteDataSource>(() => coreDataModule
        .healthEventRemoteDataSource(gh<_i494.SupabaseRestClient>()));
    gh.lazySingleton<_i494.AppSettingsRemoteDataSource>(() => coreDataModule
        .appSettingsRemoteDataSource(gh<_i494.SupabaseRestClient>()));
    gh.lazySingleton<_i494.PushDeviceRepository>(() =>
        registerModule.pushDeviceRepository(gh<_i494.SupabaseRestClient>()));
    gh.lazySingleton<_i494.ActivityNotificationRemoteDataSource>(() =>
        registerModule.activityNotificationRemoteDataSource(
            gh<_i494.SupabaseRestClient>()));
    gh.lazySingleton<_i494.RegisterEventRemoteDataSource>(() => registerModule
        .registerEventRemoteDataSource(gh<_i494.SupabaseRestClient>()));
    gh.lazySingleton<_i494.AgendaEventRemoteDataSource>(() => registerModule
        .agendaEventRemoteDataSource(gh<_i494.SupabaseRestClient>()));
    gh.lazySingleton<_i494.SqliteFamilyRepository>(
        () => coreDataModule.localFamilyRepository(
              gh<_i494.BebeDatabase>(),
              gh<_i494.FamilyRemoteDataSource>(),
            ));
    gh.lazySingleton<_i494.ActivityNotificationRepository>(() =>
        registerModule.activityNotificationRepository(
            gh<_i494.ActivityNotificationRemoteDataSource>()));
    gh.lazySingleton<_i494.FamilySyncService>(
        () => coreDataModule.familySyncService(
              gh<_i494.SqliteFamilyRepository>(),
              gh<_i494.FamilyRemoteDataSource>(),
            ));
    gh.lazySingleton<_i494.RegisterEventSyncService>(
        () => registerModule.registerEventSyncService(
              gh<_i494.SqliteRegisterEventRepository>(),
              gh<_i494.RegisterEventRemoteDataSource>(),
              gh<_i494.FamilySyncService>(),
            ));
    gh.lazySingleton<_i494.AppSettingsSyncService>(
        () => coreDataModule.appSettingsSyncService(
              gh<_i494.SqliteAppSettingsRepository>(),
              gh<_i494.AppSettingsRemoteDataSource>(),
            ));
    gh.lazySingleton<_i494.FamilyRepository>(
        () => coreDataModule.familyRepository(
              gh<_i494.SqliteFamilyRepository>(),
              gh<_i494.FamilySyncService>(),
            ));
    gh.lazySingleton<_i494.AgendaEventSyncService>(
        () => registerModule.agendaEventSyncService(
              gh<_i494.SqliteAgendaRepository>(),
              gh<_i494.AgendaEventRemoteDataSource>(),
              gh<_i494.FamilySyncService>(),
            ));
    gh.lazySingleton<_i327.NotificationService>(
        () => startupModule.notificationService(
              gh<_i494.PushDeviceRepository>(),
              gh<_i494.ActivityNotificationRepository>(),
            ));
    gh.lazySingleton<_i494.RegisterAgendaCoordinator>(
        () => registerModule.registerAgendaCoordinator(
              gh<_i494.SqliteRegisterEventRepository>(),
              gh<_i494.SqliteAgendaRepository>(),
              gh<_i494.AgendaEventSyncService>(),
              gh<_i494.SqliteFamilyRepository>(),
            ));
    gh.lazySingleton<_i494.HealthEventSyncService>(
        () => coreDataModule.healthEventSyncService(
              gh<_i494.SqliteHealthRepository>(),
              gh<_i494.HealthEventRemoteDataSource>(),
              gh<_i494.FamilySyncService>(),
            ));
    gh.lazySingleton<_i662.AuthService>(() => startupModule.authService(
          gh<_i662.AuthGateway>(),
          gh<_i327.NotificationService>(),
          gh<_i494.ProfileRemoteDataSource>(),
        ));
    gh.lazySingleton<_i494.InitialDataSyncCoordinator>(
        () => registerModule.initialDataSyncCoordinator(
              gh<_i494.SessionRepository>(),
              gh<_i494.ProfileRemoteDataSource>(),
              gh<_i494.FamilySyncService>(),
              gh<_i494.RegisterEventSyncService>(),
              gh<_i494.AgendaEventSyncService>(),
              gh<_i494.HealthEventSyncService>(),
              gh<_i494.AppSettingsSyncService>(),
              gh<_i494.RegisterAgendaCoordinator>(),
            ));
    gh.lazySingleton<_i494.AgendaRepository>(
        () => registerModule.agendaRepository(
              gh<_i494.SqliteAgendaRepository>(),
              gh<_i494.AgendaEventSyncService>(),
            ));
    gh.lazySingleton<_i494.AppSettingsRepository>(
        () => coreDataModule.appSettingsRepository(
              gh<_i494.SqliteAppSettingsRepository>(),
              gh<_i494.AppSettingsSyncService>(),
            ));
    gh.lazySingleton<_i494.GetAppSettings>(
        () => coreDataModule.getAppSettings(gh<_i494.AppSettingsRepository>()));
    gh.lazySingleton<_i494.UpdateAppSettings>(() =>
        coreDataModule.updateAppSettings(gh<_i494.AppSettingsRepository>()));
    gh.lazySingleton<_i494.RegisterEventRepository>(
        () => registerModule.registerEventRepository(
              gh<_i494.SqliteRegisterEventRepository>(),
              gh<_i494.RegisterEventSyncService>(),
            ));
    gh.lazySingleton<_i494.GetFamilyOverview>(
        () => coreDataModule.getFamilyOverview(gh<_i494.FamilyRepository>()));
    gh.lazySingleton<_i494.SetActiveFamilyBaby>(
        () => coreDataModule.setActiveFamilyBaby(gh<_i494.FamilyRepository>()));
    gh.factory<_i1027.FamilyBloc>(() => blocsModule.familyBloc(
          gh<_i494.GetFamilyOverview>(),
          gh<_i494.SetActiveFamilyBaby>(),
        ));
    gh.lazySingleton<_i494.SupabaseRealtimeSyncCoordinator>(
        () => registerModule.realtimeSyncCoordinator(
              gh<_i494.SupabaseConfiguration>(),
              gh<_i494.SessionRepository>(),
              gh<_i494.InitialDataSyncCoordinator>(),
            ));
    gh.lazySingleton<_i706.OnboardingRepository>(() =>
        startupModule.onboardingRepository(
          gh<_i460.SharedPreferencesAsync>(instanceName: 'startupPreferences'),
          gh<_i662.AuthGateway>(),
          gh<_i494.FamilyRepository>(),
          gh<_i494.SupabaseRestClient>(),
        ));
    gh.lazySingleton<_i663.AuthenticatedStartupCoordinator>(
        () => startupModule.authenticatedStartupCoordinator(
              gh<_i494.GetCurrentSession>(),
              gh<_i494.BebeDatabase>(),
              gh<_i494.InitialDataSyncCoordinator>(),
              gh<_i494.FamilySyncService>(),
              gh<_i494.SqliteFamilyRepository>(),
              gh<_i494.ActiveContextRepository>(),
              gh<_i494.SupabaseRealtimeSyncCoordinator>(),
            ));
    gh.lazySingleton<_i494.CreateAgendaEvent>(
        () => registerModule.createAgendaEvent(gh<_i494.AgendaRepository>()));
    gh.lazySingleton<_i494.UpdateAgendaEvent>(
        () => registerModule.updateAgendaEvent(gh<_i494.AgendaRepository>()));
    gh.lazySingleton<_i494.HealthRepository>(
        () => coreDataModule.healthRepository(
              gh<_i494.SqliteHealthRepository>(),
              gh<_i494.HealthEventSyncService>(),
            ));
    gh.lazySingleton<_i494.ResolveEntryDestination>(
        () => startupModule.resolveEntryDestination(
              gh<_i662.AuthGateway>(),
              gh<_i663.AuthenticatedStartupCoordinator>(),
            ));
    gh.factory<_i1027.SettingsBloc>(() => blocsModule.settingsBloc(
          gh<_i494.GetAppSettings>(),
          gh<_i494.UpdateAppSettings>(),
          gh<_i494.GetCurrentSession>(),
        ));
    gh.lazySingleton<_i494.GetHealthOverview>(
        () => coreDataModule.getHealthOverview(gh<_i494.HealthRepository>()));
    gh.lazySingleton<_i494.SaveRegisterEvent>(() =>
        registerModule.saveRegisterEvent(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.GetRegisterEvents>(() =>
        registerModule.getRegisterEvents(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.DeleteRegisterEvent>(() => registerModule
        .deleteRegisterEvent(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.UpdateRegisterEvent>(() => registerModule
        .updateRegisterEvent(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.GetActiveRegisterEvents>(() => registerModule
        .getActiveRegisterEvents(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.FinishActiveRegisterEvent>(() => registerModule
        .finishActiveRegisterEvent(gh<_i494.RegisterEventRepository>()));
    gh.lazySingleton<_i494.GetAgendaOverview>(
        () => coreDataModule.getAgendaOverview(
              gh<_i494.AgendaRepository>(),
              gh<_i494.RegisterEventRepository>(),
              gh<_i494.AppSettingsRepository>(),
              gh<_i494.HealthRepository>(),
            ));
    gh.lazySingleton<_i494.GetHomeOverview>(
        () => coreDataModule.getHomeOverview(
              gh<_i494.FamilyRepository>(),
              gh<_i494.RegisterEventRepository>(),
              gh<_i494.HealthRepository>(),
              gh<_i494.AgendaRepository>(),
              gh<_i494.GetActiveRegisterEvents>(),
            ));
    gh.factory<_i1024.HomeBloc>(() => blocsModule.homeBloc(
          gh<_i494.GetHomeOverview>(),
          gh<_i494.FinishActiveRegisterEvent>(),
          gh<_i494.RegisterEventSyncService>(),
          gh<_i494.InitialDataSyncCoordinator>(),
        ));
    gh.factory<_i914.AgendaBloc>(() => blocsModule.agendaBloc(
          gh<_i494.GetAgendaOverview>(),
          gh<_i494.GetFamilyOverview>(),
          gh<_i494.AgendaEventSyncService>(),
          gh<_i494.InitialDataSyncCoordinator>(),
        ));
    gh.factory<_i237.HealthBloc>(() => blocsModule.healthBloc(
          gh<_i494.GetHealthOverview>(),
          gh<_i494.GetRegisterEvents>(),
          gh<_i494.GetFamilyOverview>(),
          gh<_i494.InitialDataSyncCoordinator>(),
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

class _$CoreDataModule extends _i579.CoreDataModule {}
