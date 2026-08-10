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
  FamilyRepository familyRepository(BebeDatabase database) =>
      SqliteFamilyRepository(database);

  @lazySingleton
  SqliteAgendaRepository localAgendaRepository(BebeDatabase database) =>
      SqliteAgendaRepository(database);

  @lazySingleton
  HealthRepository healthRepository(BebeDatabase database) =>
      SqliteHealthRepository(database);

  @lazySingleton
  AppSettingsRepository appSettingsRepository(BebeDatabase database) =>
      SqliteAppSettingsRepository(database);

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
  ) =>
      GetAgendaOverview(repository, registerRepository);

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
  ) =>
      GetHomeOverview(
        familyRepository,
        registerRepository,
        healthRepository,
      );
}
