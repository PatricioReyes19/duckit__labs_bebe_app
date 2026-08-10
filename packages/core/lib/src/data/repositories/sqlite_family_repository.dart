import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/family/family.dart';
import '../../domain/repositories/family/family_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/family_models.dart';

typedef LocalIdGenerator = String Function(String prefix);

class SqliteFamilyRepository implements FamilyRepository {
  SqliteFamilyRepository(this._database, {LocalIdGenerator? idGenerator})
    : _idGenerator = idGenerator ?? _defaultId;

  final BebeDatabase _database;
  final LocalIdGenerator _idGenerator;

  @override
  Future<FamilyOverviewEntity> getCurrent() async {
    final database = await _database.database;
    final families = await database.query(
      BebeDatabaseSchema.families,
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
}
