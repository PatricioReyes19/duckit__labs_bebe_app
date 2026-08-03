part of 'agenda_bloc.dart';

@freezed
sealed class AgendaEvent with _$AgendaEvent {
  const factory AgendaEvent.started() = _Started;
  const factory AgendaEvent.retried() = _Retried;
}
