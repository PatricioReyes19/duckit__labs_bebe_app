import '../../entities/agenda/agenda.dart';

abstract interface class AgendaRepository {
  Stream<void> get changes;

  Future<AgendaOverviewEntity> getOverview(String babyId);

  Stream<AgendaOverviewEntity> observeOverview(String babyId);

  Future<AgendaEventEntity?> findById(String id);

  Future<AgendaEventEntity> create(AgendaEventDraft draft);

  Future<AgendaEventEntity?> update(String id, AgendaEventPatch patch);

  Future<void> delete(String id);
}
