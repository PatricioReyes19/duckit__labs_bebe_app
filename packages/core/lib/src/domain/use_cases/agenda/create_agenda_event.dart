import '../../entities/agenda/agenda.dart';
import '../../repositories/agenda/agenda_repository.dart';

class CreateAgendaEvent {
  const CreateAgendaEvent(this._repository);

  final AgendaRepository _repository;

  Future<AgendaEventEntity> call(AgendaEventDraft draft) {
    if (draft.babyId.trim().isEmpty || draft.title.trim().isEmpty) {
      throw ArgumentError('Baby and title are required.');
    }
    return _repository.create(draft);
  }
}
