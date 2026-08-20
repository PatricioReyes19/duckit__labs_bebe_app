import 'dart:async';

import 'package:agenda/models/agenda_overview_vm.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agenda_bloc.freezed.dart';
part 'agenda_event.dart';
part 'agenda_state.dart';

typedef AgendaClock = DateTime Function();

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc({
    required this._getAgendaOverview,
    GetFamilyOverview? getFamilyOverview,
    AgendaEventSyncService? syncService,
    this._initialDataSyncCoordinator,
    this.babyId,
    AgendaClock? clock,
  }) : _clock = clock ?? DateTime.now,
       // The public DI parameter intentionally omits the private underscore.
       // ignore: prefer_initializing_formals
       _syncService = syncService,
       // El parámetro público omite intencionalmente el prefijo privado.
       // ignore: prefer_initializing_formals
       _getFamilyOverview = getFamilyOverview,
       super(const AgendaState.initial()) {
    on<_Started>(_onStarted);
    on<_Retried>(
      (event, emit) =>
          _load(emit, showLoading: _currentOverview == null, requestSync: true),
    );
    on<_Refreshed>((event, emit) => _load(emit, showLoading: false));
    on<_DaySelected>(_onDaySelected);
    on<_WeekChanged>(_onWeekChanged);
    on<_MonthDaySelected>(_onMonthDaySelected);
    on<_MonthChanged>(_onMonthChanged);
    on<_CategorySelected>(_onCategorySelected);
    _changesSubscription = _getAgendaOverview.changes.listen((_) {
      _scheduleReload();
    });
    _syncSubscription = _syncService?.states.listen((syncState) {
      _remoteUnavailable = syncState.phase == RegisterSyncPhase.failed;
      if (syncState.phase != RegisterSyncPhase.syncing) {
        _scheduleReload();
      }
    });
    _familyChangesSubscription = _getFamilyOverview?.activeBabyChanges.listen((
      _,
    ) {
      _invalidateProjection();
    });
    _hydrationSubscription = _initialDataSyncCoordinator?.domainHydrationStates
        .listen((ready) {
          if (!ready) _invalidateProjection();
        });
  }

  final GetAgendaOverview _getAgendaOverview;
  final GetFamilyOverview? _getFamilyOverview;
  final AgendaEventSyncService? _syncService;
  final InitialDataSyncCoordinator? _initialDataSyncCoordinator;
  final String? babyId;
  final AgendaClock _clock;
  late final StreamSubscription<void> _changesSubscription;
  StreamSubscription<RegisterSyncState>? _syncSubscription;
  StreamSubscription<String>? _familyChangesSubscription;
  StreamSubscription<bool>? _hydrationSubscription;
  Timer? _reloadDebounce;
  AgendaOverviewVm? _lastOverview;
  bool _projectionInvalidated = false;
  bool _remoteUnavailable = false;
  bool _isSynchronizing = false;

  Future<void> _onStarted(_Started event, Emitter<AgendaState> emit) {
    final scopeChanged = _projectionInvalidated;
    _projectionInvalidated = false;
    if (scopeChanged) _lastOverview = null;
    return _load(
      emit,
      showLoading: scopeChanged || _currentOverview == null,
      requestSync: _initialDataSyncCoordinator == null,
      preserveCurrent: !scopeChanged,
    );
  }

  Future<void> _load(
    Emitter<AgendaState> emit, {
    required bool showLoading,
    bool requestSync = false,
    bool preserveCurrent = true,
  }) async {
    final previous = preserveCurrent ? _currentOverview : null;
    if (showLoading) emit(const AgendaState.loading());
    final syncService = _syncService;
    try {
      await _waitForInitialHydration();
      if (requestSync && syncService != null) {
        await _synchronize(syncService);
      }
      final resolvedBabyId =
          babyId ?? (await _getFamilyOverview?.call())?.activeBabyId;
      if (resolvedBabyId == null || resolvedBabyId.isEmpty) {
        throw StateError('No active baby is available for Agenda.');
      }
      final entity = await _getAgendaOverview(resolvedBabyId);
      var overview = AgendaOverviewVm.fromEntity(
        entity,
        selectedDay: previous?.selectedWeekDay ?? _clock(),
      );
      if (_remoteUnavailable) {
        overview = overview.copyWith(
          connectionStatus: AgendaConnectionStatus.offline,
        );
      }
      if (previous != null) {
        overview = overview.copyWith(
          focusedWeekDay: previous.focusedWeekDay,
          selectedWeekDay: previous.selectedWeekDay,
          focusedMonthDay: previous.focusedMonthDay,
          selectedMonthDay: previous.selectedMonthDay,
          selectedCategory: previous.selectedCategory,
        );
      }
      _emitOverview(emit, overview);
    } on Object catch (error) {
      if (previous != null) {
        final preserved = _remoteUnavailable
            ? previous.copyWith(
                connectionStatus: AgendaConnectionStatus.offline,
              )
            : previous;
        _emitOverview(emit, preserved);
      } else {
        emit(
          AgendaState.failure(message: 'No pudimos cargar la agenda: $error'),
        );
      }
    }
  }

  Future<void> _synchronize(AgendaEventSyncService syncService) async {
    _isSynchronizing = true;
    try {
      await syncService.synchronize();
    } on Object {
      _remoteUnavailable = true;
    } finally {
      _isSynchronizing = false;
    }
  }

  Future<void> _waitForInitialHydration() async {
    final coordinator = _initialDataSyncCoordinator;
    if (coordinator == null || coordinator.hasHydratedDomains) return;
    await coordinator.domainHydrationStates.firstWhere((ready) => ready);
  }

  Future<void> refreshFromRemote() async {
    if (isClosed) return;
    final completed = stream.firstWhere(
      (next) =>
          next is AgendaLoaded || next is AgendaEmpty || next is AgendaFailure,
    );
    add(const AgendaEvent.retried());
    await completed;
  }

  void _scheduleReload() {
    if (isClosed || _isSynchronizing) return;
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 32), () {
      if (!isClosed) add(const AgendaEvent.refreshed());
    });
  }

  void _invalidateProjection() {
    if (isClosed) return;
    _projectionInvalidated = true;
    add(const AgendaEvent.started());
  }

  void _onDaySelected(_DaySelected event, Emitter<AgendaState> emit) => _update(
    emit,
    (overview) => overview.copyWith(
      selectedWeekDay: event.selectedDay,
      focusedWeekDay: event.focusedDay,
    ),
  );

  void _onWeekChanged(_WeekChanged event, Emitter<AgendaState> emit) => _update(
    emit,
    (overview) => overview.copyWith(focusedWeekDay: event.focusedDay),
  );

  void _onMonthDaySelected(
    _MonthDaySelected event,
    Emitter<AgendaState> emit,
  ) => _update(
    emit,
    (overview) => overview.copyWith(
      selectedMonthDay: event.selectedDay,
      focusedMonthDay: event.focusedDay,
    ),
  );

  void _onMonthChanged(_MonthChanged event, Emitter<AgendaState> emit) =>
      _update(
        emit,
        (overview) => overview.copyWith(focusedMonthDay: event.focusedDay),
      );

  void _onCategorySelected(
    _CategorySelected event,
    Emitter<AgendaState> emit,
  ) => _update(
    emit,
    (overview) => overview.copyWith(selectedCategory: event.category),
  );

  AgendaOverviewVm? get _currentOverview => switch (state) {
    AgendaLoaded(:final overview) => overview,
    AgendaEmpty(:final overview) => overview,
    _ => _lastOverview,
  };

  void _emitOverview(Emitter<AgendaState> emit, AgendaOverviewVm overview) {
    _lastOverview = overview;
    if (overview.events.isEmpty && overview.registerEvents.isEmpty) {
      emit(AgendaState.empty(overview: overview));
    } else {
      emit(AgendaState.loaded(overview: overview));
    }
  }

  void _update(
    Emitter<AgendaState> emit,
    AgendaOverviewVm Function(AgendaOverviewVm overview) update,
  ) {
    final current = _currentOverview;
    if (current != null) {
      final updated = update(current);
      _lastOverview = updated;
      emit(AgendaState.loaded(overview: updated));
    }
  }

  @override
  Future<void> close() async {
    _reloadDebounce?.cancel();
    await _changesSubscription.cancel();
    await _syncSubscription?.cancel();
    await _familyChangesSubscription?.cancel();
    await _hydrationSubscription?.cancel();
    return super.close();
  }
}
