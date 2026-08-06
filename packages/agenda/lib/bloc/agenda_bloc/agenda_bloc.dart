import 'package:agenda/models/agenda_overview_vm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agenda_bloc.freezed.dart';
part 'agenda_event.dart';
part 'agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc() : super(const AgendaState.initial()) {
    on<_Started>(_onStarted);
    on<_Retried>((event, emit) => add(const AgendaEvent.started()));
    on<_Refreshed>(_onRefreshed);
    on<_DaySelected>(_onDaySelected);
    on<_WeekChanged>(_onWeekChanged);
    on<_MonthDaySelected>(_onMonthDaySelected);
    on<_MonthChanged>(_onMonthChanged);
    on<_CategorySelected>(_onCategorySelected);
  }

  Future<void> _onStarted(
    _Started event,
    Emitter<AgendaState> emit,
  ) async {
    emit(const AgendaState.loading());
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emit(AgendaState.loaded(overview: _mockOverview()));
  }

  Future<void> _onRefreshed(
    _Refreshed event,
    Emitter<AgendaState> emit,
  ) async {
    final overview = _currentOverview;
    if (overview == null) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));

    // El repositorio real reemplazará esta emisión con nuevos datos.
    emit(AgendaState.loaded(overview: overview));
  }

  void _onDaySelected(_DaySelected event, Emitter<AgendaState> emit) {
    _update(
      emit,
      (overview) => overview.copyWith(
        selectedWeekDay: event.selectedDay,
        focusedWeekDay: event.focusedDay,
      ),
    );
  }

  void _onWeekChanged(_WeekChanged event, Emitter<AgendaState> emit) {
    _update(
      emit,
      (overview) => overview.copyWith(
        focusedWeekDay: event.focusedDay,
      ),
    );
  }

  void _onMonthDaySelected(
    _MonthDaySelected event,
    Emitter<AgendaState> emit,
  ) {
    _update(
      emit,
      (overview) => overview.copyWith(
        selectedMonthDay: event.selectedDay,
        focusedMonthDay: event.focusedDay,
      ),
    );
  }

  void _onMonthChanged(_MonthChanged event, Emitter<AgendaState> emit) {
    _update(
      emit,
      (overview) => overview.copyWith(
        focusedMonthDay: event.focusedDay,
      ),
    );
  }

  void _onCategorySelected(
    _CategorySelected event,
    Emitter<AgendaState> emit,
  ) {
    _update(
      emit,
      (overview) => overview.copyWith(
        selectedCategory: event.category,
      ),
    );
  }

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
    if (current == null) {
      return;
    }

    emit(AgendaState.loaded(overview: update(current)));
  }

  AgendaOverviewVm _mockOverview() {
    final selected = DateTime(2026, 8, 3);

    return AgendaOverviewVm(
      firstDay: DateTime(2025),
      lastDay: DateTime(2027, 12, 31),
      focusedWeekDay: selected,
      selectedWeekDay: selected,
      focusedMonthDay: selected,
      selectedMonthDay: selected,
      selectedCategory: AgendaCategory.all,
      remindersEnabled: true,
      connectionStatus: AgendaConnectionStatus.online,
      markers: [
        AgendaMarkerVm(
          id: 'm1',
          date: selected,
          category: AgendaCategory.vaccines,
        ),
        AgendaMarkerVm(
          id: 'm2',
          date: selected,
          category: AgendaCategory.medication,
        ),
        AgendaMarkerVm(
          id: 'm3',
          date: DateTime(2026, 8, 5),
          category: AgendaCategory.controls,
        ),
        AgendaMarkerVm(
          id: 'm4',
          date: DateTime(2026, 8, 8),
          category: AgendaCategory.exams,
        ),
      ],
      events: [
        AgendaEventVm(
          id: 'vaccine-pcv13',
          category: AgendaCategory.vaccines,
          title: 'Vacuna Neumococo (PCV13)',
          description: 'Segunda dosis',
          startsAt: DateTime(2026, 8, 3, 10, 30),
          caregiver: const AgendaCaregiverVm(
            name: 'Gesslien',
            role: 'Mamá',
            initials: 'G',
          ),
        ),
        AgendaEventVm(
          id: 'vitamin-d',
          category: AgendaCategory.medication,
          title: 'Vitamina D',
          description: 'Administrar dosis indicada',
          startsAt: DateTime(2026, 8, 3, 20),
          caregiver: null,
          syncStatus: AgendaSyncStatus.pending,
        ),
        AgendaEventVm(
          id: 'pediatric-control',
          category: AgendaCategory.controls,
          title: 'Control pediátrico',
          description: 'Evaluación de peso, talla y desarrollo',
          startsAt: DateTime(2026, 8, 5, 9),
          caregiver: const AgendaCaregiverVm(
            name: 'Patricio',
            role: 'Papá',
            initials: 'P',
          ),
        ),
        AgendaEventVm(
          id: 'laboratory-exam',
          category: AgendaCategory.exams,
          title: 'Examen de laboratorio',
          description: 'Llevar orden médica y antecedentes',
          startsAt: DateTime(2026, 8, 8, 8, 30),
          caregiver: null,
        ),
      ],
    );
  }
}
