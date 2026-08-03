part of 'health_bloc.dart';

sealed class HealthEvent extends Equatable {
  const HealthEvent();
  @override
  List<Object?> get props => const [];
}

final class HealthStarted extends HealthEvent {
  const HealthStarted();
}

final class HealthRefreshed extends HealthEvent {
  const HealthRefreshed();
}

final class HealthRetried extends HealthEvent {
  const HealthRetried();
}
