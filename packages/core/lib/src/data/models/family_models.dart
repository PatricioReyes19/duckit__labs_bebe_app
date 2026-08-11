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
  });

  final String id;
  final String familyId;
  final String name;
  final DateTime birthDate;
  final String? avatarAssetPath;

  factory BabyModel.fromEntity(BabyEntity entity) => BabyModel(
    id: entity.id,
    familyId: entity.familyId,
    name: entity.name,
    birthDate: entity.birthDate,
    avatarAssetPath: entity.avatarAssetPath,
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
  );

  Map<String, Object?> toRow() => {
    'id': id,
    'family_id': familyId,
    'name': name,
    'birth_date': birthDate.toUtc().millisecondsSinceEpoch,
    'avatar_asset_path': avatarAssetPath,
  };

  BabyEntity toEntity() => BabyEntity(
    id: id,
    familyId: familyId,
    name: name,
    birthDate: birthDate,
    avatarAssetPath: avatarAssetPath,
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
    contact: contact,
    invitationCode: invitationCode,
    invitedAt: invitedAt,
    invitationExpiresAt: invitationExpiresAt,
  );

  static DateTime? _dateTimeFromEpoch(Object? value) => value is int
      ? DateTime.fromMillisecondsSinceEpoch(value, isUtc: true)
      : null;
}
