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
    InitialDataSyncCoordinator? initialDataSyncCoordinator,
    HomePresentationClock? clock,
  })  : _getHomeOverview = getHomeOverview,
        _finishActiveRegisterEvent = finishActiveRegisterEvent,
        _clock = clock ?? DateTime.now,
        _syncService = syncService,
        _initialDataSyncCoordinator = initialDataSyncCoordinator,
        super(const HomeState.initial()) {
    on<_Started>((event, emit) => _load(emit, showLoading: true));
    on<_Refreshed>((event, emit) => _load(emit, showLoading: true));
    on<_Retried>(
      (event, emit) => _load(emit, showLoading: true, requestSync: true),
    );
    _registerEventsSubscription = _getHomeOverview.changes.listen((_) {
      if (!isClosed && !_isSynchronizing) add(const HomeEvent.refreshed());
    });
    _hydrationSubscription =
        _initialDataSyncCoordinator?.domainHydrationStates.listen((ready) {
      if (!ready && !isClosed) add(const HomeEvent.started());
    });
  }

  final GetHomeOverview _getHomeOverview;
  final FinishActiveRegisterEvent _finishActiveRegisterEvent;
  final HomePresentationClock _clock;
  final RegisterEventSyncService? _syncService;
  final InitialDataSyncCoordinator? _initialDataSyncCoordinator;
  late final StreamSubscription<void> _registerEventsSubscription;
  StreamSubscription<bool>? _hydrationSubscription;
  bool _isSynchronizing = false;

  Future<void> _load(
    Emitter<HomeState> emit, {
    required bool showLoading,
    bool requestSync = false,
  }) async {
    final current = state;
    if (showLoading) {
      emit(const HomeState.loading());
    } else if (current is HomeLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    try {
      await _waitForInitialHydration();
      if (requestSync) await _synchronize();
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

  Future<void> _waitForInitialHydration() async {
    final coordinator = _initialDataSyncCoordinator;
    if (coordinator == null || coordinator.hasHydratedDomains) return;
    await coordinator.domainHydrationStates.firstWhere((ready) => ready);
  }

  Future<void> _synchronize() async {
    final syncService = _syncService;
    if (syncService == null) return;
    _isSynchronizing = true;
    try {
      await syncService.synchronize();
    } on Object {
      // Home remains local-first when the remote source is unavailable.
    } finally {
      _isSynchronizing = false;
    }
  }

  Future<void> refreshFromRemote() async {
    if (isClosed) return;
    final completed = stream.firstWhere(
      (next) => next is HomeLoaded || next is HomeFailure,
    );
    add(const HomeEvent.retried());
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
    await _hydrationSubscription?.cancel();
    return super.close();
  }
}
