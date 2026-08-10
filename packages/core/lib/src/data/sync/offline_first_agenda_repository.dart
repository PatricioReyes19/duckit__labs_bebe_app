import 'dart:async';

import '../../domain/entities/agenda/agenda.dart';
import '../../domain/repositories/agenda/agenda_repository.dart';
import '../repositories/sqlite_agenda_repository.dart';
import 'agenda_event_sync_service.dart';

class OfflineFirstAgendaRepository implements AgendaRepository {
  const OfflineFirstAgendaRepository(this._local, this._syncService);

  final SqliteAgendaRepository _local;
  final AgendaEventSyncService _syncService;

  @override
  Stream<void> get changes => _local.changes;

  @override
  Future<AgendaOverviewEntity> getOverview(String babyId) =>
      _local.getOverview(babyId);

  @override
  Stream<AgendaOverviewEntity> observeOverview(String babyId) =>
      _local.observeOverview(babyId);

  @override
  Future<AgendaEventEntity?> findById(String id) => _local.findById(id);

  @override
  Future<AgendaEventEntity> create(AgendaEventDraft draft) async {
    final saved = await _local.create(draft);
    unawaited(_syncService.synchronize());
    return saved;
  }

  @override
  Future<AgendaEventEntity?> update(String id, AgendaEventPatch patch) async {
    final updated = await _local.update(id, patch);
    if (updated != null) unawaited(_syncService.synchronize());
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    unawaited(_syncService.synchronize());
  }
}
