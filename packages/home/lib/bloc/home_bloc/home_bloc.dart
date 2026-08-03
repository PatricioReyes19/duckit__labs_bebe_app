import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:home/models/home_overview_vm.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

typedef LoadHomeOverview = Future<HomeOverviewVm> Function();

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required LoadHomeOverview loadHomeOverview,
  })  : _loadHomeOverview = loadHomeOverview,
        super(const HomeState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
    on<_Retried>(_onRetried);
  }

  final LoadHomeOverview _loadHomeOverview;

  Future<void> _onStarted(
    _Started event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeState.loading());
    await _load(emit);
  }

  Future<void> _onRefreshed(
    _Refreshed event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    await _load(emit);
  }

  Future<void> _onRetried(
    _Retried event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeState.loading());
    await _load(emit);
  }

  Future<void> _load(Emitter<HomeState> emit) async {
    try {
      final overview = await _loadHomeOverview();
      emit(HomeState.loaded(overview: overview));
    } on Object catch (error) {
      emit(HomeState.failure(message: error.toString()));
    }
  }
}
