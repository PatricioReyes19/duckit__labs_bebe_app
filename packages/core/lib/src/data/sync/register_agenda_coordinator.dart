import 'dart:async';

import '../../domain/entities/agenda/agenda.dart';
import '../../domain/entities/register/register.dart';
import '../register/sqlite_register_event_repository.dart';
import '../repositories/sqlite_agenda_repository.dart';
import 'agenda_event_sync_service.dart';

/// Projects medication records into future agenda actions.
///
/// The source register row remains the fact that a dose happened. Generated
/// agenda rows only represent future actions and keep a source id for safe,
/// idempotent reconciliation on every device.
class RegisterAgendaCoordinator {
  RegisterAgendaCoordinator(
    this._registerRepository,
    this._agendaRepository,
    this._agendaSyncService, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SqliteRegisterEventRepository _registerRepository;
  final SqliteAgendaRepository _agendaRepository;
  final AgendaEventSyncService _agendaSyncService;
  final DateTime Function() _clock;
  StreamSubscription<void>? _subscription;
  Future<void>? _running;
  bool _rerunRequested = false;

  /// Ventana móvil para tratamientos sin término explícito. Se repone en cada
  /// reconciliación, por lo que una pauta abierta no desaparece después de dos
  /// semanas y tampoco materializa una cantidad infinita de filas.
  static const openEndedHorizon = Duration(days: 90);
  static const maximumGeneratedDoses = 1024;

  void start() {
    _subscription ??= _registerRepository.changes.listen((_) {
      unawaited(reconcile());
    });
    unawaited(reconcile());
  }

  Future<void> reconcile() {
    _rerunRequested = true;
    final running = _running;
    if (running != null) return running;
    final operation = _drainReconciliationQueue();
    _running = operation;
    return operation.whenComplete(() => _running = null);
  }

  Future<void> _drainReconciliationQueue() async {
    while (_rerunRequested) {
      _rerunRequested = false;
      await _reconcileOnce();
    }
  }

  Future<void> _reconcileOnce() async {
    final medicationEvents = await _registerRepository
        .listByTypeIncludingDeleted(RegisterEventType.medication);
    var changed = false;
    for (final medication in medicationEvents) {
      final desired = _desiredDoses(medication);
      for (final draft in desired) {
        final before = await _agendaRepository.findByIdIncludingDeleted(
          draft.id!,
        );
        final after = await _agendaRepository.upsertDerived(draft);
        if (before == null || before.updatedAt != after.updatedAt) {
          changed = true;
        }
      }
      final desiredIds = desired.map((draft) => draft.id).toSet();
      if (await _agendaRepository.deleteDerivedExcept(
        medication.id,
        desiredIds,
      )) {
        changed = true;
      }
    }
    if (changed) unawaited(_agendaSyncService.synchronize());
  }

  List<AgendaEventDraft> _desiredDoses(RegisteredEvent event) {
    if (event.isDeleted || event.details['schedule_next_doses'] != true) {
      return const [];
    }
    final interval = _frequencyInterval(event.details['frequency'] as String?);
    if (interval == null) return const [];

    final now = _clock();
    final explicitEnd = DateTime.tryParse(
      (event.details['end_date'] as String?) ?? '',
    )?.toLocal();
    final horizon = explicitEnd ?? now.add(openEndedHorizon);
    var next = event.occurredAt.toLocal().add(interval);
    while (!next.isAfter(now)) {
      next = next.add(interval);
    }

    final name = (event.details['name'] as String?)?.trim();
    final dose = event.details['dose'];
    final unit = event.details['unit'];
    final frequency = event.details['frequency'];
    final result = <AgendaEventDraft>[];
    while (!next.isAfter(horizon) && result.length < maximumGeneratedDoses) {
      final startsAt = next.toUtc();
      result.add(
        AgendaEventDraft(
          id: 'dose-${event.id}-${startsAt.millisecondsSinceEpoch}',
          babyId: event.babyId,
          category: AgendaCategory.medication,
          title:
              'Próxima dosis: ${name?.isNotEmpty == true ? name : 'medicamento'}',
          description: [
            if (dose != null && unit != null) '$dose $unit',
            if (frequency != null) '$frequency',
          ].join(' · '),
          startsAt: startsAt,
          sourceRegisterEventId: event.id,
        ),
      );
      next = next.add(interval);
    }
    return result;
  }

  static Duration? _frequencyInterval(String? value) => switch (value) {
    'Cada 4 horas' => const Duration(hours: 4),
    'Cada 6 horas' => const Duration(hours: 6),
    'Cada 8 horas' => const Duration(hours: 8),
    'Cada 12 horas' => const Duration(hours: 12),
    'Una vez al día' => const Duration(days: 1),
    _ => null,
  };

  Future<void> close() async => _subscription?.cancel();
}
