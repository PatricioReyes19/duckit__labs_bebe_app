import '../../entities/settings/app_settings.dart';

abstract interface class AppSettingsRepository {
  Future<AppSettingsEntity> get();

  Future<AppSettingsEntity> update(AppSettingsPatch patch);
}
