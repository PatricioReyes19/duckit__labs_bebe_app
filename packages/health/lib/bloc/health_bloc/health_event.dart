part of 'health_bloc.dart';

@freezed
sealed class HealthEvent with _$HealthEvent {
  const factory HealthEvent.started() = _Started;
  const factory HealthEvent.retried() = _Retried;
}
