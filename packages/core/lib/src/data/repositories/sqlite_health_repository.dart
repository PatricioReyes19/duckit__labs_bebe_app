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
  static const syncCursorIdKey = 'health_events.sync.cursor_id.v1';

  final BebeDatabase _database;
  final HealthIdGenerator _idGenerator;
  final DateTime Function() _clock;
  final _changes = StreamController<void>.broadcast();

  @override
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
      appointmentKind: draft.appointmentKind,
      reason: draft.reason,
      timezone: draft.timezone,
      attendedAt: draft.attendedAt,
      completedAt: draft.completedAt,
      professionalName: draft.professionalName,
      specialty: draft.specialty,
      facility: draft.facility,
      caregiverIds: draft.caregiverIds,
      notesBeforeVisit: draft.notesBeforeVisit,
      questionsToAsk: draft.questionsToAsk,
      clinicalSummary: draft.clinicalSummary,
      professionalAssessment: draft.professionalAssessment,
      indications: draft.indications,
      medications: draft.medications,
      measurements: draft.measurements,
      attachments: draft.attachments,
      nextAppointmentId: draft.nextAppointmentId,
      createdBy: draft.createdBy,
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
  Future<HealthEventEntity?> getEvent(String id) async =>
      _findById(await _database.database, id);

  @override
  Future<HealthEventEntity?> updateEvent(
    String id,
    HealthEventPatch patch,
  ) async {
    final existing = await _findById(await _database.database, id);
    if (existing == null) return null;
    final updated = _applyPatch(existing, patch);
    final changes = HealthEventModel.fromEntity(updated).toRow()
      ..remove('id')
      ..remove('baby_id')
      ..remove('created_at');
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

  @override
  Future<HealthEventEntity?> rescheduleEvent(
    String id,
    DateTime startsAt,
  ) async {
    final database = await _database.database;
    final existing = await _findById(database, id);
    if (existing == null || !existing.isAppointment) return null;
    final newId = _idGenerator();
    final now = _nextTimestamp(existing.updatedAt);
    final replacement = HealthEventEntity(
      id: newId,
      babyId: existing.babyId,
      type: existing.type,
      title: existing.title,
      description: existing.description,
      startsAt: startsAt.toUtc(),
      status: HealthEventStatus.scheduled,
      appointmentKind: existing.appointmentKind,
      reason: existing.reason,
      timezone: existing.timezone,
      professionalName: existing.professionalName,
      specialty: existing.specialty,
      facility: existing.facility,
      caregiverIds: existing.caregiverIds,
      notesBeforeVisit: existing.notesBeforeVisit,
      questionsToAsk: existing.questionsToAsk,
      createdBy: existing.createdBy,
      caregiverId: existing.caregiverId,
      createdAt: now,
      updatedAt: now,
      syncStatus: HealthSyncStatus.pending,
    );
    final previous = _applyPatch(
      existing,
      HealthEventPatch(
        status: HealthEventStatus.rescheduled,
        nextAppointmentId: newId,
      ),
    );
    await database.transaction((transaction) async {
      await transaction.update(
        BebeDatabaseSchema.healthEvents,
        HealthEventModel.fromEntity(previous).toRow()
          ..remove('id')
          ..remove('baby_id')
          ..remove('created_at'),
        where: 'id = ?',
        whereArgs: [id],
      );
      await transaction.insert(
        BebeDatabaseSchema.healthEvents,
        HealthEventModel.fromEntity(replacement).toRow(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.abort,
      );
    });
    _notify();
    return _findById(database, newId);
  }

  Future<List<HealthEventEntity>> listPending({int limit = 100}) async {
    final database = await _database.database;
    final rows = await database.rawQuery(
      "$_selectBase WHERE h.sync_status != 'synced' "
      'ORDER BY h.updated_at ASC LIMIT ?',
      [limit],
    );
    return rows
        .map(HealthEventModel.fromRow)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  Future<int> countPending() async {
    final database = await _database.database;
    final rows = await database.rawQuery(
      'SELECT COUNT(*) FROM ${BebeDatabaseSchema.healthEvents} '
      "WHERE sync_status != 'synced'",
    );
    return sqlite.Sqflite.firstIntValue(rows) ?? 0;
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
        appointmentKind: remote.appointmentKind,
        reason: remote.reason,
        timezone: remote.timezone,
        attendedAt: remote.attendedAt,
        completedAt: remote.completedAt,
        professionalName: remote.professionalName,
        specialty: remote.specialty,
        facility: remote.facility,
        caregiverIds: remote.caregiverIds,
        notesBeforeVisit: remote.notesBeforeVisit,
        questionsToAsk: remote.questionsToAsk,
        clinicalSummary: remote.clinicalSummary,
        professionalAssessment: remote.professionalAssessment,
        indications: remote.indications,
        medications: remote.medications,
        measurements: remote.measurements,
        attachments: remote.attachments,
        nextAppointmentId: remote.nextAppointmentId,
        createdBy: remote.createdBy,
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

  HealthEventEntity _applyPatch(
    HealthEventEntity existing,
    HealthEventPatch patch,
  ) => HealthEventEntity(
    id: existing.id,
    babyId: existing.babyId,
    type: patch.type ?? existing.type,
    title: patch.title?.trim() ?? existing.title,
    description: patch.description?.trim() ?? existing.description,
    startsAt: patch.startsAt?.toUtc() ?? existing.startsAt,
    caregiverId: patch.clearCaregiver
        ? null
        : patch.caregiverId ?? existing.caregiverId,
    status: patch.status ?? existing.status,
    appointmentKind: patch.appointmentKind ?? existing.appointmentKind,
    reason: patch.reason ?? existing.reason,
    timezone: patch.timezone ?? existing.timezone,
    attendedAt: patch.attendedAt ?? existing.attendedAt,
    completedAt: patch.completedAt ?? existing.completedAt,
    professionalName: patch.professionalName ?? existing.professionalName,
    specialty: patch.specialty ?? existing.specialty,
    facility: patch.facility ?? existing.facility,
    caregiverIds: patch.caregiverIds ?? existing.caregiverIds,
    notesBeforeVisit: patch.notesBeforeVisit ?? existing.notesBeforeVisit,
    questionsToAsk: patch.questionsToAsk ?? existing.questionsToAsk,
    clinicalSummary: patch.clinicalSummary ?? existing.clinicalSummary,
    professionalAssessment:
        patch.professionalAssessment ?? existing.professionalAssessment,
    indications: patch.indications ?? existing.indications,
    medications: patch.medications ?? existing.medications,
    measurements: patch.measurements ?? existing.measurements,
    attachments: patch.attachments ?? existing.attachments,
    nextAppointmentId: patch.nextAppointmentId ?? existing.nextAppointmentId,
    createdBy: patch.createdBy ?? existing.createdBy,
    createdAt: existing.createdAt,
    updatedAt: _nextTimestamp(existing.updatedAt),
    syncStatus: HealthSyncStatus.pending,
  );

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> close() => _changes.close();
}
