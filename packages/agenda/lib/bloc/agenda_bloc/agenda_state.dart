part of 'agenda_bloc.dart';

@freezed
sealed class AgendaState with _$AgendaState {
  const factory AgendaState.initial() = AgendaInitial;
  const factory AgendaState.loading() = AgendaLoading;
  const factory AgendaState.loaded() = AgendaLoaded;
  const factory AgendaState.failure({required String message}) = AgendaFailure;
}
