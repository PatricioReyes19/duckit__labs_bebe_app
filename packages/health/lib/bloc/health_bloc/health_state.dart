part of 'health_bloc.dart';

sealed class HealthState extends Equatable {
  const HealthState();
  @override
  List<Object?> get props => const [];
}

final class HealthInitial extends HealthState {
  const HealthInitial();
}

final class HealthLoading extends HealthState {
  const HealthLoading();
}

final class HealthLoaded extends HealthState {
  const HealthLoaded();
}

final class HealthFailure extends HealthState {
  const HealthFailure({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
