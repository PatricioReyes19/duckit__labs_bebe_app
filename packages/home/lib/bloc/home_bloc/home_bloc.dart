import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:home/models/home_overview_vm.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

typedef HomePresentationClock = DateTime Function();

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetHomeOverview getHomeOverview,
    HomePresentationClock? clock,
  })  : _getHomeOverview = getHomeOverview,
        _clock = clock ?? DateTime.now,
        super(const HomeState.initial()) {
    on<_Started>((event, emit) => _load(emit, showLoading: true));
    on<_Refreshed>((event, emit) => _load(emit, showLoading: false));
    on<_Retried>((event, emit) => _load(emit, showLoading: true));
  }

  final GetHomeOverview _getHomeOverview;
  final HomePresentationClock _clock;

  Future<void> _load(
    Emitter<HomeState> emit, {
    required bool showLoading,
  }) async {
    final current = state;
    if (showLoading) {
      emit(const HomeState.loading());
    } else if (current is HomeLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    try {
      final entity = await _getHomeOverview();
      emit(
        HomeState.loaded(
          overview: HomeOverviewVm.fromEntity(
            entity,
            referenceDate: _clock(),
          ),
        ),
      );
    } on Object catch (error) {
      emit(
        HomeState.failure(
          message: 'No pudimos cargar el inicio: $error',
        ),
      );
    }
  }
}
