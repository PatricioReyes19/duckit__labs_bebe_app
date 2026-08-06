import '../../entities/settings/app_settings.dart';
import '../../repositories/settings/app_settings_repository.dart';

class UpdateAppSettings {
  const UpdateAppSettings(this._repository);

  final AppSettingsRepository _repository;

  Future<AppSettingsEntity> call(AppSettingsPatch patch) =>
      _repository.update(patch);
}
