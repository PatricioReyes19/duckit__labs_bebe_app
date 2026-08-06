enum FamilyMemberStatus { active, pending }

class BabyEntity {
  const BabyEntity({
    required this.id,
    required this.familyId,
    required this.name,
    required this.birthDate,
    this.avatarAssetPath,
  });

  final String id;
  final String familyId;
  final String name;
  final DateTime birthDate;
  final String? avatarAssetPath;
}

class FamilyMemberEntity {
  const FamilyMemberEntity({
    required this.id,
    required this.familyId,
    required this.name,
    required this.role,
    required this.accessDescription,
    required this.status,
  });

  final String id;
  final String familyId;
  final String name;
  final String role;
  final String accessDescription;
  final FamilyMemberStatus status;
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
  });

  final String familyId;
  final String name;
  final DateTime birthDate;
  final String? avatarAssetPath;
}

class BabyPatch {
  const BabyPatch({this.name, this.birthDate, this.avatarAssetPath});

  final String? name;
  final DateTime? birthDate;
  final String? avatarAssetPath;
}
