enum AppThemePreference { system, light, dark }

class AppSettingsEntity {
  const AppSettingsEntity({
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
}

class AppSettingsPatch {
  const AppSettingsPatch({
    this.name,
    this.theme,
    this.highContrast,
    this.personalReminders,
    this.familyActivity,
    this.dailySummary,
    this.reduceMotion,
    this.wifiOnly,
    this.language,
    this.timeFormat,
    this.textSize,
  });

  final String? name;
  final AppThemePreference? theme;
  final bool? highContrast;
  final bool? personalReminders;
  final bool? familyActivity;
  final bool? dailySummary;
  final bool? reduceMotion;
  final bool? wifiOnly;
  final String? language;
  final String? timeFormat;
  final String? textSize;
}
