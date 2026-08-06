import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required GetAppSettings getAppSettings,
    required UpdateAppSettings updateAppSettings,
  }) : _getAppSettings = getAppSettings,
       _updateAppSettings = updateAppSettings,
       super(const SettingsState()) {
    on<_Started>(_onStarted);
    on<_ThemeChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(theme: _domainTheme(event.value)), emit),
    );
    on<_HighContrastChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(highContrast: event.value), emit),
    );
    on<_PersonalRemindersChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(personalReminders: event.value), emit),
    );
    on<_FamilyActivityChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(familyActivity: event.value), emit),
    );
    on<_DailySummaryChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(dailySummary: event.value), emit),
    );
    on<_ReduceMotionChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(reduceMotion: event.value), emit),
    );
    on<_WifiOnlyChanged>(
      (event, emit) => _persist(AppSettingsPatch(wifiOnly: event.value), emit),
    );
  }

  final GetAppSettings _getAppSettings;
  final UpdateAppSettings _updateAppSettings;

  Future<void> _onStarted(_Started event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      emit(_toState(await _getAppSettings()));
    } on Object catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'No pudimos cargar la configuración: $error',
        ),
      );
    }
  }

  Future<void> _persist(
    AppSettingsPatch patch,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(_toState(await _updateAppSettings(patch)));
    } on Object catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'No pudimos guardar la configuración: $error',
        ),
      );
    }
  }

  SettingsState _toState(AppSettingsEntity settings) => SettingsState(
    themeMode: switch (settings.theme) {
      AppThemePreference.system => BebeThemeModeOption.system,
      AppThemePreference.light => BebeThemeModeOption.light,
      AppThemePreference.dark => BebeThemeModeOption.dark,
    },
    highContrast: settings.highContrast,
    personalReminders: settings.personalReminders,
    familyActivity: settings.familyActivity,
    dailySummary: settings.dailySummary,
    reduceMotion: settings.reduceMotion,
    wifiOnly: settings.wifiOnly,
    name: settings.name,
    email: settings.email,
    language: settings.language,
    timeFormat: settings.timeFormat,
    textSize: settings.textSize,
    localStorage: 'Datos locales disponibles',
    appVersion: '1.0.0',
  );

  static AppThemePreference _domainTheme(BebeThemeModeOption value) =>
      switch (value) {
        BebeThemeModeOption.system => AppThemePreference.system,
        BebeThemeModeOption.light => AppThemePreference.light,
        BebeThemeModeOption.dark => AppThemePreference.dark,
      };
}
