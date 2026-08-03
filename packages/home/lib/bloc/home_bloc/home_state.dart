part of 'home_bloc.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeInitial;
  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.loaded({
    required HomeOverviewVm overview,
    @Default(false) bool isRefreshing,
  }) = HomeLoaded;
  const factory HomeState.failure({
    required String message,
  }) = HomeFailure;
}
