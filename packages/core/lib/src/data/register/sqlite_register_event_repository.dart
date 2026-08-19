import 'dart:async';

import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/register/register.dart';
import '../../domain/repositories/register_event/register_event.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/register_event_model.dart';

typedef RegisterEventIdGenerator = String Function();
typedef RegisterClock = DateTime Function();

/// SQLite source of truth for register events.
///
/// Mutations are immediately visible through [observeByBaby]. Deletes are
/// tombstones so an offline deletion can later be propagated to Supabase.
class SqliteRegisterEventRepository implements RegisterEventRepository {
  SqliteRegisterEventRepository({
    BebeDatabase? database,
    sqlite.DatabaseFactory? databaseFactory,
    String? databasePath,
    RegisterEventIdGenerator? idGenerator,
    RegisterClock? clock,
  }) : _database =
           database ??
           BebeDatabase(
             databaseFactory: databaseFactory,
             databasePath: databasePath,
           ),
       _ownsDatabase = database == null,
       _idGenerator = idGenerator ?? _defaultId,
       _clock = clock ?? DateTime.now;

  static const databaseName = BebeDatabase.databaseName;
  static const tableName = BebeDatabaseSchema.registerEvents;
  static const databaseVersion = BebeDatabaseSchema.version;
  static const syncCursorKey = 'register_events.remote_cursor';
  static const syncCursorIdKey = 'register_events.remote_cursor_id';

  final BebeDatabase _database;
  final bool _ownsDatabase;
  final RegisterEventIdGenerator _idGenerator;
  final RegisterClock _clock;
  final _snapshotChanges = StreamController<String?>.broadcast();
  final _contentChanges = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _contentChanges.stream;

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) async {
    final now = _clock().toUtc();
    final event = RegisteredEvent(
      id: _idGenerator(),
      babyId: draft.babyId.trim(),
      type: draft.type,
      occurredAt: draft.occurredAt.toUtc(),
      createdAt: now,
      updatedAt: now,
      details: draft.details,
      notes: _normalize(draft.notes),
      caregiverId: _normalize(draft.caregiverId),
      syncStatus: RegisterSyncStatus.pending,
      schemaVersion: draft.schemaVersion,
    );
    final database = await _database.database;
    await database.insert(
      tableName,
      RegisterEventModel.fromEntity(event).toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    _notify(event.babyId, contentChanged: true);
    return event;
  }

  @override
  Future<RegisteredEvent?> findById(String id) async {
    final event = await findByIdIncludingDeleted(id);
    return event == null || event.isDeleted ? null : event;
  }

  Future<RegisteredEvent?> findByIdIncludingDeleted(String id) async {
    final database = await _database.database;
    final rows = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : RegisterEventModel.fromRow(rows.single).toEntity();
  }

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async {
    final database = await _database.database;
    final where = StringBuffer('baby_id = ? AND deleted_at IS NULL');
    final whereArgs = <Object?>[babyId];
    if (type != null) {
      where.write(' AND event_type = ?');
      whereArgs.add(_typeToStorage(type));
    }
    final rows = await database.query(
      tableName,
      where: where.toString(),
      whereArgs: whereArgs,
      orderBy: 'occurred_at DESC, created_at DESC',
      limit: limit,
    );
    return rows
        .map(RegisterEventModel.fromRow)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  @override
  Stream<List<RegisteredEvent>> observeByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async* {
    yield await listByBaby(babyId, type: type, limit: limit);
    await for (final changedBabyId in _snapshotChanges.stream) {
      if (changedBabyId == null || changedBabyId == babyId) {
        yield await listByBaby(babyId, type: type, limit: limit);
      }
    }
  }

  @override
  Future<RegisteredEvent?> update(String id, RegisterEventPatch patch) async {
    final existing = await findById(id);
    if (existing == null) return null;
    if (patch.isEmpty) return existing;
    final updated = RegisteredEvent(
      id: existing.id,
      babyId: existing.babyId,
      type: existing.type,
      occurredAt: (patch.occurredAt ?? existing.occurredAt).toUtc(),
      createdAt: existing.createdAt,
      updatedAt: _nextTimestamp(existing.updatedAt),
      details: {...existing.details, ...?patch.details},
      notes: patch.clearNotes
          ? null
          : _normalize(patch.notes) ?? existing.notes,
      caregiverId: patch.clearCaregiverId
          ? null
          : _normalize(patch.caregiverId) ?? existing.caregiverId,
      syncStatus: RegisterSyncStatus.pending,
      schemaVersion: patch.schemaVersion ?? existing.schemaVersion,
    );
    final database = await _database.database;
    await database.update(
      tableName,
      RegisterEventModel.fromEntity(updated).toRow(),
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify(existing.babyId, contentChanged: true);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final existing = await findById(id);
    if (existing == null) return;
    final now = _nextTimestamp(existing.updatedAt);
    final database = await _database.database;
    await database.update(
      tableName,
      {
        'deleted_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
        'sync_status': RegisterSyncStatus.pending.name,
        'sync_error': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify(existing.babyId, contentChanged: true);
  }

  Future<List<RegisteredEvent>> listPending({int limit = 100}) async {
    final database = await _database.database;
    final rows = await database.query(
      tableName,
      where: "sync_status != 'synced'",
      orderBy: 'updated_at ASC',
      limit: limit,
    );
    return rows
        .map(RegisterEventModel.fromRow)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  Future<int> countPending() async {
    final database = await _database.database;
    final rows = await database.rawQuery(
      "SELECT COUNT(*) FROM $tableName WHERE sync_status != 'synced'",
    );
    return sqlite.Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<List<RegisteredEvent>> listByTypeIncludingDeleted(
    RegisterEventType type,
  ) async {
    final database = await _database.database;
    final rows = await database.query(
      tableName,
      where: 'event_type = ?',
      whereArgs: [_typeToStorage(type)],
      orderBy: 'updated_at ASC',
    );
    return rows
        .map(RegisterEventModel.fromRow)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  Future<void> markSyncing(RegisteredEvent event) async {
    await _setSyncStatus(event, RegisterSyncStatus.syncing, error: null);
  }

  Future<void> markSynced(RegisteredEvent event) async {
    await _setSyncStatus(event, RegisterSyncStatus.synced, error: null);
  }

  Future<void> markFailed(RegisteredEvent event, Object error) async {
    await _setSyncStatus(
      event,
      RegisterSyncStatus.failed,
      error: error.toString(),
    );
  }

  Future<void> _setSyncStatus(
    RegisteredEvent event,
    RegisterSyncStatus status, {
    required String? error,
  }) async {
    final database = await _database.database;
    final affected = await database.update(
      tableName,
      {'sync_status': status.name, 'sync_error': error},
      where: 'id = ? AND updated_at = ?',
      whereArgs: [event.id, event.updatedAt.millisecondsSinceEpoch],
    );
    if (affected > 0) {
      _notify(event.babyId, contentChanged: false);
    }
  }

  /// Applies a remote snapshot unless a newer unsynced local mutation exists.
  Future<void> mergeRemote(RegisteredEvent remote) async {
    final existing = await findByIdIncludingDeleted(remote.id);
    if (existing != null && existing.updatedAt.isAfter(remote.updatedAt)) {
      return;
    }
    final synced = RegisteredEvent(
      id: remote.id,
      babyId: remote.babyId,
      type: remote.type,
      occurredAt: remote.occurredAt,
      createdAt: remote.createdAt,
      updatedAt: remote.updatedAt,
      details: remote.details,
      notes: remote.notes,
      caregiverId: remote.caregiverId,
      deletedAt: remote.deletedAt,
      syncStatus: RegisterSyncStatus.synced,
      schemaVersion: remote.schemaVersion,
    );
    final database = await _database.database;
    await database.insert(
      tableName,
      RegisterEventModel.fromEntity(synced).toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
    _notify(remote.babyId, contentChanged: true);
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

  Future<String?> readSyncCursorId() async {
    final database = await _database.database;
    final rows = await database.query(
      BebeDatabaseSchema.syncMetadata,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [syncCursorIdKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final value = (rows.single['value']! as String).trim();
    return value.isEmpty ? null : value;
  }

  Future<void> writeSyncCursor(DateTime value, {String? id}) async {
    final database = await _database.database;
    await database.transaction((transaction) async {
      await transaction.insert(
        BebeDatabaseSchema.syncMetadata,
        {'key': syncCursorKey, 'value': value.toUtc().toIso8601String()},
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
      );
      if (id != null && id.isNotEmpty) {
        await transaction.insert(
          BebeDatabaseSchema.syncMetadata,
          {'key': syncCursorIdKey, 'value': id},
          conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> close() async {
    await _snapshotChanges.close();
    await _contentChanges.close();
    if (_ownsDatabase) await _database.close();
  }

  void _notify(String babyId, {required bool contentChanged}) {
    if (!_snapshotChanges.isClosed) _snapshotChanges.add(babyId);
    if (contentChanged && !_contentChanges.isClosed) {
      _contentChanges.add(null);
    }
  }

  static String _defaultId() =>
      'event-${DateTime.now().toUtc().microsecondsSinceEpoch}';

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static String _typeToStorage(RegisterEventType type) => switch (type) {
    RegisterEventType.feeding => 'feeding',
    RegisterEventType.sleep => 'sleep',
    RegisterEventType.diaper => 'diaper',
    RegisterEventType.clinicalObservation => 'clinical_observation',
    RegisterEventType.medication => 'medication',
    RegisterEventType.measurement => 'measurement',
  };

  DateTime _nextTimestamp(DateTime previous) {
    final candidate = _clock().toUtc();
    return candidate.isAfter(previous)
        ? candidate
        : previous.add(const Duration(milliseconds: 1));
  }
}
