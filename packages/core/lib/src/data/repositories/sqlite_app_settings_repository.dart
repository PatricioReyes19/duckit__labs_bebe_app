import 'dart:async';

import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/settings/app_settings.dart';
import '../../domain/repositories/settings/app_settings_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/app_settings_model.dart';

class SqliteAppSettingsRepository implements AppSettingsRepository {
  SqliteAppSettingsRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final BebeDatabase _database;
  final DateTime Function() _clock;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

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
      'updated_at': _clock().toUtc().millisecondsSinceEpoch,
      'sync_status': AppSettingsSyncStatus.pending.name,
      'sync_error': null,
    };
    if (changes.isNotEmpty) {
      final database = await _database.database;
      await database.update(
        BebeDatabaseSchema.appSettings,
        changes,
        where: 'id = ?',
        whereArgs: ['local'],
      );
      if (!_changes.isClosed) _changes.add(null);
    }
    return get();
  }

  Future<AppSettingsSyncRecord?> readSyncRecord() async {
    final database = await _database.database;
    final rows = await database.query(
      BebeDatabaseSchema.appSettings,
      where: 'id = ?',
      whereArgs: ['local'],
      limit: 1,
    );
    return rows.isEmpty ? null : AppSettingsSyncRecord.fromRow(rows.single);
  }

  Future<void> markSyncing(AppSettingsSyncRecord record) =>
      _setSyncStatus(record, AppSettingsSyncStatus.syncing);

  Future<void> markSynced(AppSettingsSyncRecord record) =>
      _setSyncStatus(record, AppSettingsSyncStatus.synced);

  Future<void> markFailed(AppSettingsSyncRecord record, Object error) =>
      _setSyncStatus(
        record,
        AppSettingsSyncStatus.failed,
        error: error.toString(),
      );

  Future<void> _setSyncStatus(
    AppSettingsSyncRecord record,
    AppSettingsSyncStatus status, {
    String? error,
  }) async {
    final database = await _database.database;
    final affected = await database.update(
      BebeDatabaseSchema.appSettings,
      {'sync_status': status.name, 'sync_error': error},
      where: 'id = ? AND updated_at = ?',
      whereArgs: ['local', record.updatedAt.millisecondsSinceEpoch],
    );
    if (affected > 0 && !_changes.isClosed) _changes.add(null);
  }

  Future<void> mergeRemote(AppSettingsSyncRecord remote) async {
    final local = await readSyncRecord();
    if (local != null && local.updatedAt.isAfter(remote.updatedAt)) return;
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.appSettings,
      AppSettingsSyncRecord(
        settings: remote.settings,
        updatedAt: remote.updatedAt,
        syncStatus: AppSettingsSyncStatus.synced,
      ).toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> close() => _changes.close();
}
