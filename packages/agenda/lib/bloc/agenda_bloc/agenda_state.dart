part of 'agenda_bloc.dart';

@freezed
sealed class AgendaState with _$AgendaState {
  const factory AgendaState.initial() = AgendaInitial;
  const factory AgendaState.loading() = AgendaLoading;
  const factory AgendaState.loaded({required AgendaOverviewVm overview}) =
      AgendaLoaded;
  const factory AgendaState.empty({required AgendaOverviewVm overview}) =
      AgendaEmpty;
  const factory AgendaState.failure({required String message}) = AgendaFailure;
}
