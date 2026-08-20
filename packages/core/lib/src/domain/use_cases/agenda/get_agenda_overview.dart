import 'dart:async';

import '../../entities/agenda/agenda.dart';
import '../../entities/health/health.dart';
import '../../entities/register/register.dart';
import '../../repositories/agenda/agenda_repository.dart';
import '../../repositories/register_event/register_event.dart';
import '../../repositories/settings/app_settings_repository.dart';
import '../../repositories/health/health_repository.dart';

class GetAgendaOverview {
  const GetAgendaOverview(
    this._repository,
    this._registerRepository, [
    this._settingsRepository,
    this._healthRepository,
  ]);

  final AgendaRepository _repository;
  final RegisterEventRepository _registerRepository;
  final AppSettingsRepository? _settingsRepository;
  final HealthRepository? _healthRepository;

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
        final healthRepository = _healthRepository;
        if (healthRepository != null) {
          subscriptions.add(healthRepository.changes.listen(controller.add));
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
    final results = await Future.wait<Object>([
      _registerRepository.listByBaby(babyId, limit: 250),
      if (_healthRepository != null) _healthRepository.getOverview(babyId),
    ]);
    final records = results.first as List<RegisteredEvent>;
    final health = results.length == 2
        ? results[1] as HealthOverviewEntity
        : const HealthOverviewEntity(events: [], measurements: []);
    final now = DateTime.now();
    final projectedAppointments = health.events
        .where((event) => _isVisibleInAgenda(event, now))
        .map(
          (event) => AgendaEventEntity(
            id: 'health:${event.id}',
            babyId: event.babyId,
            category: AgendaCategory.controls,
            title: event.title,
            description: _appointmentDescription(event),
            startsAt: event.startsAt,
            caregiver: event.caregiver,
            caregiverId: event.caregiverId,
            syncStatus: switch (event.syncStatus) {
              HealthSyncStatus.synced => AgendaSyncStatus.synced,
              HealthSyncStatus.pending => AgendaSyncStatus.pending,
              HealthSyncStatus.syncing => AgendaSyncStatus.syncing,
              HealthSyncStatus.failed => AgendaSyncStatus.failed,
            },
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
          ),
        );
    return overview.copyWith(
      events: [...overview.events, ...projectedAppointments],
      registerEvents: records,
    );
  }

  static String _appointmentDescription(HealthEventEntity event) {
    final state = switch (event.effectiveStatus(DateTime.now())) {
      HealthEventStatus.draft => 'Borrador',
      HealthEventStatus.scheduled => 'Programado',
      HealthEventStatus.due => 'Corresponde hoy',
      HealthEventStatus.attendancePending => 'Confirma asistencia',
      HealthEventStatus.attendedPendingSummary => 'Resumen pendiente',
      HealthEventStatus.completed => 'Completado',
      HealthEventStatus.notAttended => 'No asistieron',
      HealthEventStatus.cancelled => 'Cancelado',
      HealthEventStatus.rescheduled => 'Reprogramado',
    };
    final detail = event.description.trim();
    return detail.isEmpty ? state : '$state · $detail';
  }

  static bool _isVisibleInAgenda(HealthEventEntity event, DateTime now) {
    if (!event.isAppointment) return false;
    return switch (event.effectiveStatus(now)) {
      HealthEventStatus.scheduled || HealthEventStatus.due => true,
      _ => false,
    };
  }
}
