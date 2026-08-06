import '../../entities/agenda/agenda.dart';
import '../../repositories/agenda/agenda_repository.dart';

class UpdateAgendaEvent {
  const UpdateAgendaEvent(this._repository);

  final AgendaRepository _repository;

  Future<AgendaEventEntity?> call(String id, AgendaEventPatch patch) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be empty.');
    }
    return _repository.update(id, patch);
  }
}
