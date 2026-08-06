import '../models/models.dart';

enum OnboardingActionStatus { idle, loading, failure }

class OnboardingState {
  const OnboardingState({
    required this.step,
    this.status = OnboardingActionStatus.idle,
    this.invitationCode = '',
    this.invitation,
    this.invitationFailure,
    this.babyName = '',
    this.birthDate,
    this.sexReference,
    this.createdBaby,
    this.babyNameError,
    this.birthDateError,
    this.sexReferenceError,
    this.invitationCodeError,
    this.message,
  });

  factory OnboardingState.initial(OnboardingEntry entry) {
    return OnboardingState(
      step: switch (entry) {
        OnboardingEntry.choice => OnboardingStep.choice,
        OnboardingEntry.invitation => OnboardingStep.invitationCode,
        OnboardingEntry.babyProfile => OnboardingStep.babyProfile,
      },
    );
  }

  final OnboardingStep step;
  final OnboardingActionStatus status;
  final String invitationCode;
  final CareInvitation? invitation;
  final InvitationFailureReason? invitationFailure;
  final String babyName;
  final DateTime? birthDate;
  final SexReference? sexReference;
  final BabyProfile? createdBaby;
  final String? babyNameError;
  final String? birthDateError;
  final String? sexReferenceError;
  final String? invitationCodeError;
  final String? message;

  bool get isLoading => status == OnboardingActionStatus.loading;

  OnboardingState copyWith({
    OnboardingStep? step,
    OnboardingActionStatus? status,
    String? invitationCode,
    CareInvitation? invitation,
    InvitationFailureReason? invitationFailure,
    String? babyName,
    DateTime? birthDate,
    SexReference? sexReference,
    BabyProfile? createdBaby,
    String? babyNameError,
    String? birthDateError,
    String? sexReferenceError,
    String? invitationCodeError,
    String? message,
    bool clearInvitation = false,
    bool clearInvitationFailure = false,
    bool clearBabyNameError = false,
    bool clearBirthDateError = false,
    bool clearSexReferenceError = false,
    bool clearInvitationCodeError = false,
    bool clearMessage = false,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      status: status ?? this.status,
      invitationCode: invitationCode ?? this.invitationCode,
      invitation: clearInvitation ? null : invitation ?? this.invitation,
      invitationFailure: clearInvitationFailure
          ? null
          : invitationFailure ?? this.invitationFailure,
      babyName: babyName ?? this.babyName,
      birthDate: birthDate ?? this.birthDate,
      sexReference: sexReference ?? this.sexReference,
      createdBaby: createdBaby ?? this.createdBaby,
      babyNameError:
          clearBabyNameError ? null : babyNameError ?? this.babyNameError,
      birthDateError:
          clearBirthDateError ? null : birthDateError ?? this.birthDateError,
      sexReferenceError: clearSexReferenceError
          ? null
          : sexReferenceError ?? this.sexReferenceError,
      invitationCodeError: clearInvitationCodeError
          ? null
          : invitationCodeError ?? this.invitationCodeError,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
