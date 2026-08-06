import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/agenda/agenda.dart';
import '../../domain/repositories/agenda/agenda_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/agenda_event_model.dart';

typedef AgendaIdGenerator = String Function();

class SqliteAgendaRepository implements AgendaRepository {
  SqliteAgendaRepository(this._database, {AgendaIdGenerator? idGenerator})
    : _idGenerator = idGenerator ?? _defaultId;

  final BebeDatabase _database;
  final AgendaIdGenerator _idGenerator;

  @override
  Future<AgendaOverviewEntity> getOverview(String babyId) async {
    final database = await _database.database;
    final rows = await database.rawQuery(_selectSql, [babyId]);
    return AgendaOverviewEntity(
      events: rows
          .map(AgendaEventModel.fromRow)
          .map((model) => model.toEntity())
          .toList(growable: false),
      remindersEnabled: true,
      isOffline: false,
    );
  }

  @override
  Future<AgendaEventEntity> create(AgendaEventDraft draft) async {
    final model = AgendaEventModel(
      id: _idGenerator(),
      babyId: draft.babyId,
      category: draft.category,
      title: draft.title.trim(),
      description: draft.description.trim(),
      startsAt: draft.startsAt.toUtc(),
      caregiverId: draft.caregiverId,
      syncStatus: draft.syncStatus,
    );
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.agendaEvents,
      model.toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    return (await _findById(database, model.id))!;
  }

  @override
  Future<AgendaEventEntity?> update(String id, AgendaEventPatch patch) async {
    final changes = <String, Object?>{
      if (patch.category != null) 'category': patch.category!.name,
      if (patch.title != null) 'title': patch.title!.trim(),
      if (patch.description != null) 'description': patch.description!.trim(),
      if (patch.startsAt != null)
        'starts_at': patch.startsAt!.toUtc().millisecondsSinceEpoch,
      if (patch.caregiverId != null) 'caregiver_id': patch.caregiverId,
      if (patch.clearCaregiver) 'caregiver_id': null,
      if (patch.syncStatus != null) 'sync_status': patch.syncStatus!.name,
    };
    final database = await _database.database;
    if (changes.isNotEmpty) {
      await database.update(
        BebeDatabaseSchema.agendaEvents,
        changes,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return _findById(database, id);
  }

  static Future<AgendaEventEntity?> _findById(
    sqlite.Database database,
    String id,
  ) async {
    final rows = await database.rawQuery('$_selectBase WHERE a.id = ?', [id]);
    return rows.isEmpty
        ? null
        : AgendaEventModel.fromRow(rows.single).toEntity();
  }

  static const _selectBase =
      '''
SELECT a.*,
       c.family_id AS caregiver_family_id,
       c.name AS caregiver_name,
       c.role AS caregiver_role,
       c.access_description AS caregiver_access_description,
       c.status AS caregiver_status
FROM ${BebeDatabaseSchema.agendaEvents} a
LEFT JOIN ${BebeDatabaseSchema.familyMembers} c ON c.id = a.caregiver_id
''';
  static const _selectSql =
      '$_selectBase WHERE a.baby_id = ? ORDER BY a.starts_at';

  static String _defaultId() =>
      'agenda-${DateTime.now().microsecondsSinceEpoch}';
}
