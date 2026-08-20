import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class CoreDataModule {
  @lazySingleton
  BebeDatabase bebeDatabase(GetCurrentSession getCurrentSession) =>
      BebeDatabase(
        scopeProvider: () async => (await getCurrentSession())?.user.id,
      );

  @lazySingleton
  FamilyRemoteDataSource familyRemoteDataSource(SupabaseRestClient client) =>
      SupabaseFamilyRemoteDataSource(client);

  @lazySingleton
  ProfileRemoteDataSource profileRemoteDataSource(SupabaseRestClient client) =>
      SupabaseProfileRemoteDataSource(client);

  @lazySingleton
  SqliteFamilyRepository localFamilyRepository(
    BebeDatabase database,
    FamilyRemoteDataSource remote,
  ) =>
      SqliteFamilyRepository(database, remoteDataSource: remote);

  @lazySingleton
  FamilySyncService familySyncService(
    SqliteFamilyRepository local,
    FamilyRemoteDataSource remote,
  ) =>
      FamilySyncService(local, remote);

  @lazySingleton
  FamilyRepository familyRepository(
    SqliteFamilyRepository local,
    FamilySyncService syncService,
  ) =>
      OfflineFirstFamilyRepository(local, syncService);

  @lazySingleton
  SqliteAgendaRepository localAgendaRepository(BebeDatabase database) =>
      SqliteAgendaRepository(database);

  @lazySingleton
  SqliteHealthRepository localHealthRepository(BebeDatabase database) =>
      SqliteHealthRepository(database);

  @lazySingleton
  HealthEventRemoteDataSource healthEventRemoteDataSource(
    SupabaseRestClient client,
  ) =>
      SupabaseHealthEventRemoteDataSource(client);

  @lazySingleton
  HealthEventSyncService healthEventSyncService(
    SqliteHealthRepository local,
    HealthEventRemoteDataSource remote,
    FamilySyncService familySyncService,
  ) =>
      HealthEventSyncService(
        local,
        remote,
        parentSyncBarrier: familySyncService.ensureSynchronized,
      );

  @lazySingleton
  HealthRepository healthRepository(
    SqliteHealthRepository local,
    HealthEventSyncService syncService,
  ) =>
      OfflineFirstHealthRepository(local, syncService);

  @lazySingleton
  SqliteAppSettingsRepository localAppSettingsRepository(
    BebeDatabase database,
  ) =>
      SqliteAppSettingsRepository(database);

  @lazySingleton
  AppSettingsRemoteDataSource appSettingsRemoteDataSource(
    SupabaseRestClient client,
  ) =>
      SupabaseAppSettingsRemoteDataSource(client);

  @lazySingleton
  AppSettingsSyncService appSettingsSyncService(
    SqliteAppSettingsRepository local,
    AppSettingsRemoteDataSource remote,
  ) =>
      AppSettingsSyncService(local, remote);

  @lazySingleton
  AppSettingsRepository appSettingsRepository(
    SqliteAppSettingsRepository local,
    AppSettingsSyncService syncService,
  ) =>
      OfflineFirstAppSettingsRepository(local, syncService);

  @lazySingleton
  GetFamilyOverview getFamilyOverview(FamilyRepository repository) =>
      GetFamilyOverview(repository);

  @lazySingleton
  SetActiveFamilyBaby setActiveFamilyBaby(FamilyRepository repository) =>
      SetActiveFamilyBaby(repository);

  @lazySingleton
  GetAgendaOverview getAgendaOverview(
    AgendaRepository repository,
    RegisterEventRepository registerRepository,
    AppSettingsRepository settingsRepository,
    HealthRepository healthRepository,
    GetFamilyOverview getFamilyOverview,
  ) =>
      GetAgendaOverview(
        repository,
        registerRepository,
        settingsRepository,
        healthRepository,
        getFamilyOverview,
      );

  @lazySingleton
  GetHealthOverview getHealthOverview(HealthRepository repository) =>
      GetHealthOverview(repository);

  @lazySingleton
  GetAppSettings getAppSettings(AppSettingsRepository repository) =>
      GetAppSettings(repository);

  @lazySingleton
  UpdateAppSettings updateAppSettings(AppSettingsRepository repository) =>
      UpdateAppSettings(repository);

  @lazySingleton
  GetHomeOverview getHomeOverview(
    FamilyRepository familyRepository,
    RegisterEventRepository registerRepository,
    HealthRepository healthRepository,
    AgendaRepository agendaRepository,
    GetActiveRegisterEvents getActiveRegisterEvents,
  ) =>
      GetHomeOverview(
        familyRepository,
        registerRepository,
        healthRepository,
        agendaRepository: agendaRepository,
        getActiveRegisterEvents: getActiveRegisterEvents,
      );
}
