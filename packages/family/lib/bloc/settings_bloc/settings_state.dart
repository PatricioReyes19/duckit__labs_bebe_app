part of 'settings_bloc.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isLoading,
    @Default(BebeThemeModeOption.system) BebeThemeModeOption themeMode,
    @Default(false) bool highContrast,
    @Default(true) bool personalReminders,
    @Default(true) bool familyActivity,
    @Default(false) bool dailySummary,
    @Default(false) bool reduceMotion,
    @Default(false) bool wifiOnly,
    @Default('Patricio Reyes') String name,
    @Default('patricio@example.com') String email,
    @Default('Español') String language,
    @Default('24 horas') String timeFormat,
    @Default('Predeterminado') String textSize,
    @Default('124 MB') String localStorage,
    @Default('1.0.0') String appVersion,
    String? errorMessage,
  }) = _SettingsState;
}
