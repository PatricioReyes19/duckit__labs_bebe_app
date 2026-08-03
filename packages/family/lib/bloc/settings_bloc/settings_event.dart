part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.started() = _Started;
  const factory SettingsEvent.themeChanged(BebeThemeModeOption value) =
      _ThemeChanged;
  const factory SettingsEvent.reduceMotionChanged(bool value) =
      _ReduceMotionChanged;
}
