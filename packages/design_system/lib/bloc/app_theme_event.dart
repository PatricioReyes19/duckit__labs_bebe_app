part of 'app_theme_bloc.dart';

@freezed
sealed class AppThemeEvent with _$AppThemeEvent {
  const factory AppThemeEvent.updateTheme({required BebeTheme theme}) =
      _UpdateAppThemeEvent;

  const factory AppThemeEvent.updateThemeMode({required ThemeMode themeMode}) =
      _UpdateThemeModeEvent;
}
