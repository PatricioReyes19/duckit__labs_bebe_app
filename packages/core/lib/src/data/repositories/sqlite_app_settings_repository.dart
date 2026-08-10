import '../../domain/entities/settings/app_settings.dart';
import '../../domain/repositories/settings/app_settings_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/app_settings_model.dart';

class SqliteAppSettingsRepository implements AppSettingsRepository {
  const SqliteAppSettingsRepository(this._database);

  final BebeDatabase _database;

  @override
  Future<AppSettingsEntity> get() async {
    final database = await _database.database;
    final rows = await database.query(
      BebeDatabaseSchema.appSettings,
      where: 'id = ?',
      whereArgs: ['local'],
      limit: 1,
    );
    if (rows.isEmpty) throw StateError('Local settings are not configured.');
    return AppSettingsModel.fromRow(rows.single).toEntity();
  }

  @override
  Future<AppSettingsEntity> update(AppSettingsPatch patch) async {
    final changes = <String, Object?>{
      if (patch.name != null) 'account_name': patch.name!.trim(),
      if (patch.theme != null) 'theme_mode': patch.theme!.name,
      if (patch.highContrast != null)
        'high_contrast': patch.highContrast! ? 1 : 0,
      if (patch.personalReminders != null)
        'personal_reminders': patch.personalReminders! ? 1 : 0,
      if (patch.familyActivity != null)
        'family_activity': patch.familyActivity! ? 1 : 0,
      if (patch.dailySummary != null)
        'daily_summary': patch.dailySummary! ? 1 : 0,
      if (patch.reduceMotion != null)
        'reduce_motion': patch.reduceMotion! ? 1 : 0,
      if (patch.wifiOnly != null) 'wifi_only': patch.wifiOnly! ? 1 : 0,
      if (patch.language != null) 'language': patch.language,
      if (patch.timeFormat != null) 'time_format': patch.timeFormat,
      if (patch.textSize != null) 'text_size': patch.textSize,
    };
    if (changes.isNotEmpty) {
      final database = await _database.database;
      await database.update(
        BebeDatabaseSchema.appSettings,
        changes,
        where: 'id = ?',
        whereArgs: ['local'],
      );
    }
    return get();
  }
}
