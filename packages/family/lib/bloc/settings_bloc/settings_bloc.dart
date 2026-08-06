import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<_Started>(_onStarted);
    on<_ThemeChanged>(
      (event, emit) => emit(state.copyWith(themeMode: event.value)),
    );
    on<_HighContrastChanged>(
      (event, emit) => emit(state.copyWith(highContrast: event.value)),
    );
    on<_PersonalRemindersChanged>(
      (event, emit) => emit(
        state.copyWith(personalReminders: event.value),
      ),
    );
    on<_FamilyActivityChanged>(
      (event, emit) => emit(state.copyWith(familyActivity: event.value)),
    );
    on<_DailySummaryChanged>(
      (event, emit) => emit(state.copyWith(dailySummary: event.value)),
    );
    on<_ReduceMotionChanged>(
      (event, emit) => emit(state.copyWith(reduceMotion: event.value)),
    );
    on<_WifiOnlyChanged>(
      (event, emit) => emit(state.copyWith(wifiOnly: event.value)),
    );
  }

  Future<void> _onStarted(
    _Started event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await Future<void>.delayed(const Duration(milliseconds: 200));
    emit(state.copyWith(isLoading: false));
  }
}
