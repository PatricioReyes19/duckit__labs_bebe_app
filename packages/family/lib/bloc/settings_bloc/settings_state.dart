part of 'settings_bloc.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isLoading,
    @Default(BebeThemeModeOption.system)
    BebeThemeModeOption themeMode,
    @Default(false) bool reduceMotion,
    String? errorMessage,
  }) = _SettingsState;
}
