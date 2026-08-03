part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => const [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded();
}

final class HomeFailure extends HomeState {
  const HomeFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
