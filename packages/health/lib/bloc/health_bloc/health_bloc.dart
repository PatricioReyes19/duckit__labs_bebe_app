import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health/models/health_overview_vm.dart';

part 'health_bloc.freezed.dart';
part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc() : super(const HealthState.initial()) {
    on<_Started>((event, emit) async {
      emit(const HealthState.loading());
      // TODO(health): ejecutar caso de uso.
      emit(
        HealthState.loaded(
          overview: const HealthOverviewVm(
            upcomingEvents: [],
            vaccinesSummary: HealthVaccinesSummaryVm(completed: 4, pending: 1),
            growthSummary: HealthGrowthSummaryVm(weightKg: 5.5),
          ),
        ),
      );
    });
    on<_Retried>((event, emit) => add(const HealthEvent.started()));
  }
}
