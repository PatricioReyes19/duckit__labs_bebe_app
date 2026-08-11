import 'dart:async';

import '../../domain/entities/health/health.dart';
import '../../domain/repositories/health/health_repository.dart';
import '../repositories/sqlite_health_repository.dart';
import 'health_event_sync_service.dart';

class OfflineFirstHealthRepository implements HealthRepository {
  const OfflineFirstHealthRepository(this._local, this._syncService);

  final SqliteHealthRepository _local;
  final HealthEventSyncService _syncService;

  @override
  Future<HealthOverviewEntity> getOverview(String babyId) =>
      _local.getOverview(babyId);

  @override
  Future<HealthEventEntity> createEvent(HealthEventDraft draft) async {
    final saved = await _local.createEvent(draft);
    unawaited(_syncService.synchronize());
    return saved;
  }

  @override
  Future<HealthEventEntity?> updateEvent(
    String id,
    HealthEventPatch patch,
  ) async {
    final updated = await _local.updateEvent(id, patch);
    if (updated != null) unawaited(_syncService.synchronize());
    return updated;
  }
}
