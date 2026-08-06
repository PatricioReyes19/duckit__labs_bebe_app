part of 'family_bloc.dart';

@freezed
sealed class FamilyState with _$FamilyState {
  const factory FamilyState.initial() = FamilyInitial;
  const factory FamilyState.loading() = FamilyLoading;
  const factory FamilyState.loaded({required FamilyOverviewVm overview}) =
      FamilyLoaded;
  const factory FamilyState.failure({required String message}) = FamilyFailure;
}
