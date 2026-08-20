import 'dart:async';

import '../../entities/agenda/agenda.dart';
import '../../entities/family/family.dart';
import '../../entities/health/health.dart';
import '../../entities/immunization/immunization.dart';
import '../../entities/register/register.dart';
import '../../../data/immunization/bundled_immunization_catalog.dart';
import '../../repositories/agenda/agenda_repository.dart';
import '../../repositories/register_event/register_event.dart';
import '../../repositories/settings/app_settings_repository.dart';
import '../../repositories/health/health_repository.dart';
import '../family/get_family_overview.dart';

class GetAgendaOverview {
  const GetAgendaOverview(
    this._repository,
    this._registerRepository, [
    this._settingsRepository,
    this._healthRepository,
    this._getFamilyOverview,
  ]);

  final AgendaRepository _repository;
  final RegisterEventRepository _registerRepository;
  final AppSettingsRepository? _settingsRepository;
  final HealthRepository? _healthRepository;
  final GetFamilyOverview? _getFamilyOverview;

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
    final projectedHealthEvents = health.events
        .where((event) => _isVisibleInAgenda(event, now))
        .map(
          (event) => AgendaEventEntity(
            id: 'health:${event.id}',
            babyId: event.babyId,
            category: event.isImmunization
                ? AgendaCategory.vaccines
                : AgendaCategory.controls,
            title: event.title,
            description: _healthEventDescription(event),
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
    final projectedImmunizations = await _projectImmunizations(
      babyId: babyId,
      health: health,
      now: now,
    );
    return overview.copyWith(
      events: [
        ...overview.events,
        ...projectedHealthEvents,
        ...projectedImmunizations,
      ],
      registerEvents: records,
    );
  }

  Future<List<AgendaEventEntity>> _projectImmunizations({
    required String babyId,
    required HealthOverviewEntity health,
    required DateTime now,
  }) async {
    final getFamilyOverview = _getFamilyOverview;
    if (getFamilyOverview == null) return const [];
    final family = await getFamilyOverview();
    BabyEntity? baby;
    for (final candidate in family.babies) {
      if (candidate.id == babyId) {
        baby = candidate;
        break;
      }
    }
    if (baby == null) return const [];

    final catalog = await BundledImmunizationCatalog.load();
    final schedule = const ImmunizationSchedulePlanner().plan(
      catalog: catalog,
      context: ImmunizationEligibilityContext.fromBaby(baby),
      records: health.events
          .map((event) => event.immunizationRecord)
          .whereType<ImmunizationRecord>(),
      now: now,
    );
    return schedule
        .where((planned) => !planned.isPending)
        .map(
          (planned) => AgendaEventEntity(
            id: 'immunization:${planned.item.id}:${planned.scheduledAt.toUtc().toIso8601String()}',
            babyId: babyId,
            category: AgendaCategory.vaccines,
            title: planned.item.displayName,
            description:
                '${planned.item.sourceBadge} · ${planned.item.doseLabel} · ${planned.item.sourceVersion}',
            startsAt: planned.scheduledAt,
            syncStatus: AgendaSyncStatus.synced,
            createdAt: planned.scheduledAt,
            updatedAt: planned.scheduledAt,
          ),
        )
        .toList(growable: false);
  }

  static String _healthEventDescription(HealthEventEntity event) {
    if (event.isImmunization) {
      final source = switch (event.immunizationSourceType) {
        ImmunizationSourceType.pniProgrammatic => 'PNI',
        ImmunizationSourceType.minsalCampaign => 'Campaña MINSAL',
        ImmunizationSourceType.complementaryPrivate => 'Particular',
        ImmunizationSourceType.physicianIndicated || null => 'Indicada',
      };
      final dose = event.immunizationDoseLabel?.trim();
      return dose == null || dose.isEmpty ? source : '$source · $dose';
    }
    final appointmentKind =
        event.appointmentKind == HealthAppointmentKind.wellChildControl
        ? 'Control'
        : 'Consulta';
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
    final summary = detail.isEmpty ? state : '$state · $detail';
    return '$appointmentKind · $summary';
  }

  static bool _isVisibleInAgenda(HealthEventEntity event, DateTime now) {
    if (!event.isAppointment && !event.isImmunization) return false;
    // Las atenciones son parte de la historia clínica: se conservan al volver
    // a su fecha en Agenda. Los borradores todavía no son citas confirmadas.
    if (event.isAppointment) {
      return event.effectiveStatus(now) != HealthEventStatus.draft;
    }
    return switch (event.effectiveStatus(now)) {
      HealthEventStatus.scheduled || HealthEventStatus.due => true,
      _ => false,
    };
  }
}
