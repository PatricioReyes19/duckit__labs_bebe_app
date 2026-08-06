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
    required GetAgendaOverview getAgendaOverview,
    this.babyId = 'local-active-baby',
    AgendaClock? clock,
  }) : _getAgendaOverview = getAgendaOverview,
       _clock = clock ?? DateTime.now,
       super(const AgendaState.initial()) {
    on<_Started>((event, emit) => _load(emit, showLoading: true));
    on<_Retried>((event, emit) => _load(emit, showLoading: true));
    on<_Refreshed>((event, emit) => _load(emit, showLoading: false));
    on<_DaySelected>(_onDaySelected);
    on<_WeekChanged>(_onWeekChanged);
    on<_MonthDaySelected>(_onMonthDaySelected);
    on<_MonthChanged>(_onMonthChanged);
    on<_CategorySelected>(_onCategorySelected);
  }

  final GetAgendaOverview _getAgendaOverview;
  final String babyId;
  final AgendaClock _clock;

  Future<void> _load(
    Emitter<AgendaState> emit, {
    required bool showLoading,
  }) async {
    final previous = _currentOverview;
    if (showLoading) emit(const AgendaState.loading());
    try {
      final entity = await _getAgendaOverview(babyId);
      var overview = AgendaOverviewVm.fromEntity(
        entity,
        selectedDay: previous?.selectedWeekDay ?? _clock(),
      );
      if (previous != null) {
        overview = overview.copyWith(
          focusedWeekDay: previous.focusedWeekDay,
          selectedWeekDay: previous.selectedWeekDay,
          focusedMonthDay: previous.focusedMonthDay,
          selectedMonthDay: previous.selectedMonthDay,
          selectedCategory: previous.selectedCategory,
        );
      }
      emit(AgendaState.loaded(overview: overview));
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
}
