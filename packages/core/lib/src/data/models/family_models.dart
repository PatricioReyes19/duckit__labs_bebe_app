import '../../domain/entities/family/family.dart';

class FamilyModel {
  const FamilyModel({
    required this.id,
    required this.name,
    required this.activeBabyId,
  });

  final String id;
  final String name;
  final String activeBabyId;

  factory FamilyModel.fromEntity(FamilyOverviewEntity entity) => FamilyModel(
    id: entity.id,
    name: entity.name,
    activeBabyId: entity.activeBabyId,
  );

  factory FamilyModel.fromRow(Map<String, Object?> row) => FamilyModel(
    id: row['id']! as String,
    name: row['name']! as String,
    activeBabyId: row['active_baby_id']! as String,
  );

  Map<String, Object?> toRow() => {
    'id': id,
    'name': name,
    'active_baby_id': activeBabyId,
  };
}

class BabyModel {
  const BabyModel({
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

  factory BabyModel.fromEntity(BabyEntity entity) => BabyModel(
    id: entity.id,
    familyId: entity.familyId,
    name: entity.name,
    birthDate: entity.birthDate,
    avatarAssetPath: entity.avatarAssetPath,
    isPremature: entity.isPremature,
    livesInRapaNui: entity.livesInRapaNui,
    hasRsvRisk: entity.hasRsvRisk,
  );

  factory BabyModel.fromRow(Map<String, Object?> row) => BabyModel(
    id: row['id']! as String,
    familyId: row['family_id']! as String,
    name: row['name']! as String,
    birthDate: DateTime.fromMillisecondsSinceEpoch(
      row['birth_date']! as int,
      isUtc: true,
    ),
    avatarAssetPath: row['avatar_asset_path'] as String?,
    isPremature: (row['is_premature'] as int? ?? 0) != 0,
    livesInRapaNui: (row['lives_in_rapa_nui'] as int? ?? 0) != 0,
    hasRsvRisk: (row['has_rsv_risk'] as int? ?? 0) != 0,
  );

  Map<String, Object?> toRow() => {
    'id': id,
    'family_id': familyId,
    'name': name,
    'birth_date': birthDate.toUtc().millisecondsSinceEpoch,
    'avatar_asset_path': avatarAssetPath,
    'is_premature': isPremature ? 1 : 0,
    'lives_in_rapa_nui': livesInRapaNui ? 1 : 0,
    'has_rsv_risk': hasRsvRisk ? 1 : 0,
  };

  BabyEntity toEntity() => BabyEntity(
    id: id,
    familyId: familyId,
    name: name,
    birthDate: birthDate,
    avatarAssetPath: avatarAssetPath,
    isPremature: isPremature,
    livesInRapaNui: livesInRapaNui,
    hasRsvRisk: hasRsvRisk,
  );
}

class FamilyMemberModel {
  const FamilyMemberModel({
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
  final bool canWrite;
  final String? contact;
  final String? invitationCode;
  final DateTime? invitedAt;
  final DateTime? invitationExpiresAt;

  factory FamilyMemberModel.fromEntity(FamilyMemberEntity entity) =>
      FamilyMemberModel(
        id: entity.id,
        familyId: entity.familyId,
        name: entity.name,
        role: entity.role,
        accessDescription: entity.accessDescription,
        status: entity.status,
        canWrite: entity.canWrite,
        contact: entity.contact,
        invitationCode: entity.invitationCode,
        invitedAt: entity.invitedAt,
        invitationExpiresAt: entity.invitationExpiresAt,
      );

  factory FamilyMemberModel.fromRow(Map<String, Object?> row) =>
      FamilyMemberModel(
        id: row['id']! as String,
        familyId: row['family_id']! as String,
        name: row['name']! as String,
        role: row['role']! as String,
        accessDescription: row['access_description']! as String,
        status: switch (row['status']! as String) {
          'active' => FamilyMemberStatus.active,
          'pending' => FamilyMemberStatus.pending,
          final value => throw FormatException('Unknown member status: $value'),
        },
        canWrite: row['can_write'] == 1 || row['can_write'] == true,
        contact: row['contact'] as String?,
        invitationCode: row['invitation_code'] as String?,
        invitedAt: _dateTimeFromEpoch(row['invited_at']),
        invitationExpiresAt: _dateTimeFromEpoch(row['invitation_expires_at']),
      );

  Map<String, Object?> toRow() => {
    'id': id,
    'family_id': familyId,
    'name': name,
    'role': role,
    'access_description': accessDescription,
    'status': status.name,
    'can_write': canWrite ? 1 : 0,
    'contact': contact,
    'invitation_code': invitationCode,
    'invited_at': invitedAt?.toUtc().millisecondsSinceEpoch,
    'invitation_expires_at': invitationExpiresAt
        ?.toUtc()
        .millisecondsSinceEpoch,
  };

  FamilyMemberEntity toEntity() => FamilyMemberEntity(
    id: id,
    familyId: familyId,
    name: name,
    role: role,
    accessDescription: accessDescription,
    status: status,
    canWrite: canWrite,
    contact: contact,
    invitationCode: invitationCode,
    invitedAt: invitedAt,
    invitationExpiresAt: invitationExpiresAt,
  );

  static DateTime? _dateTimeFromEpoch(Object? value) => value is int
      ? DateTime.fromMillisecondsSinceEpoch(value, isUtc: true)
      : null;
}

class FamilySyncSnapshot {
  const FamilySyncSnapshot({required this.overview, required this.updatedAt});

  final FamilyOverviewEntity overview;
  final DateTime updatedAt;

  Map<String, Object?> toRemoteJson() => {
    'family_id': overview.id,
    'family_name': overview.name,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'babies': [
      for (final baby in overview.babies)
        {
          'id': baby.id,
          'display_name': baby.name,
          'birth_date': baby.birthDate.toUtc().toIso8601String(),
          'is_premature': baby.isPremature,
          'lives_in_rapa_nui': baby.livesInRapaNui,
          'has_rsv_risk': baby.hasRsvRisk,
        },
    ],
  };
}
