import 'dart:async';

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
    required FinishActiveRegisterEvent finishActiveRegisterEvent,
    RegisterEventSyncService? syncService,
    HomePresentationClock? clock,
  })  : _getHomeOverview = getHomeOverview,
        _finishActiveRegisterEvent = finishActiveRegisterEvent,
        _clock = clock ?? DateTime.now,
        _syncService = syncService,
        super(const HomeState.initial()) {
    on<_Started>((event, emit) => _load(emit, showLoading: true));
    on<_Refreshed>((event, emit) => _load(emit, showLoading: false));
    on<_Retried>((event, emit) => _load(emit, showLoading: true));
    _registerEventsSubscription = _getHomeOverview.changes.listen((_) {
      if (!isClosed) add(const HomeEvent.refreshed());
    });
  }

  final GetHomeOverview _getHomeOverview;
  final FinishActiveRegisterEvent _finishActiveRegisterEvent;
  final HomePresentationClock _clock;
  final RegisterEventSyncService? _syncService;
  late final StreamSubscription<void> _registerEventsSubscription;

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

  Future<void> refreshFromRemote() async {
    try {
      await _syncService?.synchronize();
    } on Object {
      // Home remains local-first when the remote source is unavailable.
    }
    if (isClosed) return;
    final completed = stream.firstWhere(
      (next) => next is HomeLoaded || next is HomeFailure,
    );
    add(const HomeEvent.refreshed());
    await completed;
  }

  /// Completes the original active record for the baby currently shown.
  Future<bool> finishActiveActivity(String eventId) async {
    final current = state;
    if (current is! HomeLoaded) return false;
    final finished = await _finishActiveRegisterEvent(
      eventId: eventId,
      babyId: current.overview.activeBaby.id,
      endedAt: _clock(),
    );
    return finished != null;
  }

  @override
  Future<void> close() async {
    await _registerEventsSubscription.cancel();
    return super.close();
  }
}
