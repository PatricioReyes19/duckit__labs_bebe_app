import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/health/health.dart';
import '../../domain/repositories/health/health_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/health_models.dart';

typedef HealthIdGenerator = String Function();

class SqliteHealthRepository implements HealthRepository {
  SqliteHealthRepository(this._database, {HealthIdGenerator? idGenerator})
    : _idGenerator = idGenerator ?? _defaultId;

  final BebeDatabase _database;
  final HealthIdGenerator _idGenerator;

  @override
  Future<HealthOverviewEntity> getOverview(String babyId) async {
    final database = await _database.database;
    final eventRows = await database.rawQuery(_selectSql, [babyId]);
    final measurementRows = await database.query(
      BebeDatabaseSchema.healthMeasurements,
      where: 'baby_id = ?',
      whereArgs: [babyId],
      orderBy: 'recorded_at DESC',
    );
    return HealthOverviewEntity(
      events: eventRows
          .map(HealthEventModel.fromRow)
          .map((model) => model.toEntity())
          .toList(growable: false),
      measurements: measurementRows
          .map(HealthMeasurementModel.fromRow)
          .map((model) => model.toEntity())
          .toList(growable: false),
    );
  }

  @override
  Future<HealthEventEntity> createEvent(HealthEventDraft draft) async {
    final model = HealthEventModel(
      id: _idGenerator(),
      babyId: draft.babyId,
      type: draft.type,
      title: draft.title.trim(),
      description: draft.description.trim(),
      startsAt: draft.startsAt.toUtc(),
      caregiverId: draft.caregiverId,
      status: draft.status,
    );
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.healthEvents,
      model.toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    return (await _findById(database, model.id))!;
  }

  @override
  Future<HealthEventEntity?> updateEvent(
    String id,
    HealthEventPatch patch,
  ) async {
    final changes = <String, Object?>{
      if (patch.type != null) 'event_type': patch.type!.name,
      if (patch.title != null) 'title': patch.title!.trim(),
      if (patch.description != null) 'description': patch.description!.trim(),
      if (patch.startsAt != null)
        'starts_at': patch.startsAt!.toUtc().millisecondsSinceEpoch,
      if (patch.caregiverId != null) 'caregiver_id': patch.caregiverId,
      if (patch.clearCaregiver) 'caregiver_id': null,
      if (patch.status != null) 'status': patch.status!.name,
    };
    final database = await _database.database;
    if (changes.isNotEmpty) {
      await database.update(
        BebeDatabaseSchema.healthEvents,
        changes,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return _findById(database, id);
  }

  static Future<HealthEventEntity?> _findById(
    sqlite.Database database,
    String id,
  ) async {
    final rows = await database.rawQuery('$_selectBase WHERE h.id = ?', [id]);
    return rows.isEmpty
        ? null
        : HealthEventModel.fromRow(rows.single).toEntity();
  }

  static const _selectBase =
      '''
SELECT h.*,
       c.family_id AS caregiver_family_id,
       c.name AS caregiver_name,
       c.role AS caregiver_role,
       c.access_description AS caregiver_access_description,
       c.status AS caregiver_status
FROM ${BebeDatabaseSchema.healthEvents} h
LEFT JOIN ${BebeDatabaseSchema.familyMembers} c ON c.id = h.caregiver_id
''';
  static const _selectSql =
      '$_selectBase WHERE h.baby_id = ? ORDER BY h.starts_at';

  static String _defaultId() =>
      'health-${DateTime.now().microsecondsSinceEpoch}';
}
