import 'dart:async';

import '../../entities/agenda/agenda.dart';
import '../../repositories/agenda/agenda_repository.dart';
import '../../repositories/register_event/register_event.dart';

class GetAgendaOverview {
  const GetAgendaOverview(this._repository, this._registerRepository);

  final AgendaRepository _repository;
  final RegisterEventRepository _registerRepository;

  Stream<void> get changes {
    late StreamController<void> controller;
    final subscriptions = <StreamSubscription<void>>[];
    controller = StreamController<void>(
      onListen: () {
        subscriptions
          ..add(_repository.changes.listen(controller.add))
          ..add(_registerRepository.changes.listen(controller.add));
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  Future<AgendaOverviewEntity> call(String babyId) async {
    if (babyId.trim().isEmpty) {
      throw ArgumentError.value(babyId, 'babyId', 'Cannot be empty.');
    }
    final overview = await _repository.getOverview(babyId);
    final records = await _registerRepository.listByBaby(babyId, limit: 250);
    return overview.copyWith(registerEvents: records);
  }
}
