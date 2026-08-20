enum FamilyMemberStatus { active, pending }

class BabyEntity {
  const BabyEntity({
    required this.id,
    required this.familyId,
    required this.name,
    required this.birthDate,
    this.avatarAssetPath,
    this.isPremature = false,
    this.livesInRapaNui = false,
    this.hasRsvRisk = false,
  });

  final String id;
  final String familyId;
  final String name;
  final DateTime birthDate;
  final String? avatarAssetPath;
  final bool isPremature;
  final bool livesInRapaNui;
  final bool hasRsvRisk;
}

class FamilyMemberEntity {
  const FamilyMemberEntity({
    required this.id,
    required this.familyId,
    required this.name,
    required this.role,
    required this.accessDescription,
    required this.status,
    this.canWrite = false,
    this.contact,
    this.invitationCode,
    this.invitedAt,
    this.invitationExpiresAt,
  });

  final String id;
  final String familyId;
  final String name;
  final String role;
  final String accessDescription;
  final FamilyMemberStatus status;

  /// Permission last confirmed by the care-circle membership on the server.
  ///
  /// A missing value is intentionally read-only: local data must never grant a
  /// capability that was not explicitly granted remotely.
  final bool canWrite;
  final String? contact;
  final String? invitationCode;
  final DateTime? invitedAt;
  final DateTime? invitationExpiresAt;

  bool get invitationExpired =>
      status == FamilyMemberStatus.pending &&
      invitationExpiresAt?.isBefore(DateTime.now()) == true;
}

class FamilyOverviewEntity {
  const FamilyOverviewEntity({
    required this.id,
    required this.name,
    required this.activeBabyId,
    required this.babies,
    required this.members,
  });

  final String id;
  final String name;
  final String activeBabyId;
  final List<BabyEntity> babies;
  final List<FamilyMemberEntity> members;

  BabyEntity get activeBaby =>
      babies.firstWhere((baby) => baby.id == activeBabyId);

  int get pendingInvitations => members
      .where((member) => member.status == FamilyMemberStatus.pending)
      .length;
}

class BabyDraft {
  const BabyDraft({
    required this.familyId,
    required this.name,
    required this.birthDate,
    this.avatarAssetPath,
    this.isPremature = false,
    this.livesInRapaNui = false,
    this.hasRsvRisk = false,
  });

  final String familyId;
  final String name;
  final DateTime birthDate;
  final String? avatarAssetPath;
  final bool isPremature;
  final bool livesInRapaNui;
  final bool hasRsvRisk;
}

class BabyPatch {
  const BabyPatch({
    this.name,
    this.birthDate,
    this.avatarAssetPath,
    this.isPremature,
    this.livesInRapaNui,
    this.hasRsvRisk,
  });

  final String? name;
  final DateTime? birthDate;
  final String? avatarAssetPath;
  final bool? isPremature;
  final bool? livesInRapaNui;
  final bool? hasRsvRisk;
}

class InitialFamilyDraft {
  const InitialFamilyDraft({
    required this.familyName,
    required this.babyName,
    required this.birthDate,
    required this.ownerName,
    required this.ownerEmail,
    this.avatarAssetPath,
    this.isPremature = false,
    this.livesInRapaNui = false,
    this.hasRsvRisk = false,
  });

  final String familyName;
  final String babyName;
  final DateTime birthDate;
  final String ownerName;
  final String ownerEmail;
  final String? avatarAssetPath;
  final bool isPremature;
  final bool livesInRapaNui;
  final bool hasRsvRisk;
}

class FamilyInvitationDraft {
  const FamilyInvitationDraft({
    required this.familyId,
    required this.babyId,
    required this.babyName,
    required this.name,
    required this.contact,
    required this.role,
    required this.accessDescription,
    required this.canWrite,
  });

  final String familyId;
  final String babyId;
  final String babyName;
  final String name;
  final String contact;
  final String role;
  final String accessDescription;
  final bool canWrite;
}

class JoinedCareCircleDraft {
  const JoinedCareCircleDraft({
    required this.familyId,
    required this.familyName,
    required this.babyId,
    required this.babyName,
    required this.babyBirthDate,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    this.memberRole = 'Acceso pendiente de confirmación',
    this.memberAccessDescription = 'Acceso de solo lectura',
    this.canWrite = false,
  });

  final String familyId;
  final String familyName;
  final String babyId;
  final String babyName;
  final DateTime babyBirthDate;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String memberRole;
  final String memberAccessDescription;
  final bool canWrite;
}
