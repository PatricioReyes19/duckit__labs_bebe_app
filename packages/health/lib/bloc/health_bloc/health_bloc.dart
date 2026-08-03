import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc() : super(const HealthInitial()) {
    on<HealthStarted>(_onStarted);
    on<HealthRefreshed>(_onRefreshed);
    on<HealthRetried>(_onRetried);
  }
  Future<void> _onStarted(
    HealthStarted event,
    Emitter<HealthState> emit,
  ) async {
    emit(const HealthLoading());
    try {
      emit(const HealthLoaded());
    } on Object catch (error) {
      emit(HealthFailure(message: error.toString()));
    }
  }

  Future<void> _onRefreshed(
    HealthRefreshed event,
    Emitter<HealthState> emit,
  ) async {}
  Future<void> _onRetried(
    HealthRetried event,
    Emitter<HealthState> emit,
  ) async {
    add(const HealthStarted());
  }
}
