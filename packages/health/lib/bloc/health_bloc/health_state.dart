part of 'health_bloc.dart';

@freezed
sealed class HealthState with _$HealthState {
  const factory HealthState.initial() = HealthInitial;
  const factory HealthState.loading() = HealthLoading;
  const factory HealthState.loaded({required HealthOverviewVm overview}) =
      HealthLoaded;
  const factory HealthState.failure({required String message}) = HealthFailure;
}
