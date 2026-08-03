import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_bloc.freezed.dart';
part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc() : super(const HealthState.initial()) {
    on<_Started>((event, emit) async {
      emit(const HealthState.loading());
      // TODO(health): ejecutar caso de uso.
      emit(const HealthState.loaded());
    });
    on<_Retried>((event, emit) => add(const HealthEvent.started()));
  }
}
