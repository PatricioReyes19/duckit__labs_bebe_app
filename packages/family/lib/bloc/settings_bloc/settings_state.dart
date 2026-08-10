import 'package:design_system/design_system.dart';

class SettingsState {
  const SettingsState({
    this.isLoading = false,
    this.themeMode = BebeThemeModeOption.system,
    this.highContrast = false,
    this.personalReminders = true,
    this.familyActivity = true,
    this.dailySummary = false,
    this.reduceMotion = false,
    this.wifiOnly = false,
    this.name = '',
    this.email = '',
    this.language = '',
    this.timeFormat = '',
    this.textSize = '',
    this.localStorage = '',
    this.appVersion = '1.0.0',
    this.errorMessage,
  });

  final bool isLoading;
  final BebeThemeModeOption themeMode;
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
  final String localStorage;
  final String appVersion;
  final String? errorMessage;

  static const _notProvided = Object();

  SettingsState copyWith({
    bool? isLoading,
    BebeThemeModeOption? themeMode,
    bool? highContrast,
    bool? personalReminders,
    bool? familyActivity,
    bool? dailySummary,
    bool? reduceMotion,
    bool? wifiOnly,
    String? name,
    String? email,
    String? language,
    String? timeFormat,
    String? textSize,
    String? localStorage,
    String? appVersion,
    Object? errorMessage = _notProvided,
  }) => SettingsState(
    isLoading: isLoading ?? this.isLoading,
    themeMode: themeMode ?? this.themeMode,
    highContrast: highContrast ?? this.highContrast,
    personalReminders: personalReminders ?? this.personalReminders,
    familyActivity: familyActivity ?? this.familyActivity,
    dailySummary: dailySummary ?? this.dailySummary,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    name: name ?? this.name,
    email: email ?? this.email,
    language: language ?? this.language,
    timeFormat: timeFormat ?? this.timeFormat,
    textSize: textSize ?? this.textSize,
    localStorage: localStorage ?? this.localStorage,
    appVersion: appVersion ?? this.appVersion,
    errorMessage: identical(errorMessage, _notProvided)
        ? this.errorMessage
        : errorMessage as String?,
  );
}
