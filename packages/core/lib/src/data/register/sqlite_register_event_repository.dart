import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/register/register.dart';
import '../../domain/repositories/register_event/register_event.dart';

typedef RegisterEventIdGenerator = String Function();
typedef RegisterClock = DateTime Function();

class SqliteRegisterEventRepository implements RegisterEventRepository {
  // A public named argument is intentionally mapped to a private field.
  SqliteRegisterEventRepository({
    sqlite.DatabaseFactory? databaseFactory,
    String? databasePath,
    RegisterEventIdGenerator? idGenerator,
    RegisterClock? clock,
  }) : _databaseFactory = databaseFactory ?? sqlite.databaseFactory,
       // ignore: prefer_initializing_formals
       _databasePath = databasePath,
       _idGenerator = idGenerator ?? _defaultId,
       _clock = clock ?? DateTime.now;

  static const databaseName = 'bebeapp.sqlite';
  static const tableName = 'register_events';
  static const databaseVersion = 1;

  final sqlite.DatabaseFactory _databaseFactory;
  final String? _databasePath;
  final RegisterEventIdGenerator _idGenerator;
  final RegisterClock _clock;

  sqlite.Database? _database;

  Future<sqlite.Database> get _db async {
    final configuredPath = _databasePath;
    final databasePath =
        configuredPath ??
        '${await _databaseFactory.getDatabasesPath()}'
            '${Platform.pathSeparator}$databaseName';
    return _database ??= await _databaseFactory.openDatabase(
      databasePath,
      options: sqlite.OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: (database, _) async {
          await database.execute('''
CREATE TABLE $tableName (
  id TEXT PRIMARY KEY,
  baby_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  occurred_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  caregiver_id TEXT,
  notes TEXT,
  details_json TEXT NOT NULL,
  schema_version INTEGER NOT NULL DEFAULT 1
)
''');
          await database.execute('''
CREATE INDEX idx_register_events_baby_occurred
ON $tableName (baby_id, occurred_at DESC)
''');
          await database.execute('''
CREATE INDEX idx_register_events_type
ON $tableName (event_type)
''');
        },
      ),
    );
  }

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) async {
    final createdAt = _clock().toUtc();
    final event = RegisteredEvent(
      id: _idGenerator(),
      babyId: draft.babyId.trim(),
      type: draft.type,
      occurredAt: draft.occurredAt.toUtc(),
      createdAt: createdAt,
      details: draft.details,
      notes: _normalize(draft.notes),
      caregiverId: _normalize(draft.caregiverId),
      schemaVersion: draft.schemaVersion,
    );
    final database = await _db;
    await database.insert(
      tableName,
      _toRow(event),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    return event;
  }

  @override
  Future<RegisteredEvent?> findById(String id) async {
    final database = await _db;
    final rows = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.single);
  }

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async {
    final database = await _db;
    final where = StringBuffer('baby_id = ?');
    final whereArgs = <Object?>[babyId];
    if (type != null) {
      where.write(' AND event_type = ?');
      whereArgs.add(type.storageKey);
    }
    final rows = await database.query(
      tableName,
      where: where.toString(),
      whereArgs: whereArgs,
      orderBy: 'occurred_at DESC, created_at DESC',
      limit: limit,
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<void> delete(String id) async {
    final database = await _db;
    await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }

  static Map<String, Object?> _toRow(RegisteredEvent event) {
    return {
      'id': event.id,
      'baby_id': event.babyId,
      'event_type': event.type.storageKey,
      'occurred_at': event.occurredAt.millisecondsSinceEpoch,
      'created_at': event.createdAt.millisecondsSinceEpoch,
      'caregiver_id': event.caregiverId,
      'notes': event.notes,
      'details_json': jsonEncode(event.details),
      'schema_version': event.schemaVersion,
    };
  }

  static RegisteredEvent _fromRow(Map<String, Object?> row) {
    final rawDetails = jsonDecode(row['details_json']! as String);
    if (rawDetails is! Map<String, dynamic>) {
      throw const FormatException('Invalid register event details.');
    }
    return RegisteredEvent(
      id: row['id']! as String,
      babyId: row['baby_id']! as String,
      type: RegisterEventType.fromStorageKey(row['event_type']! as String),
      occurredAt: DateTime.fromMillisecondsSinceEpoch(
        row['occurred_at']! as int,
        isUtc: true,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at']! as int,
        isUtc: true,
      ),
      caregiverId: row['caregiver_id'] as String?,
      notes: row['notes'] as String?,
      details: Map<String, Object?>.from(rawDetails),
      schemaVersion: row['schema_version']! as int,
    );
  }

  static String _defaultId() =>
      'register-${DateTime.now().microsecondsSinceEpoch}';

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
