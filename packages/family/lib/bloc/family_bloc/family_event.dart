part of 'family_bloc.dart';

@freezed
sealed class FamilyEvent with _$FamilyEvent {
  const factory FamilyEvent.started() = _Started;
}
