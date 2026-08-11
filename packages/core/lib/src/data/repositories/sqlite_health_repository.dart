import 'dart:async';

import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/health/health.dart';
import '../../domain/repositories/health/health_repository.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/health_models.dart';

typedef HealthIdGenerator = String Function();

class SqliteHealthRepository implements HealthRepository {
  SqliteHealthRepository(
    this._database, {
    HealthIdGenerator? idGenerator,
    DateTime Function()? clock,
  }) : _idGenerator = idGenerator ?? _defaultId,
       _clock = clock ?? DateTime.now;

  static const syncCursorKey = 'health_events.sync.cursor.v1';

  final BebeDatabase _database;
  final HealthIdGenerator _idGenerator;
  final DateTime Function() _clock;
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

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
    final now = _clock().toUtc();
    final model = HealthEventModel(
      id: _idGenerator(),
      babyId: draft.babyId,
      type: draft.type,
      title: draft.title.trim(),
      description: draft.description.trim(),
      startsAt: draft.startsAt.toUtc(),
      caregiverId: draft.caregiverId,
      status: draft.status,
      createdAt: now,
      updatedAt: now,
      syncStatus: HealthSyncStatus.pending,
    );
    final database = await _database.database;
    await database.insert(
      BebeDatabaseSchema.healthEvents,
      model.toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    _notify();
    return (await _findById(database, model.id))!;
  }

  @override
  Future<HealthEventEntity?> updateEvent(
    String id,
    HealthEventPatch patch,
  ) async {
    final existing = await _findById(await _database.database, id);
    if (existing == null) return null;
    final changes = <String, Object?>{
      if (patch.type != null) 'event_type': patch.type!.name,
      if (patch.title != null) 'title': patch.title!.trim(),
      if (patch.description != null) 'description': patch.description!.trim(),
      if (patch.startsAt != null)
        'starts_at': patch.startsAt!.toUtc().millisecondsSinceEpoch,
      if (patch.caregiverId != null) 'caregiver_id': patch.caregiverId,
      if (patch.clearCaregiver) 'caregiver_id': null,
      if (patch.status != null) 'status': patch.status!.name,
      'updated_at': _nextTimestamp(existing.updatedAt).millisecondsSinceEpoch,
      'sync_status': HealthSyncStatus.pending.name,
      'sync_error': null,
    };
    final database = await _database.database;
    if (changes.isNotEmpty) {
      await database.update(
        BebeDatabaseSchema.healthEvents,
        changes,
        where: 'id = ?',
        whereArgs: [id],
      );
      _notify();
    }
    return _findById(database, id);
  }

  Future<List<HealthEventEntity>> listPending({int limit = 100}) async {
    final database = await _database.database;
    final rows = await database.rawQuery(
      '$_selectBase WHERE h.sync_status != ? '
      'ORDER BY h.updated_at ASC LIMIT ?',
      [HealthSyncStatus.synced.name, limit],
    );
    return rows
        .map(HealthEventModel.fromRow)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  Future<void> markSyncing(HealthEventEntity event) =>
      _setSyncStatus(event, HealthSyncStatus.syncing);

  Future<void> markSynced(HealthEventEntity event) =>
      _setSyncStatus(event, HealthSyncStatus.synced);

  Future<void> markFailed(HealthEventEntity event, Object error) =>
      _setSyncStatus(event, HealthSyncStatus.failed, error: error.toString());

  Future<void> _setSyncStatus(
    HealthEventEntity event,
    HealthSyncStatus status, {
    String? error,
  }) async {
    final database = await _database.database;
    final affected = await database.update(
      BebeDatabaseSchema.healthEvents,
      {'sync_status': status.name, 'sync_error': error},
      where: 'id = ? AND updated_at = ?',
      whereArgs: [event.id, event.updatedAt.millisecondsSinceEpoch],
    );
    if (affected > 0) _notify();
  }

  Future<void> mergeRemote(HealthEventEntity remote) async {
    final database = await _database.database;
    final existing = await _findById(database, remote.id);
    if (existing != null && existing.updatedAt.isAfter(remote.updatedAt)) {
      return;
    }
    final model = HealthEventModel.fromEntity(
      HealthEventEntity(
        id: remote.id,
        babyId: remote.babyId,
        type: remote.type,
        title: remote.title,
        description: remote.description,
        startsAt: remote.startsAt,
        status: remote.status,
        caregiverId: remote.caregiverId,
        createdAt: remote.createdAt,
        updatedAt: remote.updatedAt,
        syncStatus: HealthSyncStatus.synced,
      ),
    );
    await database.insert(
      BebeDatabaseSchema.healthEvents,
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

  DateTime _nextTimestamp(DateTime previous) {
    final candidate = _clock().toUtc();
    return candidate.isAfter(previous)
        ? candidate
        : previous.add(const Duration(milliseconds: 1));
  }

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> close() => _changes.close();
}
