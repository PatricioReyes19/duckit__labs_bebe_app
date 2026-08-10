import 'dart:async';

import '../../domain/entities/register/register.dart';
import '../../domain/repositories/register_event/register_event.dart';
import '../register/sqlite_register_event_repository.dart';
import 'register_event_sync_service.dart';

class OfflineFirstRegisterEventRepository implements RegisterEventRepository {
  const OfflineFirstRegisterEventRepository(this._local, this._syncService);

  final SqliteRegisterEventRepository _local;
  final RegisterEventSyncService _syncService;

  @override
  Stream<void> get changes => _local.changes;

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) async {
    final saved = await _local.save(draft);
    unawaited(_syncService.synchronize());
    return saved;
  }

  @override
  Future<RegisteredEvent?> findById(String id) => _local.findById(id);

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) => _local.listByBaby(babyId, type: type, limit: limit);

  @override
  Stream<List<RegisteredEvent>> observeByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) => _local.observeByBaby(babyId, type: type, limit: limit);

  @override
  Future<RegisteredEvent?> update(String id, RegisterEventPatch patch) async {
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
