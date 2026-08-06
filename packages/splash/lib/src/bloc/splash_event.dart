part of 'splash_bloc.dart';

@freezed
sealed class SplashEvent with _$SplashEvent {
  const factory SplashEvent.started() = _Started;
  const factory SplashEvent.retried() = _Retried;
  const factory SplashEvent.loginRequested() = _LoginRequested;
  const factory SplashEvent.signUpRequested() = _SignUpRequested;
}
