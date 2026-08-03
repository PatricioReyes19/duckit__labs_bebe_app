part of 'family_bloc.dart';

sealed class FamilyEvent extends Equatable {
  const FamilyEvent();
  @override
  List<Object?> get props => const [];
}

final class FamilyStarted extends FamilyEvent {
  const FamilyStarted();
}

final class FamilyRefreshed extends FamilyEvent {
  const FamilyRefreshed();
}

final class FamilyRetried extends FamilyEvent {
  const FamilyRetried();
}
