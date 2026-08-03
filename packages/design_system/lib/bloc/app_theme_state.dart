part of 'app_theme_bloc.dart';

@freezed
abstract class AppThemeState with _$AppThemeState {
  const factory AppThemeState({
    required BebeTheme theme,
    required ThemeMode themeMode,
  }) = _AppThemeState;
}
