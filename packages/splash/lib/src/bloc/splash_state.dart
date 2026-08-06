part of 'splash_bloc.dart';

@freezed
sealed class SplashState with _$SplashState {
  const factory SplashState.resolving() = SplashResolving;
  const factory SplashState.authEntry() = SplashAuthEntryState;
  const factory SplashState.routeRequested({
    required EntryDestination destination,
  }) = SplashRouteRequested;
  const factory SplashState.failure({
    required String message,
    required bool canRetry,
  }) = SplashFailure;
}
