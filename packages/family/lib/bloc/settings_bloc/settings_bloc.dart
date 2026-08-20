import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'settings_event.dart';
import 'settings_state.dart';

export 'settings_event.dart';
export 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required this._getAppSettings,
    required UpdateAppSettings updateAppSettings,
    required this._getCurrentSession,
  }) : _updateAppSettings = updateAppSettings,
       super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsAccountNameChanged>(
      (event, emit) => _persist(AppSettingsPatch(name: event.value), emit),
    );
    on<SettingsLanguageChanged>(
      (event, emit) => _persist(AppSettingsPatch(language: event.value), emit),
    );
    on<SettingsTimeFormatChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(timeFormat: event.value), emit),
    );
    on<SettingsTextSizeChanged>(
      (event, emit) => _persist(AppSettingsPatch(textSize: event.value), emit),
    );
    on<SettingsHighContrastChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(highContrast: event.value), emit),
    );
    on<SettingsPersonalRemindersChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(personalReminders: event.value), emit),
    );
    on<SettingsFamilyActivityChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(familyActivity: event.value), emit),
    );
    on<SettingsDailySummaryChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(dailySummary: event.value), emit),
    );
    on<SettingsReduceMotionChanged>(
      (event, emit) =>
          _persist(AppSettingsPatch(reduceMotion: event.value), emit),
    );
    on<SettingsWifiOnlyChanged>(
      (event, emit) => _persist(AppSettingsPatch(wifiOnly: event.value), emit),
    );
  }

  final GetAppSettings _getAppSettings;
  final UpdateAppSettings _updateAppSettings;
  final GetCurrentSession _getCurrentSession;
  AuthSession? _session;

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final settings = await _getAppSettings();
      _session = await _getCurrentSession();
      emit(_toState(settings));
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

  Future<void> _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final previous = state;

    // Refleja la selección antes de escribir en SQLite. Esto evita que el
    // rebuild del Theme global devuelva el control a la posición anterior.
    emit(state.copyWith(themeMode: event.value, errorMessage: null));

    try {
      await _updateAppSettings(
        AppSettingsPatch(theme: _domainTheme(event.value)),
      );
      // El estado optimista ya contiene el valor persistido. Emitirlo de
      // nuevo reconstruía toda la pantalla de Ajustes inmediatamente después
      // del rebuild global de MaterialApp causado por el cambio de tema.
    } on Object catch (error) {
      emit(
        previous.copyWith(
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
    name: _displayName(settings),
    email: _session?.user.email ?? settings.email,
    language: settings.language,
    timeFormat: settings.timeFormat,
    textSize: settings.textSize,
    localStorage: 'Datos locales disponibles',
    appVersion: '1.0.0',
  );

  String _displayName(AppSettingsEntity settings) {
    final stored = settings.name.trim();
    if (stored.isNotEmpty && stored != 'Usuario Bypass') return stored;
    return _session?.user.displayName ?? stored;
  }

  static AppThemePreference _domainTheme(BebeThemeModeOption value) =>
      switch (value) {
        BebeThemeModeOption.system => AppThemePreference.system,
        BebeThemeModeOption.light => AppThemePreference.light,
        BebeThemeModeOption.dark => AppThemePreference.dark,
      };
}
