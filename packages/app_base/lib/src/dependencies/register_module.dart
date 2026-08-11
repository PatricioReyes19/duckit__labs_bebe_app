import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseConfiguration supabaseConfiguration() =>
      SupabaseConfiguration.fromEnvironment;

  @lazySingleton
  AccessTokenProvider accessTokenProvider(SessionRepository repository) =>
      CallbackAccessTokenProvider(
        ({required bool forceRefresh}) =>
            repository.getIdToken(forceRefresh: forceRefresh),
      );

  @lazySingleton
  SupabaseRestClient supabaseRestClient(
    SupabaseConfiguration configuration,
    AccessTokenProvider tokenProvider,
  ) =>
      SupabaseRestClient(configuration, tokenProvider);

  @lazySingleton
  PushDeviceRepository pushDeviceRepository(SupabaseRestClient client) =>
      SupabasePushDeviceRepository(client);

  @lazySingleton
  ActivityNotificationRemoteDataSource activityNotificationRemoteDataSource(
    SupabaseRestClient client,
  ) =>
      SupabaseActivityNotificationRemoteDataSource(client);

  @lazySingleton
  ActivityNotificationRepository activityNotificationRepository(
    ActivityNotificationRemoteDataSource remote,
  ) =>
      SupabaseActivityNotificationRepository(remote);

  @lazySingleton
  SqliteRegisterEventRepository localRegisterEventRepository(
    BebeDatabase database,
  ) =>
      SqliteRegisterEventRepository(database: database);

  @lazySingleton
  RegisterEventRemoteDataSource registerEventRemoteDataSource(
    SupabaseRestClient client,
  ) =>
      SupabaseRegisterEventRemoteDataSource(client);

  @lazySingleton
  RegisterEventSyncService registerEventSyncService(
    SqliteRegisterEventRepository local,
    RegisterEventRemoteDataSource remote,
  ) =>
      RegisterEventSyncService(local, remote);

  @lazySingleton
  AgendaEventRemoteDataSource agendaEventRemoteDataSource(
    SupabaseRestClient client,
  ) =>
      SupabaseAgendaEventRemoteDataSource(client);

  @lazySingleton
  AgendaEventSyncService agendaEventSyncService(
    SqliteAgendaRepository local,
    AgendaEventRemoteDataSource remote,
  ) =>
      AgendaEventSyncService(local, remote);

  @lazySingleton
  SupabaseRealtimeSyncCoordinator realtimeSyncCoordinator(
    SupabaseConfiguration configuration,
    SessionRepository sessionRepository,
    RegisterEventSyncService registerSyncService,
    AgendaEventSyncService agendaSyncService,
    HealthEventSyncService healthSyncService,
    AppSettingsSyncService appSettingsSyncService,
    FamilySyncService familySyncService,
  ) =>
      SupabaseRealtimeSyncCoordinator(
        configuration,
        sessionRepository,
        registerSyncService,
        agendaSyncService,
        healthSyncService: healthSyncService,
        appSettingsSyncService: appSettingsSyncService,
        familySyncService: familySyncService,
      );

  @lazySingleton
  AgendaRepository agendaRepository(
    SqliteAgendaRepository local,
    AgendaEventSyncService syncService,
  ) =>
      OfflineFirstAgendaRepository(local, syncService);

  @lazySingleton
  RegisterAgendaCoordinator registerAgendaCoordinator(
    SqliteRegisterEventRepository registerRepository,
    SqliteAgendaRepository agendaRepository,
    AgendaEventSyncService syncService,
  ) =>
      RegisterAgendaCoordinator(
        registerRepository,
        agendaRepository,
        syncService,
      );

  @lazySingleton
  RegisterEventRepository registerEventRepository(
    SqliteRegisterEventRepository local,
    RegisterEventSyncService syncService,
  ) =>
      OfflineFirstRegisterEventRepository(local, syncService);

  @lazySingleton
  SaveRegisterEvent saveRegisterEvent(RegisterEventRepository repository) {
    return SaveRegisterEvent(repository);
  }

  @lazySingleton
  GetRegisterEvents getRegisterEvents(RegisterEventRepository repository) {
    return GetRegisterEvents(repository);
  }

  @lazySingleton
  DeleteRegisterEvent deleteRegisterEvent(
    RegisterEventRepository repository,
  ) {
    return DeleteRegisterEvent(repository);
  }

  @lazySingleton
  UpdateRegisterEvent updateRegisterEvent(RegisterEventRepository repository) {
    return UpdateRegisterEvent(repository);
  }

  @lazySingleton
  CreateAgendaEvent createAgendaEvent(AgendaRepository repository) =>
      CreateAgendaEvent(repository);

  @lazySingleton
  UpdateAgendaEvent updateAgendaEvent(AgendaRepository repository) =>
      UpdateAgendaEvent(repository);
}
