part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.started() = _Started;
  const factory SettingsEvent.themeChanged(BebeThemeModeOption value) =
      _ThemeChanged;
  const factory SettingsEvent.highContrastChanged(bool value) =
      _HighContrastChanged;
  const factory SettingsEvent.personalRemindersChanged(bool value) =
      _PersonalRemindersChanged;
  const factory SettingsEvent.familyActivityChanged(bool value) =
      _FamilyActivityChanged;
  const factory SettingsEvent.dailySummaryChanged(bool value) =
      _DailySummaryChanged;
  const factory SettingsEvent.reduceMotionChanged(bool value) =
      _ReduceMotionChanged;
  const factory SettingsEvent.wifiOnlyChanged(bool value) = _WifiOnlyChanged;
}
