enum OnboardingEntry { choice, invitation, babyProfile }

enum OnboardingStep {
  choice,
  invitationCode,
  invitationReview,
  invitationInvalid,
  babyProfile,
  babyCreated,
  invitationAccepted,
}

enum SexReference { male, female }

enum InvitationFailureReason {
  expired,
  revoked,
  wrongAccount,
  alreadyMember,
  notFound,
}

class BabyDraft {
  const BabyDraft({
    required this.name,
    required this.birthDate,
    required this.sexReference,
  });

  final String name;
  final DateTime birthDate;
  final SexReference sexReference;
}

class BabyProfile {
  const BabyProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.sexReference,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final SexReference sexReference;
}

class CareInvitation {
  const CareInvitation({
    required this.id,
    required this.code,
    required this.inviterName,
    required this.inviterRelationship,
    required this.babyName,
    required this.babyAgeLabel,
  });

  final String id;
  final String code;
  final String inviterName;
  final String inviterRelationship;
  final String babyName;
  final String babyAgeLabel;
}

class InvitationLookupResult {
  const InvitationLookupResult.valid(this.invitation) : failure = null;

  const InvitationLookupResult.invalid(this.failure) : invitation = null;

  final CareInvitation? invitation;
  final InvitationFailureReason? failure;

  bool get isValid => invitation != null;
}
