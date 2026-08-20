import 'dart:async';
import 'dart:math';

import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/family/family.dart';
import '../../domain/repositories/family/family_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/family_models.dart';
import '../datasources/remote/family_remote_data_source.dart';

typedef LocalIdGenerator = String Function(String prefix);

class SqliteFamilyRepository implements FamilyRepository {
  SqliteFamilyRepository(
    this._database, {
    LocalIdGenerator? idGenerator,
    this._remoteDataSource,
    DateTime Function()? clock,
  }) : _idGenerator = idGenerator ?? _defaultId,
       _clock = clock ?? DateTime.now;

  final BebeDatabase _database;
  final LocalIdGenerator _idGenerator;
  final FamilyRemoteDataSource? _remoteDataSource;
  final DateTime Function() _clock;
  final StreamController<String> _activeBabyChanges =
      StreamController<String>.broadcast();
  String? _activeFamilyId;

  @override
  Stream<String> get activeBabyChanges => _activeBabyChanges.stream;

  Future<bool> containsBaby(String babyId) async {
    final database = await _database.database;
    final rows = await database.query(
      BebeDatabaseSchema.babies,
      columns: const ['id'],
      where: 'id = ?',
      whereArgs: [babyId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<FamilyOverviewEntity>> listAvailable() async {
    final database = await _database.database;
    final rows = await database.query(
      BebeDatabaseSchema.families,
      orderBy: 'rowid ASC',
    );
    final families = <FamilyOverviewEntity>[];
    for (final row in rows) {
      families.add(await _overview(database, FamilyModel.fromRow(row)));
    }
    return List.unmodifiable(families);
  }

  @override
  Future<FamilyOverviewEntity> getCurrent() async {
    final database = await _database.database;
    final activeFamilyId = _activeFamilyId;
    if (activeFamilyId != null) {
      final selected = await database.query(
        BebeDatabaseSchema.families,
        where: 'id = ?',
        whereArgs: [activeFamilyId],
        limit: 1,
      );
      if (selected.isNotEmpty) {
        return _overview(database, FamilyModel.fromRow(selected.single));
      }
      _activeFamilyId = null;
    }
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
    _activeFamilyId = baby.familyId;
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
    final overview = await _overview(
      database,
      FamilyModel.fromRow(familyRows.single),
    );
    _activeBabyChanges.add(babyId);
    return overview;
  }

  @override
  Future<FamilyOverviewEntity> createInitialFamily(
    InitialFamilyDraft draft,
  ) async {
    final babyName = draft.babyName.trim();
    final familyName = draft.familyName.trim();
    if (babyName.isEmpty) {
      throw ArgumentError.value(
        draft.babyName,
        'babyName',
        'No puede estar vacío.',
      );
    }
    if (familyName.isEmpty) {
      throw ArgumentError.value(
        draft.familyName,
        'familyName',
        'No puede estar vacío.',
      );
    }
    final database = await _database.database;
    final existingRows = await database.query(
      BebeDatabaseSchema.families,
      orderBy: 'rowid DESC',
      limit: 1,
    );
    if (existingRows.isNotEmpty) {
      final existingFamily = FamilyModel.fromRow(existingRows.single);
      await database.transaction((transaction) async {
        final babyRows = await transaction.query(
          BebeDatabaseSchema.babies,
          where: 'id = ? AND family_id = ?',
          whereArgs: [existingFamily.activeBabyId, existingFamily.id],
          limit: 1,
        );
        if (babyRows.isEmpty) {
          throw StateError(
            'La familia local ${existingFamily.id} no contiene a su bebé activo '
            '${existingFamily.activeBabyId}.',
          );
        }
        await transaction.update(
          BebeDatabaseSchema.families,
          {'name': familyName},
          where: 'id = ?',
          whereArgs: [existingFamily.id],
        );
        await transaction.update(
          BebeDatabaseSchema.babies,
          {
            'name': babyName,
            'birth_date': draft.birthDate.toUtc().millisecondsSinceEpoch,
            if (draft.avatarAssetPath != null)
              'avatar_asset_path': draft.avatarAssetPath,
          },
          where: 'id = ?',
          whereArgs: [existingFamily.activeBabyId],
        );
        await transaction.update(
          BebeDatabaseSchema.familyMembers,
          {'name': draft.ownerName.trim()},
          where: 'family_id = ? AND status = ?',
          whereArgs: [existingFamily.id, FamilyMemberStatus.active.name],
        );
        await transaction.update(
          BebeDatabaseSchema.appSettings,
          {
            'account_name': draft.ownerName.trim(),
            'account_email': draft.ownerEmail.trim().toLowerCase(),
          },
          where: 'id = ?',
          whereArgs: ['local'],
        );
        await _markSnapshotPending(transaction);
      });
      return _overview(
        database,
        FamilyModel(
          id: existingFamily.id,
          name: familyName,
          activeBabyId: existingFamily.activeBabyId,
        ),
      );
    }

    final familyId = _idGenerator('family');
    final babyId = _idGenerator('baby');
    final ownerId = _idGenerator('member');
    final family = FamilyModel(
      id: familyId,
      name: familyName,
      activeBabyId: babyId,
    );
    final baby = BabyModel(
      id: babyId,
      familyId: familyId,
      name: babyName,
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
      await _markSnapshotPending(transaction);
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
    await _markSnapshotPending(database);
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
      await _markSnapshotPending(database);
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
    final remote = _remoteDataSource;
    if (remote != null &&
        remote.isConfigured &&
        !await remote.isAuthenticated()) {
      throw StateError('Inicia sesión para enviar la invitación.');
    }
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
      if (remote != null && await remote.isAuthenticated()) {
        await remote.createInvitation({
          'p_baby_id': draft.babyId,
          'p_baby_name': draft.babyName,
          'p_invitee_name': model.name,
          'p_contact': contact,
          'p_relationship': model.role,
          'p_access_description': model.accessDescription,
          'p_can_write': draft.canWrite,
          'p_code': model.invitationCode,
        });
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
    final remote = _remoteDataSource;
    if (remote != null &&
        current.invitationCode != null &&
        await remote.isAuthenticated()) {
      await remote.resendInvitation(
        code: current.invitationCode!,
        newCode: invitationCode,
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
      final remote = _remoteDataSource;
      if (remote != null && code != null && await remote.isAuthenticated()) {
        await remote.revokeInvitation(code);
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
      await _writeSyncMetadata(
        transaction,
        _familySyncedAtKey,
        _clock().toUtc().toIso8601String(),
      );
    });
    return _overview(database, family);
  }

  /// Returns a complete local family aggregate only when it has never been
  /// uploaded or a family/baby mutation marked it as pending.
  Future<FamilySyncSnapshot?> readPendingSnapshot({bool force = false}) async {
    final database = await _database.database;
    final pendingAt = await _readSyncMetadata(database, _familyPendingAtKey);
    final syncedAt = await _readSyncMetadata(database, _familySyncedAtKey);
    if (!force && pendingAt == null && syncedAt != null) return null;
    final localFamilies = await database.query(
      BebeDatabaseSchema.families,
      columns: const ['id'],
      limit: 1,
    );
    if (localFamilies.isEmpty) return null;
    final overview = await getCurrent();
    final updatedAt = pendingAt == null || force
        ? _clock().toUtc()
        : DateTime.parse(pendingAt).toUtc();
    if (pendingAt == null || force) {
      await _writeSyncMetadata(
        database,
        _familyPendingAtKey,
        updatedAt.toIso8601String(),
      );
    }
    return FamilySyncSnapshot(overview: overview, updatedAt: updatedAt);
  }

  Future<void> markSnapshotSynced({
    required FamilySyncSnapshot attempted,
    required FamilySyncSnapshot accepted,
  }) async {
    final database = await _database.database;
    await database.transaction((transaction) async {
      await _writeSyncMetadata(
        transaction,
        _familySyncedAtKey,
        accepted.updatedAt.toUtc().toIso8601String(),
      );
      await transaction.delete(
        BebeDatabaseSchema.syncMetadata,
        where: 'key = ? AND value = ?',
        whereArgs: [
          _familyPendingAtKey,
          attempted.updatedAt.toUtc().toIso8601String(),
        ],
      );
    });
  }

  /// Merges server aggregates without replacing the device-only avatar path or
  /// the active baby selection when that baby still exists.
  Future<void> mergeRemote(List<FamilySyncSnapshot> snapshots) async {
    if (snapshots.isEmpty) return;
    final database = await _database.database;
    final pendingAtValue = await _readSyncMetadata(
      database,
      _familyPendingAtKey,
    );
    final pendingAt = pendingAtValue == null
        ? null
        : DateTime.tryParse(pendingAtValue)?.toUtc();
    await database.transaction((transaction) async {
      for (final snapshot in snapshots) {
        if (pendingAt != null && pendingAt.isAfter(snapshot.updatedAt)) {
          continue;
        }
        final overview = snapshot.overview;
        final existingFamily = await transaction.query(
          BebeDatabaseSchema.families,
          where: 'id = ?',
          whereArgs: [overview.id],
          limit: 1,
        );
        final remoteBabyIds = overview.babies.map((baby) => baby.id).toSet();
        final existingActiveBabyId = existingFamily.isEmpty
            ? null
            : existingFamily.single['active_baby_id'] as String?;
        final activeBabyId = remoteBabyIds.contains(existingActiveBabyId)
            ? existingActiveBabyId!
            : overview.activeBabyId;
        final familyRow = FamilyModel(
          id: overview.id,
          name: overview.name,
          activeBabyId: activeBabyId,
        ).toRow();
        await transaction.insert(
          BebeDatabaseSchema.families,
          familyRow,
          conflictAlgorithm: sqlite.ConflictAlgorithm.ignore,
        );
        await transaction.update(
          BebeDatabaseSchema.families,
          familyRow,
          where: 'id = ?',
          whereArgs: [overview.id],
        );
        for (final baby in overview.babies) {
          final existing = await transaction.query(
            BebeDatabaseSchema.babies,
            columns: ['avatar_asset_path'],
            where: 'id = ?',
            whereArgs: [baby.id],
            limit: 1,
          );
          final babyRow = BabyModel(
            id: baby.id,
            familyId: overview.id,
            name: baby.name,
            birthDate: baby.birthDate,
            avatarAssetPath: existing.isEmpty
                ? null
                : existing.single['avatar_asset_path'] as String?,
          ).toRow();
          await transaction.insert(
            BebeDatabaseSchema.babies,
            babyRow,
            conflictAlgorithm: sqlite.ConflictAlgorithm.ignore,
          );
          await transaction.update(
            BebeDatabaseSchema.babies,
            babyRow,
            where: 'id = ?',
            whereArgs: [baby.id],
          );
        }
        for (final member in overview.members) {
          final contact = member.contact?.trim().toLowerCase();
          if (contact != null && contact.isNotEmpty) {
            await transaction.delete(
              BebeDatabaseSchema.familyMembers,
              where: 'family_id = ? AND status = ? AND lower(contact) = ?',
              whereArgs: [
                overview.id,
                FamilyMemberStatus.pending.name,
                contact,
              ],
            );
          }
          final memberRow = FamilyMemberModel.fromEntity(member).toRow();
          await transaction.insert(
            BebeDatabaseSchema.familyMembers,
            memberRow,
            conflictAlgorithm: sqlite.ConflictAlgorithm.ignore,
          );
          await transaction.update(
            BebeDatabaseSchema.familyMembers,
            memberRow,
            where: 'id = ?',
            whereArgs: [member.id],
          );
        }
        await _writeSyncMetadata(
          transaction,
          _familySyncedAtKey,
          snapshot.updatedAt.toUtc().toIso8601String(),
        );
      }
    });
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

  Future<void> _markSnapshotPending(sqlite.DatabaseExecutor database) =>
      _writeSyncMetadata(
        database,
        _familyPendingAtKey,
        _clock().toUtc().toIso8601String(),
      );

  static Future<String?> _readSyncMetadata(
    sqlite.DatabaseExecutor database,
    String key,
  ) async {
    final rows = await database.query(
      BebeDatabaseSchema.syncMetadata,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.single['value'] as String?;
  }

  static Future<void> _writeSyncMetadata(
    sqlite.DatabaseExecutor database,
    String key,
    String value,
  ) => database.insert(
    BebeDatabaseSchema.syncMetadata,
    {'key': key, 'value': value},
    conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
  );

  static const _familyPendingAtKey = 'family.snapshot.pending_at';
  static const _familySyncedAtKey = 'family.snapshot.synced_at';
}
