import 'dart:async';

import '../../domain/entities/health/health.dart';
import '../../domain/repositories/health/health_repository.dart';
import '../repositories/sqlite_health_repository.dart';
import 'background_sync.dart';
import 'health_event_sync_service.dart';

class OfflineFirstHealthRepository implements HealthRepository {
  const OfflineFirstHealthRepository(this._local, this._syncService);

  final SqliteHealthRepository _local;
  final HealthEventSyncService _syncService;

  @override
  Stream<void> get changes => _local.changes;

  @override
  Future<HealthOverviewEntity> getOverview(String babyId) =>
      _local.getOverview(babyId);

  @override
  Future<HealthEventEntity> createEvent(HealthEventDraft draft) async {
    final saved = await _local.createEvent(draft);
    _scheduleSync();
    return saved;
  }

  @override
  Future<HealthEventEntity?> getEvent(String id) => _local.getEvent(id);

  @override
  Future<HealthEventEntity?> updateEvent(
    String id,
    HealthEventPatch patch,
  ) async {
    final updated = await _local.updateEvent(id, patch);
    if (updated != null) _scheduleSync();
    return updated;
  }

  @override
  Future<HealthEventEntity?> rescheduleEvent(
    String id,
    DateTime startsAt,
  ) async {
    final rescheduled = await _local.rescheduleEvent(id, startsAt);
    if (rescheduled != null) _scheduleSync();
    return rescheduled;
  }

  void _scheduleSync() => scheduleBackgroundSync(
    _syncService.synchronize,
    operation: 'Health background synchronization',
  );
}
