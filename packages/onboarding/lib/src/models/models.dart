enum OnboardingEntry { choice, invitation, babyProfile }

enum OnboardingStep {
  choice,
  invitationCode,
  invitationReview,
  invitationInvalid,
  babyProfile,
  babyCreated,
  invitationAccepted,
  invitationDeclined,
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
    this.photoPath,
  });

  final String name;
  final DateTime birthDate;
  final SexReference sexReference;
  final String? photoPath;
}

class BabyProfile {
  const BabyProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.sexReference,
    this.photoPath,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final SexReference sexReference;
  final String? photoPath;
}

class CareInvitation {
  const CareInvitation({
    required this.id,
    required this.code,
    required this.inviterName,
    required this.inviterRelationship,
    required this.babyName,
    required this.babyAgeLabel,
    this.relationship = 'Acceso pendiente de confirmación',
    this.accessDescription = 'Acceso de solo lectura',
    this.canWrite = false,
    this.familyName,
    this.familyId,
    this.babyId,
    this.babyBirthDate,
  });

  final String id;
  final String code;
  final String inviterName;
  final String inviterRelationship;
  final String babyName;
  final String babyAgeLabel;

  /// Role and capabilities confirmed by the invitation service.
  ///
  /// Defaults are deliberately restrictive for malformed or legacy payloads.
  final String relationship;
  final String accessDescription;
  final bool canWrite;
  final String? familyName;
  final String? familyId;
  final String? babyId;
  final DateTime? babyBirthDate;
}

class InvitationLookupResult {
  const InvitationLookupResult.valid(this.invitation) : failure = null;

  const InvitationLookupResult.invalid(this.failure) : invitation = null;

  final CareInvitation? invitation;
  final InvitationFailureReason? failure;

  bool get isValid => invitation != null;
}
