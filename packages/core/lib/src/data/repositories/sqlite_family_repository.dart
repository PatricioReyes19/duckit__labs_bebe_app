import 'dart:math';

import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/family/family.dart';
import '../../domain/repositories/family/family_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/family_models.dart';
import '../network/supabase_rest_client.dart';

typedef LocalIdGenerator = String Function(String prefix);

class SqliteFamilyRepository implements FamilyRepository {
  SqliteFamilyRepository(
    this._database, {
    LocalIdGenerator? idGenerator,
    SupabaseRestClient? remoteClient,
  }) : _idGenerator = idGenerator ?? _defaultId,
       _remoteClient = remoteClient;

  final BebeDatabase _database;
  final LocalIdGenerator _idGenerator;
  final SupabaseRestClient? _remoteClient;

  @override
  Future<FamilyOverviewEntity> getCurrent() async {
    final database = await _database.database;
    final families = await database.query(
      BebeDatabaseSchema.families,
      orderBy: 'rowid DESC',
      limit: 1,
    );
    if (families.isEmpty) {
      throw StateError('No local family has been configured.');
    }
    return _overview(database, FamilyModel.fromRow(families.single));
  }

  @override
  Future<FamilyOverviewEntity> setActiveBaby(String babyId) async {
    final database = await _database.database;
    final babyRows = await database.query(
      BebeDatabaseSchema.babies,
      where: 'id = ?',
      whereArgs: [babyId],
      limit: 1,
    );
    if (babyRows.isEmpty) {
      throw StateError('Baby $babyId does not exist.');
    }
    final baby = BabyModel.fromRow(babyRows.single);
    await database.update(
      BebeDatabaseSchema.families,
      {'active_baby_id': babyId},
      where: 'id = ?',
      whereArgs: [baby.familyId],
    );
    final familyRows = await database.query(
      BebeDatabaseSchema.families,
      where: 'id = ?',
      whereArgs: [baby.familyId],
      limit: 1,
    );
    return _overview(database, FamilyModel.fromRow(familyRows.single));
  }

  @override
  Future<FamilyOverviewEntity> createInitialFamily(
    InitialFamilyDraft draft,
  ) async {
    final database = await _database.database;
    final existingRows = await database.query(
      BebeDatabaseSchema.families,
      orderBy: 'rowid DESC',
      limit: 1,
    );
    if (existingRows.isNotEmpty) {
      return _overview(database, FamilyModel.fromRow(existingRows.single));
    }

    final familyId = _idGenerator('family');
    final babyId = _idGenerator('baby');
    final ownerId = _idGenerator('member');
    final family = FamilyModel(
      id: familyId,
      name: draft.familyName.trim(),
      activeBabyId: babyId,
    );
    final baby = BabyModel(
      id: babyId,
      familyId: familyId,
      name: draft.babyName.trim(),
      birthDate: draft.birthDate.toUtc(),
      avatarAssetPath: draft.avatarAssetPath,
    );
    final owner = FamilyMemberModel(
      id: ownerId,
      familyId: familyId,
      name: draft.ownerName.trim(),
      role: 'Administrador/a',
      accessDescription: 'Acceso completo al círculo de cuidado',
      status: FamilyMemberStatus.active,
    );

    await database.transaction((transaction) async {
      await transaction.insert(
        BebeDatabaseSchema.families,
        family.toRow(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
      );
      await transaction.insert(
        BebeDatabaseSchema.babies,
        baby.toRow(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
      );
      await transaction.insert(
        BebeDatabaseSchema.familyMembers,
        owner.toRow(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
      );
      await transaction.insert(
        BebeDatabaseSchema.appSettings,
        {
          'id': 'local',
          'theme_mode': 'system',
          'high_contrast': 0,
          'personal_reminders': 1,
          'family_activity': 1,
          'daily_summary': 0,
          'reduce_motion': 0,
          'wifi_only': 0,
          'account_name': draft.ownerName.trim(),
          'account_email': draft.ownerEmail.trim().toLowerCase(),
          'language': 'Español',
          'time_format': '24 horas',
          'text_size': 'Predeterminado',
        },
        conflictAlgorithm: sqlite.ConflictAlgorithm.ignore,
      );
    });
    return _overview(database, family);
  }

  @override
  Future<BabyEntity> createBaby(BabyDraft draft) async {
    final model = BabyModel(
      id: _idGenerator('baby'),
      familyId: draft.familyId,
      name: draft.name.trim(),
      birthDate: draft.birthDate.toUtc(),
      avatarAssetPath: draft.avatarAssetPath,
    );
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.babies,
      model.toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    return model.toEntity();
  }

  @override
  Future<BabyEntity?> updateBaby(String id, BabyPatch patch) async {
    final database = await _database.database;
    final changes = <String, Object?>{
      if (patch.name != null) 'name': patch.name!.trim(),
      if (patch.birthDate != null)
        'birth_date': patch.birthDate!.toUtc().millisecondsSinceEpoch,
      if (patch.avatarAssetPath != null)
        'avatar_asset_path': patch.avatarAssetPath,
    };
    if (changes.isNotEmpty) {
      await database.update(
        BebeDatabaseSchema.babies,
        changes,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    final rows = await database.query(
      BebeDatabaseSchema.babies,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : BabyModel.fromRow(rows.single).toEntity();
  }

  @override
  Future<FamilyMemberEntity> sendInvitation(FamilyInvitationDraft draft) async {
    final rawContact = draft.contact.trim().toLowerCase();
    final contact = rawContact.contains('@')
        ? rawContact
        : rawContact.replaceAll(RegExp(r'[\s-]'), '');
    final database = await _database.database;
    final existing = await database.query(
      BebeDatabaseSchema.familyMembers,
      where: 'family_id = ? AND lower(contact) = ?',
      whereArgs: [draft.familyId, contact],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      final member = FamilyMemberModel.fromRow(existing.single).toEntity();
      if (member.status == FamilyMemberStatus.active) {
        throw StateError('Esta persona ya forma parte del círculo.');
      }
      throw StateError(
        'Ya existe una invitación pendiente para este contacto.',
      );
    }

    final now = DateTime.now().toUtc();
    final model = FamilyMemberModel(
      id: _idGenerator('member'),
      familyId: draft.familyId,
      name: draft.name.trim().isEmpty ? contact : draft.name.trim(),
      role: draft.role.trim(),
      accessDescription: draft.accessDescription.trim(),
      status: FamilyMemberStatus.pending,
      contact: contact,
      invitationCode: await _newInvitationCode(database),
      invitedAt: now,
      invitationExpiresAt: now.add(const Duration(days: 7)),
    );
    await database.insert(
      BebeDatabaseSchema.familyMembers,
      model.toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    try {
      final client = _remoteClient;
      if (client != null && await client.isAuthenticated()) {
        await client.rpc(
          'create_care_invitation',
          parameters: {
            'p_baby_id': draft.babyId,
            'p_baby_name': draft.babyName,
            'p_invitee_name': model.name,
            'p_contact': contact,
            'p_relationship': model.role,
            'p_access_description': model.accessDescription,
            'p_can_write': draft.canWrite,
            'p_code': model.invitationCode,
          },
        );
      }
    } on Object {
      await database.delete(
        BebeDatabaseSchema.familyMembers,
        where: 'id = ?',
        whereArgs: [model.id],
      );
      rethrow;
    }
    return model.toEntity();
  }

  @override
  Future<FamilyMemberEntity?> resendInvitation(String memberId) async {
    final database = await _database.database;
    final rows = await database.query(
      BebeDatabaseSchema.familyMembers,
      where: 'id = ? AND status = ?',
      whereArgs: [memberId, FamilyMemberStatus.pending.name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final now = DateTime.now().toUtc();
    final current = FamilyMemberModel.fromRow(rows.single);
    final invitationCode = await _newInvitationCode(database);
    final client = _remoteClient;
    if (client != null &&
        current.invitationCode != null &&
        await client.isAuthenticated()) {
      await client.rpc(
        'resend_care_invitation',
        parameters: {
          'p_code': current.invitationCode,
          'p_new_code': invitationCode,
        },
      );
    }
    await database.update(
      BebeDatabaseSchema.familyMembers,
      {
        'invitation_code': invitationCode,
        'invited_at': now.millisecondsSinceEpoch,
        'invitation_expires_at': now
            .add(const Duration(days: 7))
            .millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [memberId],
    );
    final updated = await database.query(
      BebeDatabaseSchema.familyMembers,
      where: 'id = ?',
      whereArgs: [memberId],
      limit: 1,
    );
    return FamilyMemberModel.fromRow(updated.single).toEntity();
  }

  @override
  Future<void> cancelInvitation(String memberId) async {
    final database = await _database.database;
    final rows = await database.query(
      BebeDatabaseSchema.familyMembers,
      columns: ['invitation_code'],
      where: 'id = ? AND status = ?',
      whereArgs: [memberId, FamilyMemberStatus.pending.name],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      final code = rows.single['invitation_code'] as String?;
      final client = _remoteClient;
      if (client != null && code != null && await client.isAuthenticated()) {
        await client.rpc(
          'revoke_care_invitation',
          parameters: {'p_code': code},
        );
      }
    }
    await database.delete(
      BebeDatabaseSchema.familyMembers,
      where: 'id = ? AND status = ?',
      whereArgs: [memberId, FamilyMemberStatus.pending.name],
    );
  }

  @override
  Future<FamilyOverviewEntity> joinCareCircle(
    JoinedCareCircleDraft draft,
  ) async {
    final database = await _database.database;
    final family = FamilyModel(
      id: draft.familyId,
      name: draft.familyName.trim(),
      activeBabyId: draft.babyId,
    );
    final baby = BabyModel(
      id: draft.babyId,
      familyId: draft.familyId,
      name: draft.babyName.trim(),
      birthDate: draft.babyBirthDate.toUtc(),
    );
    final member = FamilyMemberModel(
      id: draft.memberId,
      familyId: draft.familyId,
      name: draft.memberName.trim(),
      role: draft.memberRole.trim(),
      accessDescription: 'Puede acompañar y registrar cuidados',
      status: FamilyMemberStatus.active,
      contact: draft.memberEmail.trim().toLowerCase(),
    );
    await database.transaction((transaction) async {
      await transaction.insert(
        BebeDatabaseSchema.families,
        family.toRow(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.ignore,
      );
      await transaction.insert(
        BebeDatabaseSchema.babies,
        baby.toRow(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.ignore,
      );
      await transaction.insert(
        BebeDatabaseSchema.familyMembers,
        member.toRow(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
      );
      await transaction.insert(
        BebeDatabaseSchema.appSettings,
        {
          'id': 'local',
          'theme_mode': 'system',
          'high_contrast': 0,
          'personal_reminders': 1,
          'family_activity': 1,
          'daily_summary': 0,
          'reduce_motion': 0,
          'wifi_only': 0,
          'account_name': draft.memberName.trim(),
          'account_email': draft.memberEmail.trim().toLowerCase(),
          'language': 'Español',
          'time_format': '24 horas',
          'text_size': 'Predeterminado',
        },
        conflictAlgorithm: sqlite.ConflictAlgorithm.ignore,
      );
    });
    return _overview(database, family);
  }

  static Future<FamilyOverviewEntity> _overview(
    sqlite.Database database,
    FamilyModel family,
  ) async {
    final babyRows = await database.query(
      BebeDatabaseSchema.babies,
      where: 'family_id = ?',
      whereArgs: [family.id],
      orderBy: 'birth_date DESC',
    );
    final memberRows = await database.query(
      BebeDatabaseSchema.familyMembers,
      where: 'family_id = ?',
      whereArgs: [family.id],
      orderBy: 'status, name',
    );
    return FamilyOverviewEntity(
      id: family.id,
      name: family.name,
      activeBabyId: family.activeBabyId,
      babies: babyRows
          .map(BabyModel.fromRow)
          .map((model) => model.toEntity())
          .toList(growable: false),
      members: memberRows
          .map(FamilyMemberModel.fromRow)
          .map((model) => model.toEntity())
          .toList(growable: false),
    );
  }

  static String _defaultId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  static Future<String> _newInvitationCode(sqlite.Database database) async {
    const alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final random = Random.secure();
    for (var attempt = 0; attempt < 10; attempt += 1) {
      final suffix = List.generate(
        6,
        (_) => alphabet[random.nextInt(alphabet.length)],
      ).join();
      final code = 'BEBE-$suffix';
      final rows = await database.query(
        BebeDatabaseSchema.familyMembers,
        columns: ['id'],
        where: 'invitation_code = ?',
        whereArgs: [code],
        limit: 1,
      );
      if (rows.isEmpty) return code;
    }
    throw StateError('No pudimos generar un código de invitación.');
  }
}
