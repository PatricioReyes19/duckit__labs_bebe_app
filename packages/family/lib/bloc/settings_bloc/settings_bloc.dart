import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsStarted>((e, emit) async {
      emit(state.copyWith(isLoading: true));
      emit(state.copyWith(isLoading: false));
    });
    on<SettingsThemeModeChanged>(
      (e, emit) => emit(state.copyWith(themeMode: e.themeMode)),
    );
    on<SettingsReduceMotionChanged>(
      (e, emit) => emit(state.copyWith(reduceMotion: e.enabled)),
    );
  }
}
