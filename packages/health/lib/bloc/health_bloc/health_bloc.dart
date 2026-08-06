import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health/models/health_overview_vm.dart';

part 'health_bloc.freezed.dart';
part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc({
    required GetHealthOverview getHealthOverview,
    this.babyId = 'local-active-baby',
  }) : _getHealthOverview = getHealthOverview,
       super(const HealthState.initial()) {
    on<_Started>(_onLoad);
    on<_Retried>(_onLoad);
  }

  final GetHealthOverview _getHealthOverview;
  final String babyId;

  Future<void> _onLoad(HealthEvent event, Emitter<HealthState> emit) async {
    emit(const HealthState.loading());
    try {
      final entity = await _getHealthOverview(babyId);
      emit(HealthState.loaded(overview: HealthOverviewVm.fromEntity(entity)));
    } on Object catch (error) {
      emit(
        HealthState.failure(
          message: 'No pudimos cargar la información de salud: $error',
        ),
      );
    }
  }
}
