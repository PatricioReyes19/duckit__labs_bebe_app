import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_theme_bloc.freezed.dart';
part 'app_theme_event.dart';
part 'app_theme_state.dart';

class AppThemeBloc extends Bloc<AppThemeEvent, AppThemeState> {
  AppThemeBloc(BebeTheme theme, {required bool isDark, this.themeStorage})
    : super(
        AppThemeState(
          theme: theme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        ),
      ) {
    on<_UpdateAppThemeEvent>(_onUpdateTheme);
    on<_UpdateThemeModeEvent>(_onUpdateThemeMode);
  }

  final ThemeStorage? themeStorage;

  Future<void> _onUpdateTheme(
    _UpdateAppThemeEvent event,
    Emitter<AppThemeState> emit,
  ) async {
    emit(state.copyWith(theme: event.theme));
  }

  Future<void> _onUpdateThemeMode(
    _UpdateThemeModeEvent event,
    Emitter<AppThemeState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));

    final storage = themeStorage;
    if (storage == null) return;

    final mode = switch (event.themeMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };

    await storage.saveThemeMode(mode);
  }
}
