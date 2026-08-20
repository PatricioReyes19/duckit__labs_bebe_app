import 'package:core/core.dart';

export 'package:core/core.dart' show FamilyMemberStatus;

enum FamilyAvatarVariant { brand, accent, information, warning }

class FamilyOverviewVm {
  const FamilyOverviewVm({
    required this.familyId,
    required this.familyName,
    required this.activeBabyId,
    required this.babies,
    required this.members,
    required this.pendingInvitations,
  });

  final String familyId;
  final String familyName;
  final String activeBabyId;
  final List<FamilyBabyVm> babies;
  final List<FamilyMemberVm> members;
  final int pendingInvitations;

  FamilyBabyVm get activeBaby =>
      babies.firstWhere((baby) => baby.id == activeBabyId);

  factory FamilyOverviewVm.fromEntity(
    FamilyOverviewEntity entity, {
    required DateTime referenceDate,
  }) => FamilyOverviewVm(
    familyId: entity.id,
    familyName: entity.name,
    activeBabyId: entity.activeBabyId,
    pendingInvitations: entity.pendingInvitations,
    babies: entity.babies
        .map(
          (baby) => FamilyBabyVm(
            id: baby.id,
            name: baby.name,
            ageLabel: _ageLabel(baby.birthDate, referenceDate),
            initials: _initials(baby.name),
            avatarPath: baby.avatarAssetPath,
            avatarVariant: baby.id == entity.activeBabyId
                ? FamilyAvatarVariant.brand
                : FamilyAvatarVariant.accent,
          ),
        )
        .toList(growable: false),
    members: entity.members
        .map(
          (member) => FamilyMemberVm(
            id: member.id,
            name: member.name,
            role: member.role,
            accessDescription: member.accessDescription,
            canWrite: member.canWrite,
            initials: _initials(member.name),
            avatarVariant: _memberVariant(member.id, member.status),
            status: member.status,
          ),
        )
        .toList(growable: false),
  );

  FamilyOverviewVm copyWith({String? activeBabyId}) => FamilyOverviewVm(
    familyId: familyId,
    familyName: familyName,
    activeBabyId: activeBabyId ?? this.activeBabyId,
    babies: babies,
    members: members,
    pendingInvitations: pendingInvitations,
  );

  static FamilyAvatarVariant _memberVariant(
    String id,
    FamilyMemberStatus status,
  ) {
    if (status == FamilyMemberStatus.pending) {
      return FamilyAvatarVariant.warning;
    }
    return switch (id) {
      'mother' => FamilyAvatarVariant.brand,
      'father' => FamilyAvatarVariant.information,
      _ => FamilyAvatarVariant.accent,
    };
  }

  static String _initials(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  static String _ageLabel(DateTime birthDate, DateTime referenceDate) {
    final birth = birthDate.toLocal();
    final reference = referenceDate.toLocal();
    var months =
        (reference.year - birth.year) * 12 + reference.month - birth.month;
    if (reference.day < birth.day) months--;
    months = months < 0 ? 0 : months;
    final monthAnchor = DateTime(birth.year, birth.month + months, birth.day);
    final days = reference.difference(monthAnchor).inDays.clamp(0, 31);
    if (months == 0) return '$days días';
    if (days == 0) return months == 1 ? '1 mes' : '$months meses';
    return '$months ${months == 1 ? 'mes' : 'meses'} y $days días';
  }
}

class FamilyBabyVm {
  const FamilyBabyVm({
    required this.id,
    required this.name,
    required this.ageLabel,
    required this.initials,
    required this.avatarVariant,
    this.avatarPath,
  });

  final String id;
  final String name;
  final String ageLabel;
  final String initials;
  final FamilyAvatarVariant avatarVariant;
  final String? avatarPath;
}

class FamilyMemberVm {
  const FamilyMemberVm({
    required this.id,
    required this.name,
    required this.role,
    required this.accessDescription,
    required this.canWrite,
    required this.initials,
    required this.avatarVariant,
    this.status = FamilyMemberStatus.active,
  });

  final String id;
  final String name;
  final String role;
  final String accessDescription;
  final bool canWrite;
  final String initials;
  final FamilyAvatarVariant avatarVariant;
  final FamilyMemberStatus status;
}
