import 'package:sqflite/sqflite.dart' as sqlite;

import '../../domain/entities/register/register.dart';
import '../../domain/repositories/register_event/register_event.dart';
import '../local/bebe_database.dart';
import '../local/bebe_database_schema.dart';
import '../models/register_event_model.dart';

typedef RegisterEventIdGenerator = String Function();
typedef RegisterClock = DateTime Function();

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

  final BebeDatabase _database;
  final bool _ownsDatabase;
  final RegisterEventIdGenerator _idGenerator;
  final RegisterClock _clock;

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) async {
    final event = RegisteredEvent(
      id: _idGenerator(),
      babyId: draft.babyId.trim(),
      type: draft.type,
      occurredAt: draft.occurredAt.toUtc(),
      createdAt: _clock().toUtc(),
      details: draft.details,
      notes: _normalize(draft.notes),
      caregiverId: _normalize(draft.caregiverId),
      schemaVersion: draft.schemaVersion,
    );
    final database = await _database.database;
    await database.insert(
      tableName,
      RegisterEventModel.fromEntity(event).toRow(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
    );
    return event;
  }

  @override
  Future<RegisteredEvent?> findById(String id) async {
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
    final where = StringBuffer('baby_id = ?');
    final whereArgs = <Object?>[babyId];
    if (type != null) {
      final probe = RegisterEventModel(
        id: '',
        babyId: '',
        type: type,
        occurredAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        details: const {},
        schemaVersion: 1,
      ).toRow();
      where.write(' AND event_type = ?');
      whereArgs.add(probe['event_type']);
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
      details: {...existing.details, ...?patch.details},
      notes: patch.clearNotes
          ? null
          : _normalize(patch.notes) ?? existing.notes,
      caregiverId: patch.clearCaregiverId
          ? null
          : _normalize(patch.caregiverId) ?? existing.caregiverId,
      schemaVersion: patch.schemaVersion ?? existing.schemaVersion,
    );
    final database = await _database.database;
    await database.update(
      tableName,
      RegisterEventModel.fromEntity(updated).toRow(),
      where: 'id = ?',
      whereArgs: [id],
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final database = await _database.database;
    await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    if (_ownsDatabase) await _database.close();
  }

  static String _defaultId() =>
      'register-${DateTime.now().microsecondsSinceEpoch}';

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
