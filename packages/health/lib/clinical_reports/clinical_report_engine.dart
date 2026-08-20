import 'package:core/core.dart';

import 'clinical_report_aggregators.dart';

class ClinicalReportEngine {
  const ClinicalReportEngine({
    this.feedingAggregator = const FeedingReportAggregator(),
    this.eliminationAggregator = const EliminationReportAggregator(),
    this.sleepAggregator = const SleepReportAggregator(),
    this.medicationAggregator = const MedicationReportAggregator(),
    this.growthAggregator = const GrowthReportAggregator(),
    this.observationAggregator = const ObservationReportAggregator(),
  });

  final FeedingReportAggregator feedingAggregator;
  final EliminationReportAggregator eliminationAggregator;
  final SleepReportAggregator sleepAggregator;
  final MedicationReportAggregator medicationAggregator;
  final GrowthReportAggregator growthAggregator;
  final ObservationReportAggregator observationAggregator;

  ClinicalReportData generate({
    required ClinicalReportRequest request,
    required BabyEntity baby,
    required Iterable<RegisteredEvent> registerEvents,
    required Iterable<HealthEventEntity> healthEvents,
    required Iterable<ClinicalGrowthPoint> growthPoints,
    Map<String, String> caregiverNames = const {},
    DateTime? generatedAt,
    String appVersion = 'unknown',
  }) {
    final now = (generatedAt ?? DateTime.now()).toUtc();
    final records =
        registerEvents
            .where(
              (event) =>
                  event.babyId == request.babyId &&
                  !event.isDeleted &&
                  _inPeriod(event.occurredAt, request),
            )
            .toList(growable: false)
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    final health = healthEvents
        .where(
          (event) =>
              event.babyId == request.babyId &&
              _inPeriod(event.startsAt, request),
        )
        .toList(growable: false);
    final periodDays =
        request.dateTo.difference(request.dateFrom).inMinutes /
        Duration.minutesPerDay;

    final observations = <ClinicalReportItem>[
      ...observationAggregator.aggregate(
        records,
        includePrivateNotes: request.includePrivateNotes,
      ),
    ];
    if (request.type == ClinicalReportType.symptomConsultation) {
      observations.sort(
        (a, b) => _observationPriority(a).compareTo(_observationPriority(b)),
      );
    }

    return ClinicalReportData(
      reportId: 'clinical-${now.microsecondsSinceEpoch}',
      request: request,
      babyName: baby.name,
      birthDate: baby.birthDate,
      generatedAt: now,
      summary: _summaryFor(request.type, records.length, health.length),
      feeding: feedingAggregator.aggregate(records, periodDays: periodDays),
      elimination: eliminationAggregator.aggregate(
        records,
        periodDays: periodDays,
      ),
      sleep: sleepAggregator.aggregate(records, periodDays: periodDays),
      medications: medicationAggregator.aggregate(
        records,
        dateFrom: request.dateFrom,
        dateTo: request.dateTo,
        includePrivateNotes: request.includePrivateNotes,
      ),
      growth: growthAggregator.aggregate(
        growthPoints,
        dateFrom: request.dateFrom,
        dateTo: request.dateTo,
      ),
      vaccines: _vaccines(health, records),
      appointments: _appointments(health, records),
      observations: List.unmodifiable(observations),
      timeline: _timeline(records, request, caregiverNames),
      photoPaths: request.includePhotos ? _photoPaths(records) : const [],
      appVersion: appVersion,
    );
  }

  static List<ClinicalReportItem> _vaccines(
    List<HealthEventEntity> health,
    List<RegisteredEvent> records,
  ) {
    final result = <ClinicalReportItem>[
      for (final event in health)
        if (event.isImmunization)
          ClinicalReportItem(
            occurredAt: event.startsAt,
            title: event.title,
            detail: event.description,
            status: switch (event.status) {
              HealthEventStatus.draft => 'Borrador',
              HealthEventStatus.scheduled => 'Programada',
              HealthEventStatus.due => 'Corresponde hoy',
              HealthEventStatus.attendancePending => 'Asistencia pendiente',
              HealthEventStatus.attendedPendingSummary => 'Resumen pendiente',
              HealthEventStatus.completed => 'Aplicada',
              HealthEventStatus.notAttended => 'No aplicada',
              HealthEventStatus.cancelled => 'Cancelada',
              HealthEventStatus.rescheduled => 'Reprogramada',
            },
          ),
    ];
    for (final event in records.where(
      (event) => event.details['observation_type'] == 'vaccination',
    )) {
      final title = _text(event.details['title']) ?? 'Vacuna';
      final duplicate = result.any(
        (item) =>
            item.occurredAt.toLocal().year == event.occurredAt.toLocal().year &&
            item.occurredAt.toLocal().month ==
                event.occurredAt.toLocal().month &&
            item.occurredAt.toLocal().day == event.occurredAt.toLocal().day &&
            item.title == title,
      );
      if (!duplicate) {
        result.add(
          ClinicalReportItem(
            occurredAt: event.occurredAt,
            title: title,
            detail: _text(event.details['location']) ?? 'Vacuna registrada',
            status: 'Aplicada',
            professional: _text(event.details['professional']),
          ),
        );
      }
    }
    result.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(result);
  }

  static List<ClinicalReportItem> _appointments(
    List<HealthEventEntity> health,
    List<RegisteredEvent> records,
  ) {
    final result = <ClinicalReportItem>[
      for (final event in health)
        if (!event.isImmunization)
          ClinicalReportItem(
            occurredAt: event.startsAt,
            title: event.title,
            detail: event.description,
            status: switch (event.status) {
              HealthEventStatus.draft => 'Borrador',
              HealthEventStatus.scheduled => 'Programado',
              HealthEventStatus.due => 'Corresponde hoy',
              HealthEventStatus.attendancePending => 'Asistencia pendiente',
              HealthEventStatus.attendedPendingSummary => 'Resumen pendiente',
              HealthEventStatus.completed => 'Completado',
              HealthEventStatus.notAttended => 'No asistieron',
              HealthEventStatus.cancelled => 'Cancelado',
              HealthEventStatus.rescheduled => 'Reprogramado',
            },
          ),
      for (final event in records)
        if (event.details['observation_type'] == 'medical_consultation' &&
            !health.any((item) => item.id == event.id))
          ClinicalReportItem(
            occurredAt: event.occurredAt,
            title: _text(event.details['title']) ?? 'Consulta pediátrica',
            detail: [
              _text(event.details['description']),
              _text(event.details['treatment']),
              _text(event.details['follow_up']),
            ].whereType<String>().join(' · '),
            status: 'Completada',
            professional: _text(event.details['pediatrician']),
          ),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(result);
  }

  static List<ClinicalTimelineItem> _timeline(
    List<RegisteredEvent> records,
    ClinicalReportRequest request,
    Map<String, String> caregiverNames,
  ) {
    final includeAll =
        request.includeRawTimeline ||
        request.type == ClinicalReportType.fullHistory;
    if (!includeAll && request.type != ClinicalReportType.symptomConsultation) {
      return const [];
    }
    final result = <ClinicalTimelineItem>[];
    for (final event in records) {
      if (!includeAll &&
          event.type == RegisterEventType.sleep &&
          _text(event.details['symptoms']) == null) {
        continue;
      }
      if (event.details['observation_type'] == 'pediatrician_profile') continue;
      result.add(
        ClinicalTimelineItem(
          occurredAt: event.occurredAt,
          type: _typeLabel(event.type),
          detail: _eventDetail(event, request.includePrivateNotes),
          caregiverName: request.includeCaregiverNames
              ? caregiverNames[event.caregiverId]
              : null,
        ),
      );
    }
    result.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(result);
  }

  static List<String> _photoPaths(List<RegisteredEvent> records) {
    final paths = <String>{};
    for (final event in records) {
      final photos = event.details['photo_paths'];
      if (photos is List) paths.addAll(photos.whereType<String>());
    }
    return List.unmodifiable(paths);
  }

  static bool _inPeriod(DateTime value, ClinicalReportRequest request) {
    final utc = value.toUtc();
    return !utc.isBefore(request.dateFrom.toUtc()) &&
        !utc.isAfter(request.dateTo.toUtc());
  }

  static String _summaryFor(
    ClinicalReportType type,
    int recordCount,
    int healthCount,
  ) => switch (type) {
    ClinicalReportType.pediatricControl =>
      'Resumen contextual para control pediátrico con $recordCount registros '
          'de actividad y $healthCount atenciones de salud en el período.',
    ClinicalReportType.symptomConsultation =>
      'Resumen priorizado de síntomas y cuidados recientes.',
    ClinicalReportType.medicationFollowUp =>
      'Seguimiento de administraciones registradas y horarios sin registro.',
    ClinicalReportType.growthNutrition =>
      'Evolución de crecimiento y patrón resumido de alimentación.',
    ClinicalReportType.fullHistory =>
      'Historial completo solicitado expresamente por el cuidador.',
  };

  static int _observationPriority(ClinicalReportItem item) {
    final value = '${item.title} ${item.detail}'.toLowerCase();
    if (value.contains('temperatura') || value.contains('fiebre')) return 0;
    if (value.contains('respir')) return 1;
    if (value.contains('vómit') || value.contains('reflu')) return 2;
    if (value.contains('alerg') || value.contains('piel')) return 3;
    if (value.contains('heces') || value.contains('depos')) return 4;
    return 5;
  }

  static String _eventDetail(RegisteredEvent event, bool includePrivateNotes) {
    final details = event.details;
    final values = <String?>[
      _text(details['description']),
      if (details['amount_ml'] != null) '${details['amount_ml']} mL',
      _text(details['subtype']),
      _text(details['name']),
      if (details['dose'] != null)
        '${details['dose']} ${_text(details['unit']) ?? ''}'.trim(),
      _text(details['symptoms']),
      if (includePrivateNotes) _text(event.notes),
    ].whereType<String>().toSet();
    return values.isEmpty
        ? 'Registro sin detalle adicional'
        : values.join(' · ');
  }

  static String _typeLabel(RegisterEventType type) => switch (type) {
    RegisterEventType.feeding => 'Alimentación',
    RegisterEventType.sleep => 'Sueño',
    RegisterEventType.diaper => 'Eliminación',
    RegisterEventType.clinicalObservation => 'Observación',
    RegisterEventType.medication => 'Medicamento',
    RegisterEventType.measurement => 'Medición',
  };
}

String? _text(Object? value) {
  if (value == null) return null;
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}
