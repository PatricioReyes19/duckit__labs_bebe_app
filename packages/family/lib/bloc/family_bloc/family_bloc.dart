import 'package:core/core.dart';
import 'package:family/models/family_overview_vm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_bloc.freezed.dart';
part 'family_event.dart';
part 'family_state.dart';

typedef FamilyClock = DateTime Function();

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  FamilyBloc({
    required this._getFamilyOverview,
    required SetActiveFamilyBaby setActiveBaby,
    FamilyClock? clock,
  }) : _setActiveBaby = setActiveBaby,
       _clock = clock ?? DateTime.now,
       super(const FamilyState.initial()) {
    on<_Started>(_onStarted);
    on<_Retried>(_onStarted);
    on<_BabySelected>(_onBabySelected);
  }

  final GetFamilyOverview _getFamilyOverview;
  final SetActiveFamilyBaby _setActiveBaby;
  final FamilyClock _clock;

  Future<void> _onStarted(FamilyEvent event, Emitter<FamilyState> emit) async {
    emit(const FamilyState.loading());
    try {
      final entity = await _getFamilyOverview();
      emit(
        FamilyState.loaded(
          overview: FamilyOverviewVm.fromEntity(
            entity,
            referenceDate: _clock(),
          ),
        ),
      );
    } on Object catch (error) {
      emit(
        FamilyState.failure(message: 'No pudimos cargar la familia: $error'),
      );
    }
  }

  Future<void> _onBabySelected(
    _BabySelected event,
    Emitter<FamilyState> emit,
  ) async {
    final current = state;
    if (current is! FamilyLoaded ||
        !current.overview.babies.any((baby) => baby.id == event.babyId)) {
      return;
    }
    try {
      final entity = await _setActiveBaby(event.babyId);
      emit(
        FamilyState.loaded(
          overview: FamilyOverviewVm.fromEntity(
            entity,
            referenceDate: _clock(),
          ),
        ),
      );
    } on Object catch (error) {
      emit(
        FamilyState.failure(
          message: 'No pudimos cambiar el bebé activo: $error',
        ),
      );
    }
  }
}
