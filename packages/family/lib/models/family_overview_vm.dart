enum FamilyMemberStatus {
  active,
  pending,
}

enum FamilyAvatarVariant {
  brand,
  accent,
  information,
  warning,
}

class FamilyOverviewVm {
  const FamilyOverviewVm({
    required this.familyName,
    required this.activeBabyId,
    required this.babies,
    required this.members,
    required this.pendingInvitations,
  });

  final String familyName;
  final String activeBabyId;
  final List<FamilyBabyVm> babies;
  final List<FamilyMemberVm> members;
  final int pendingInvitations;

  FamilyBabyVm get activeBaby {
    return babies.firstWhere((baby) => baby.id == activeBabyId);
  }

  FamilyOverviewVm copyWith({String? activeBabyId}) {
    return FamilyOverviewVm(
      familyName: familyName,
      activeBabyId: activeBabyId ?? this.activeBabyId,
      babies: babies,
      members: members,
      pendingInvitations: pendingInvitations,
    );
  }
}

class FamilyBabyVm {
  const FamilyBabyVm({
    required this.id,
    required this.name,
    required this.ageLabel,
    required this.initials,
    required this.avatarVariant,
  });

  final String id;
  final String name;
  final String ageLabel;
  final String initials;
  final FamilyAvatarVariant avatarVariant;
}

class FamilyMemberVm {
  const FamilyMemberVm({
    required this.id,
    required this.name,
    required this.role,
    required this.accessDescription,
    required this.initials,
    required this.avatarVariant,
    this.status = FamilyMemberStatus.active,
  });

  final String id;
  final String name;
  final String role;
  final String accessDescription;
  final String initials;
  final FamilyAvatarVariant avatarVariant;
  final FamilyMemberStatus status;
}
