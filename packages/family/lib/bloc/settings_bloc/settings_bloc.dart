import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<_Started>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      emit(state.copyWith(isLoading: false));
    });
    on<_ThemeChanged>((event, emit) {
      emit(state.copyWith(themeMode: event.value));
    });
    on<_ReduceMotionChanged>((event, emit) {
      emit(state.copyWith(reduceMotion: event.value));
    });
  }
}
