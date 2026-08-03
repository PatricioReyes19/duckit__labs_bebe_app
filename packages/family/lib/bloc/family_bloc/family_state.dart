part of 'family_bloc.dart';

sealed class FamilyState extends Equatable {
  const FamilyState();
  @override
  List<Object?> get props => const [];
}

final class FamilyInitial extends FamilyState {
  const FamilyInitial();
}

final class FamilyLoading extends FamilyState {
  const FamilyLoading();
}

final class FamilyLoaded extends FamilyState {
  const FamilyLoaded();
}

final class FamilyFailure extends FamilyState {
  const FamilyFailure({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
