import '../../domain/entities/settings/app_settings.dart';
import '../../domain/repositories/settings/app_settings_repository.dart';
import '../repositories/sqlite_app_settings_repository.dart';
import 'app_settings_sync_service.dart';
import 'background_sync.dart';

class OfflineFirstAppSettingsRepository implements AppSettingsRepository {
  const OfflineFirstAppSettingsRepository(this._local, this._syncService);

  final SqliteAppSettingsRepository _local;
  final AppSettingsSyncService _syncService;

  @override
  Stream<void> get changes => _local.changes;

  @override
  Future<AppSettingsEntity> get() => _local.get();

  @override
  Future<AppSettingsEntity> update(AppSettingsPatch patch) async {
    final updated = await _local.update(patch);
    scheduleBackgroundSync(
      _syncService.synchronize,
      operation: 'Preferences background synchronization',
    );
    return updated;
  }
}
