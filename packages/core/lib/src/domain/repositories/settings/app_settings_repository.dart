import '../../entities/settings/app_settings.dart';

abstract interface class AppSettingsRepository {
  Stream<void> get changes;

  Future<AppSettingsEntity> get();

  Future<AppSettingsEntity> update(AppSettingsPatch patch);
}
