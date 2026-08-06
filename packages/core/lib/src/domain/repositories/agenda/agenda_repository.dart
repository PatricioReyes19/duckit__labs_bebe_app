import '../../entities/agenda/agenda.dart';

abstract interface class AgendaRepository {
  Future<AgendaOverviewEntity> getOverview(String babyId);

  Future<AgendaEventEntity> create(AgendaEventDraft draft);

  Future<AgendaEventEntity?> update(String id, AgendaEventPatch patch);
}
