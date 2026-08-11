import 'dart:async';

import '../../entities/agenda/agenda.dart';
import '../../repositories/agenda/agenda_repository.dart';
import '../../repositories/register_event/register_event.dart';
import '../../repositories/settings/app_settings_repository.dart';

class GetAgendaOverview {
  const GetAgendaOverview(
    this._repository,
    this._registerRepository, [
    this._settingsRepository,
  ]);

  final AgendaRepository _repository;
  final RegisterEventRepository _registerRepository;
  final AppSettingsRepository? _settingsRepository;

  Stream<void> get changes {
    late StreamController<void> controller;
    final subscriptions = <StreamSubscription<void>>[];
    controller = StreamController<void>(
      onListen: () {
        subscriptions
          ..add(_repository.changes.listen(controller.add))
          ..add(_registerRepository.changes.listen(controller.add));
        final settingsRepository = _settingsRepository;
        if (settingsRepository != null) {
          subscriptions.add(settingsRepository.changes.listen(controller.add));
        }
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
    var overview = await _repository.getOverview(babyId);
    final settingsRepository = _settingsRepository;
    if (settingsRepository != null) {
      final settings = await settingsRepository.get();
      overview = overview.copyWith(
        remindersEnabled: settings.personalReminders,
      );
    }
    final records = await _registerRepository.listByBaby(babyId, limit: 250);
    return overview.copyWith(registerEvents: records);
  }
}
