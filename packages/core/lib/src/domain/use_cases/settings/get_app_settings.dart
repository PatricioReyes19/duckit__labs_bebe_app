import '../../entities/settings/app_settings.dart';
import '../../repositories/settings/app_settings_repository.dart';

class GetAppSettings {
  const GetAppSettings(this._repository);

  final AppSettingsRepository _repository;

  Future<AppSettingsEntity> call() => _repository.get();
}
