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
