import 'dart:async';
import 'dart:developer' as developer;

import '../../domain/entities/agenda/agenda.dart';
import '../../domain/entities/register/register.dart';
import '../register/sqlite_register_event_repository.dart';
import '../repositories/sqlite_agenda_repository.dart';
import '../repositories/sqlite_family_repository.dart';
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
    required this._familyRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SqliteRegisterEventRepository _registerRepository;
  final SqliteAgendaRepository _agendaRepository;
  final AgendaEventSyncService _agendaSyncService;
  final SqliteFamilyRepository _familyRepository;
  final DateTime Function() _clock;
  StreamSubscription<void>? _subscription;
  Future<bool>? _running;
  bool _rerunRequested = false;

  /// Ventana móvil para tratamientos sin término explícito. Se repone en cada
  /// reconciliación, por lo que una pauta abierta no desaparece después de dos
  /// semanas y tampoco materializa una cantidad infinita de filas.
  static const openEndedHorizon = Duration(days: 90);
  static const maximumGeneratedDoses = 1024;

  /// Enables projection of future local/Realtime register changes.
  ///
  /// The initial reconciliation is deliberately controlled by
  /// [InitialDataSyncCoordinator] after Family/Babies and remote events have
  /// been hydrated.
  void startListening() {
    _subscription ??= _registerRepository.changes.listen((_) {
      _scheduleReconciliation();
    });
  }

  Future<bool> reconcile() {
    _rerunRequested = true;
    final running = _running;
    if (running != null) return running;
    final operation = _drainReconciliationQueue();
    _running = operation;
    return operation.whenComplete(() => _running = null);
  }

  Future<bool> _drainReconciliationQueue() async {
    var changed = false;
    while (_rerunRequested) {
      _rerunRequested = false;
      changed = await _reconcileOnce() || changed;
    }
    return changed;
  }

  Future<bool> _reconcileOnce() async {
    final medicationEvents = await _registerRepository
        .listByTypeIncludingDeleted(RegisterEventType.medication);
    var changed = false;
    for (final medication in medicationEvents) {
      if (!await _familyRepository.containsBaby(medication.babyId)) {
        continue;
      }
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
    if (changed) await _agendaSyncService.synchronize();
    return changed;
  }

  void _scheduleReconciliation() {
    unawaited(
      reconcile().then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          developer.log(
            'Register → Agenda reconciliation failed',
            name: 'bebeapp.sync',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
    );
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

  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
