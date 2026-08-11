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
    on<_Started>((event, emit) => _load(emit, showLoading: true));
    on<_Retried>((event, emit) => _load(emit, showLoading: true));
    on<_Refreshed>((event, emit) => _load(emit, showLoading: false));
    on<_DaySelected>(_onDaySelected);
    on<_WeekChanged>(_onWeekChanged);
    on<_MonthDaySelected>(_onMonthDaySelected);
    on<_MonthChanged>(_onMonthChanged);
    on<_CategorySelected>(_onCategorySelected);
    _changesSubscription = _getAgendaOverview.changes.listen((_) {
      if (!isClosed) add(const AgendaEvent.refreshed());
    });
    _syncSubscription = _syncService?.states.listen((syncState) {
      _remoteUnavailable = syncState.phase == RegisterSyncPhase.failed;
      if (!isClosed) add(const AgendaEvent.refreshed());
    });
  }

  final GetAgendaOverview _getAgendaOverview;
  final GetFamilyOverview? _getFamilyOverview;
  final AgendaEventSyncService? _syncService;
  final String? babyId;
  final AgendaClock _clock;
  late final StreamSubscription<void> _changesSubscription;
  StreamSubscription<RegisterSyncState>? _syncSubscription;
  bool _remoteUnavailable = false;

  Future<void> _load(
    Emitter<AgendaState> emit, {
    required bool showLoading,
  }) async {
    final previous = _currentOverview;
    if (showLoading) emit(const AgendaState.loading());
    if (showLoading && _syncService != null) {
      unawaited(_syncService.synchronize());
    }
    try {
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
      if (overview.events.isEmpty && overview.registerEvents.isEmpty) {
        emit(AgendaState.empty(overview: overview));
      } else {
        emit(AgendaState.loaded(overview: overview));
      }
    } on Object catch (error) {
      emit(AgendaState.failure(message: 'No pudimos cargar la agenda: $error'));
    }
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
    _ => null,
  };

  void _update(
    Emitter<AgendaState> emit,
    AgendaOverviewVm Function(AgendaOverviewVm overview) update,
  ) {
    final current = _currentOverview;
    if (current != null) emit(AgendaState.loaded(overview: update(current)));
  }

  @override
  Future<void> close() async {
    await _changesSubscription.cancel();
    await _syncSubscription?.cancel();
    return super.close();
  }
}
