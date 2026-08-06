part of 'family_bloc.dart';

@freezed
sealed class FamilyEvent with _$FamilyEvent {
  const factory FamilyEvent.started() = _Started;
  const factory FamilyEvent.retried() = _Retried;
  const factory FamilyEvent.babySelected(String babyId) = _BabySelected;
}
