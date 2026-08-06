import '../../entities/agenda/agenda.dart';
import '../../repositories/agenda/agenda_repository.dart';

class GetAgendaOverview {
  const GetAgendaOverview(this._repository);

  final AgendaRepository _repository;

  Future<AgendaOverviewEntity> call(String babyId) {
    if (babyId.trim().isEmpty) {
      throw ArgumentError.value(babyId, 'babyId', 'Cannot be empty.');
    }
    return _repository.getOverview(babyId);
  }
}
