import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health/models/health_overview_vm.dart';

part 'health_bloc.freezed.dart';
part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc({
    required this._getHealthOverview,
    GetFamilyOverview? getFamilyOverview,
    this.babyId,
  }) : super(const HealthState.initial()) {
    _getFamilyOverview = getFamilyOverview;
    on<_Started>(_onLoad);
    on<_Retried>(_onLoad);
  }

  final GetHealthOverview _getHealthOverview;
  late final GetFamilyOverview? _getFamilyOverview;
  final String? babyId;

  Future<void> _onLoad(HealthEvent event, Emitter<HealthState> emit) async {
    emit(const HealthState.loading());
    try {
      final resolvedBabyId = babyId ??
          (await _getFamilyOverview?.call())?.activeBabyId;
      if (resolvedBabyId == null || resolvedBabyId.isEmpty) {
        throw StateError('No active baby is available for Health.');
      }
      final entity = await _getHealthOverview(resolvedBabyId);
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
