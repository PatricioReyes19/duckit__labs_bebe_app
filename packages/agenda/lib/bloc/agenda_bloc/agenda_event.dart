part of 'agenda_bloc.dart';

@freezed
sealed class AgendaEvent with _$AgendaEvent {
  const factory AgendaEvent.started() = _Started;
  const factory AgendaEvent.retried() = _Retried;
  const factory AgendaEvent.refreshed() = _Refreshed;
  const factory AgendaEvent.daySelected({
    required DateTime selectedDay,
    required DateTime focusedDay,
  }) = _DaySelected;
  const factory AgendaEvent.weekChanged(DateTime focusedDay) = _WeekChanged;
  const factory AgendaEvent.monthDaySelected({
    required DateTime selectedDay,
    required DateTime focusedDay,
  }) = _MonthDaySelected;
  const factory AgendaEvent.monthChanged(DateTime focusedDay) = _MonthChanged;
  const factory AgendaEvent.categorySelected(AgendaCategory category) =
      _CategorySelected;
}
