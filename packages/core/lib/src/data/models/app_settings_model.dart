import '../../domain/entities/settings/app_settings.dart';

class AppSettingsModel {
  const AppSettingsModel({
    required this.theme,
    required this.highContrast,
    required this.personalReminders,
    required this.familyActivity,
    required this.dailySummary,
    required this.reduceMotion,
    required this.wifiOnly,
    required this.name,
    required this.email,
    required this.language,
    required this.timeFormat,
    required this.textSize,
  });

  final AppThemePreference theme;
  final bool highContrast;
  final bool personalReminders;
  final bool familyActivity;
  final bool dailySummary;
  final bool reduceMotion;
  final bool wifiOnly;
  final String name;
  final String email;
  final String language;
  final String timeFormat;
  final String textSize;

  factory AppSettingsModel.fromEntity(AppSettingsEntity entity) =>
      AppSettingsModel(
        theme: entity.theme,
        highContrast: entity.highContrast,
        personalReminders: entity.personalReminders,
        familyActivity: entity.familyActivity,
        dailySummary: entity.dailySummary,
        reduceMotion: entity.reduceMotion,
        wifiOnly: entity.wifiOnly,
        name: entity.name,
        email: entity.email,
        language: entity.language,
        timeFormat: entity.timeFormat,
        textSize: entity.textSize,
      );

  Map<String, Object?> toRow() => {
    'id': 'local',
    'theme_mode': theme.name,
    'high_contrast': highContrast ? 1 : 0,
    'personal_reminders': personalReminders ? 1 : 0,
    'family_activity': familyActivity ? 1 : 0,
    'daily_summary': dailySummary ? 1 : 0,
    'reduce_motion': reduceMotion ? 1 : 0,
    'wifi_only': wifiOnly ? 1 : 0,
    'account_name': name,
    'account_email': email,
    'language': language,
    'time_format': timeFormat,
    'text_size': textSize,
  };

  factory AppSettingsModel.fromRow(Map<String, Object?> row) =>
      AppSettingsModel(
        theme: AppThemePreference.values.firstWhere(
          (theme) => theme.name == row['theme_mode'],
        ),
        highContrast: row['high_contrast'] == 1,
        personalReminders: row['personal_reminders'] == 1,
        familyActivity: row['family_activity'] == 1,
        dailySummary: row['daily_summary'] == 1,
        reduceMotion: row['reduce_motion'] == 1,
        wifiOnly: row['wifi_only'] == 1,
        name: row['account_name']! as String,
        email: row['account_email']! as String,
        language: row['language']! as String,
        timeFormat: row['time_format']! as String,
        textSize: row['text_size']! as String,
      );

  AppSettingsEntity toEntity() => AppSettingsEntity(
    theme: theme,
    highContrast: highContrast,
    personalReminders: personalReminders,
    familyActivity: familyActivity,
    dailySummary: dailySummary,
    reduceMotion: reduceMotion,
    wifiOnly: wifiOnly,
    name: name,
    email: email,
    language: language,
    timeFormat: timeFormat,
    textSize: textSize,
  );
}

enum AppSettingsSyncStatus { synced, pending, syncing, failed }

class AppSettingsSyncRecord {
  const AppSettingsSyncRecord({
    required this.settings,
    required this.updatedAt,
    required this.syncStatus,
    this.syncError,
  });

  final AppSettingsEntity settings;
  final DateTime updatedAt;
  final AppSettingsSyncStatus syncStatus;
  final String? syncError;

  factory AppSettingsSyncRecord.fromRow(Map<String, Object?> row) =>
      AppSettingsSyncRecord(
        settings: AppSettingsModel.fromRow(row).toEntity(),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          (row['updated_at'] as int?) ?? 0,
          isUtc: true,
        ),
        syncStatus: AppSettingsSyncStatus.values.firstWhere(
          (status) => status.name == row['sync_status'],
          orElse: () => AppSettingsSyncStatus.pending,
        ),
        syncError: row['sync_error'] as String?,
      );

  factory AppSettingsSyncRecord.fromRemoteJson(Map<String, dynamic> json) =>
      AppSettingsSyncRecord(
        settings: AppSettingsEntity(
          theme: AppThemePreference.values.firstWhere(
            (theme) => theme.name == json['theme_mode'],
            orElse: () => AppThemePreference.system,
          ),
          highContrast: json['high_contrast'] as bool? ?? false,
          personalReminders: json['personal_reminders'] as bool? ?? true,
          familyActivity: json['family_activity'] as bool? ?? true,
          dailySummary: json['daily_summary'] as bool? ?? false,
          reduceMotion: json['reduce_motion'] as bool? ?? false,
          wifiOnly: json['wifi_only'] as bool? ?? false,
          name: json['account_name'] as String? ?? '',
          email: json['account_email'] as String? ?? '',
          language: json['language'] as String? ?? 'Español',
          timeFormat: json['time_format'] as String? ?? '24 horas',
          textSize: json['text_size'] as String? ?? 'Predeterminado',
        ),
        updatedAt: DateTime.parse(json['updated_at']! as String).toUtc(),
        syncStatus: AppSettingsSyncStatus.synced,
      );

  Map<String, Object?> toRow() => {
    ...AppSettingsModel.fromEntity(settings).toRow(),
    'updated_at': updatedAt.toUtc().millisecondsSinceEpoch,
    'sync_status': syncStatus.name,
    'sync_error': syncError,
  };

  Map<String, Object?> toRemoteJson() => {
    'theme_mode': settings.theme.name,
    'high_contrast': settings.highContrast,
    'personal_reminders': settings.personalReminders,
    'family_activity': settings.familyActivity,
    'daily_summary': settings.dailySummary,
    'reduce_motion': settings.reduceMotion,
    'wifi_only': settings.wifiOnly,
    'account_name': settings.name,
    'account_email': settings.email,
    'language': settings.language,
    'time_format': settings.timeFormat,
    'text_size': settings.textSize,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}
