import 'dart:async';

import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/agenda/agenda.dart';
import '../../domain/repositories/agenda/agenda_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/agenda_event_model.dart';

typedef AgendaIdGenerator = String Function();
typedef AgendaClock = DateTime Function();

/// SQLite source of truth for scheduled events.
///
/// User-created reminders and reminders derived from register events share the
/// same offline queue. Deletes are tombstones so they also synchronize.
class SqliteAgendaRepository implements AgendaRepository {
  SqliteAgendaRepository(
    this._database, {
    AgendaIdGenerator? idGenerator,
    AgendaClock? clock,
  }) : _idGenerator = idGenerator ?? _defaultId,
       _clock = clock ?? DateTime.now;

  static const syncCursorKey = 'agenda_events.remote_cursor';

  final BebeDatabase _database;
  final AgendaIdGenerator _idGenerator;
  final AgendaClock _clock;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<AgendaOverviewEntity> getOverview(String babyId) async {
    final database = await _database.database;
    final rows = await database.rawQuery(_selectSql, [babyId]);
    final events = rows
        .map(AgendaEventModel.fromRow)
        .map((model) => model.toEntity())
        .toList(growable: false);
    return AgendaOverviewEntity(
      events: events,
      remindersEnabled: true,
      isOffline: false,
    );
  }

  @override
  Stream<AgendaOverviewEntity> observeOverview(String babyId) async* {
    yield await getOverview(babyId);
    await for (final _ in changes) {
      yield await getOverview(babyId);
    }
  }

  @override
  Future<AgendaEventEntity?> findById(String id) async {
    final event = await findByIdIncludingDeleted(id);
    return event == null || event.isDeleted ? null : event;
  }

  Future<AgendaEventEntity?> findByIdIncludingDeleted(String id) async {
    final database = await _database.database;
    return _findById(database, id);
  }

  @override
  Future<AgendaEventEntity> create(AgendaEventDraft draft) async {
    final now = _clock().toUtc();
    final model = AgendaEventModel(
      id: draft.id?.trim().isNotEmpty == true
          ? draft.id!.trim()
          : _idGenerator(),
      babyId: draft.babyId.trim(),
      category: draft.category,
      title: draft.title.trim(),
      description: draft.description.trim(),
      startsAt: draft.startsAt.toUtc(),
      createdAt: now,
      updatedAt: now,
      caregiverId: _normalize(draft.caregiverId),
      sourceRegisterEventId: _normalize(draft.sourceRegisterEventId),
      syncStatus: AgendaSyncStatus.pending,
    );
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.agendaEvents,
      model.toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    _notify();
    return (await _findById(database, model.id))!;
  }

  /// Idempotently creates or refreshes an agenda item derived from a register
  /// event. Its deterministic id prevents duplicate doses across devices.
  Future<AgendaEventEntity> upsertDerived(AgendaEventDraft draft) async {
    final id = draft.id;
    if (id == null || id.trim().isEmpty) {
      throw ArgumentError.value(id, 'draft.id', 'Derived events need an id.');
    }
    final existing = await findByIdIncludingDeleted(id);
    if (existing == null) return create(draft);
    final normalized = AgendaEventModel(
      id: existing.id,
      babyId: draft.babyId.trim(),
      category: draft.category,
      title: draft.title.trim(),
      description: draft.description.trim(),
      startsAt: draft.startsAt.toUtc(),
      createdAt: existing.createdAt,
      updatedAt: _nextTimestamp(existing.updatedAt),
      caregiverId: _normalize(draft.caregiverId),
      sourceRegisterEventId: _normalize(draft.sourceRegisterEventId),
      syncStatus: AgendaSyncStatus.pending,
    );
    if (!existing.isDeleted &&
        existing.babyId == normalized.babyId &&
        existing.category == normalized.category &&
        existing.title == normalized.title &&
        existing.description == normalized.description &&
        existing.startsAt.toUtc() == normalized.startsAt &&
        existing.caregiverId == normalized.caregiverId) {
      return existing;
    }
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.agendaEvents,
      normalized.toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
    _notify();
    return (await _findById(database, normalized.id))!;
  }

  @override
  Future<AgendaEventEntity?> update(String id, AgendaEventPatch patch) async {
    final existing = await findById(id);
    if (existing == null) return null;
    final changes = <String, Object?>{
      if (patch.category != null) 'category': patch.category!.name,
      if (patch.title != null) 'title': patch.title!.trim(),
      if (patch.description != null) 'description': patch.description!.trim(),
      if (patch.startsAt != null)
        'starts_at': patch.startsAt!.toUtc().millisecondsSinceEpoch,
      if (patch.caregiverId != null) 'caregiver_id': patch.caregiverId,
      if (patch.clearCaregiver) 'caregiver_id': null,
      'updated_at': _nextTimestamp(existing.updatedAt).millisecondsSinceEpoch,
      'sync_status': AgendaSyncStatus.pending.name,
      'sync_error': null,
    };
    final database = await _database.database;
    await database.update(
      BebeDatabaseSchema.agendaEvents,
      changes,
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify();
    return _findById(database, id);
  }

  @override
  Future<void> delete(String id) async {
    final existing = await findById(id);
    if (existing == null) return;
    final now = _nextTimestamp(existing.updatedAt).millisecondsSinceEpoch;
    final database = await _database.database;
    await database.update(
      BebeDatabaseSchema.agendaEvents,
      {
        'deleted_at': now,
        'updated_at': now,
        'sync_status': AgendaSyncStatus.pending.name,
        'sync_error': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify();
  }

  Future<List<AgendaEventEntity>> listDerivedBySource(
    String sourceRegisterEventId,
  ) async {
    final database = await _database.database;
    final rows = await database.rawQuery(
      '$_selectBase WHERE a.source_register_event_id = ? '
      'ORDER BY a.starts_at ASC, a.id ASC',
      [sourceRegisterEventId],
    );
    return rows
        .map(AgendaEventModel.fromRow)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  Future<bool> deleteDerivedExcept(
    String sourceRegisterEventId,
    Set<String?> retainedIds,
  ) async {
    final database = await _database.database;
    final affected = await database.transaction((transaction) async {
      final retained = retainedIds.whereType<String>().toList(growable: false);
      final exclusion = retained.isEmpty
          ? ''
          : ' AND id NOT IN (${List.filled(retained.length, '?').join(',')})';
      final where =
          'source_register_event_id = ? AND deleted_at IS NULL$exclusion';
      final whereArgs = <Object?>[sourceRegisterEventId, ...retained];
      final rows = await transaction.query(
        BebeDatabaseSchema.agendaEvents,
        columns: ['updated_at'],
        where: where,
        whereArgs: whereArgs,
      );
      if (rows.isEmpty) return 0;
      final latest = rows
          .map((row) => row['updated_at']! as int)
          .reduce((first, second) => first > second ? first : second);
      final candidate = _clock().toUtc().millisecondsSinceEpoch;
      final timestamp = candidate > latest ? candidate : latest + 1;
      return transaction.update(
        BebeDatabaseSchema.agendaEvents,
        {
          'deleted_at': timestamp,
          'updated_at': timestamp,
          'sync_status': AgendaSyncStatus.pending.name,
          'sync_error': null,
        },
        where: where,
        whereArgs: whereArgs,
      );
    });
    if (affected > 0) _notify();
    return affected > 0;
  }

  Future<List<AgendaEventEntity>> listPending({int limit = 100}) async {
    final database = await _database.database;
    final rows = await database.rawQuery(
      '$_selectBase WHERE a.sync_status != ? '
      'ORDER BY a.updated_at ASC LIMIT ?',
      [AgendaSyncStatus.synced.name, limit],
    );
    return rows
        .map(AgendaEventModel.fromRow)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  Future<int> countPending() async {
    final database = await _database.database;
    final rows = await database.rawQuery(
      'SELECT COUNT(*) FROM ${BebeDatabaseSchema.agendaEvents} '
      'WHERE sync_status != ?',
      [AgendaSyncStatus.synced.name],
    );
    return sqlite.Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> markSyncing(AgendaEventEntity event) =>
      _setSyncStatus(event, AgendaSyncStatus.syncing);

  Future<void> markSynced(AgendaEventEntity event) =>
      _setSyncStatus(event, AgendaSyncStatus.synced);

  Future<void> markFailed(AgendaEventEntity event, Object error) =>
      _setSyncStatus(event, AgendaSyncStatus.failed, error: error.toString());

  Future<void> _setSyncStatus(
    AgendaEventEntity event,
    AgendaSyncStatus status, {
    String? error,
  }) async {
    final database = await _database.database;
    final affected = await database.update(
      BebeDatabaseSchema.agendaEvents,
      {'sync_status': status.name, 'sync_error': error},
      where: 'id = ? AND updated_at = ?',
      whereArgs: [event.id, event.updatedAt.millisecondsSinceEpoch],
    );
    if (affected > 0) _notify();
  }

  Future<void> mergeRemote(AgendaEventEntity remote) async {
    final existing = await findByIdIncludingDeleted(remote.id);
    if (existing != null && existing.updatedAt.isAfter(remote.updatedAt)) {
      return;
    }
    final model = AgendaEventModel(
      id: remote.id,
      babyId: remote.babyId,
      category: remote.category,
      title: remote.title,
      description: remote.description,
      startsAt: remote.startsAt,
      createdAt: remote.createdAt,
      updatedAt: remote.updatedAt,
      deletedAt: remote.deletedAt,
      caregiverId: remote.caregiverId,
      sourceRegisterEventId: remote.sourceRegisterEventId,
      syncStatus: AgendaSyncStatus.synced,
    );
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.agendaEvents,
      model.toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
    _notify();
  }

  Future<DateTime?> readSyncCursor() async {
    final database = await _database.database;
    final rows = await database.query(
      BebeDatabaseSchema.syncMetadata,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [syncCursorKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.single['value']! as String)?.toUtc();
  }

  Future<void> writeSyncCursor(DateTime value) async {
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.syncMetadata,
      {'key': syncCursorKey, 'value': value.toUtc().toIso8601String()},
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
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
      '$_selectBase WHERE a.baby_id = ? AND a.deleted_at IS NULL '
      'ORDER BY a.starts_at';

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  static String _defaultId() =>
      'agenda-${DateTime.now().toUtc().microsecondsSinceEpoch}';

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  DateTime _nextTimestamp(DateTime previous) {
    final candidate = _clock().toUtc();
    return candidate.isAfter(previous)
        ? candidate
        : previous.add(const Duration(milliseconds: 1));
  }
}
