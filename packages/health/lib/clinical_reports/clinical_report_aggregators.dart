import 'dart:math' as math;

import 'package:core/core.dart';

class FeedingReportAggregator {
  const FeedingReportAggregator();

  ClinicalFeedingSummary aggregate(
    Iterable<RegisteredEvent> events, {
    required double periodDays,
  }) {
    final feedings = events
        .where((event) => event.type == RegisterEventType.feeding)
        .toList(growable: false);
    final volumes = feedings
        .map((event) => event.details['amount_ml'])
        .whereType<num>()
        .map((value) => value.toDouble())
        .where((value) => value.isFinite && value >= 0)
        .toList(growable: false);
    final subtypes = <String, int>{};
    for (final event in feedings) {
      final subtype = _text(event.details['subtype']) ?? 'no especificado';
      subtypes.update(subtype, (count) => count + 1, ifAbsent: () => 1);
    }
    return ClinicalFeedingSummary(
      recordCount: feedings.length,
      averagePerDay: feedings.length / math.max(periodDays, 1),
      averageVolumeMl: volumes.isEmpty
          ? null
          : volumes.reduce((first, second) => first + second) / volumes.length,
      lastFeedingAt: feedings.isEmpty
          ? null
          : feedings
                .map((event) => event.occurredAt)
                .reduce((first, second) => first.isAfter(second) ? first : second),
      subtypes: Map.unmodifiable(subtypes),
    );
  }
}

class EliminationReportAggregator {
  const EliminationReportAggregator();

  ClinicalEliminationSummary aggregate(
    Iterable<RegisteredEvent> events, {
    required double periodDays,
  }) {
    final diapers = events
        .where((event) => event.type == RegisterEventType.diaper)
        .toList(growable: false);
    var wet = 0;
    var stools = 0;
    bool? bloodOrMucus;
    final consistency = <String>[];
    final colors = <String>[];
    final anomalies = <String>[];
    for (final event in diapers) {
      final subtype =
          _text(event.details['subtype']) ??
          _text(event.details['diaper_type']) ??
          '';
      if (subtype == 'wet' || subtype == 'mixed') wet += 1;
      if (subtype == 'dirty' || subtype == 'mixed') stools += 1;
      final appearance = _text(event.details['appearance']);
      final color = _text(event.details['color']);
      if (appearance != null) consistency.add(appearance);
      if (color != null) colors.add(color);
      final symptoms = _text(event.details['symptoms']);
      final explicitBlood = event.details['blood'] as bool?;
      final explicitMucus = event.details['mucus'] as bool?;
      if (explicitBlood != null || explicitMucus != null) {
        bloodOrMucus = explicitBlood == true || explicitMucus == true;
      }
      final normalized = '${appearance ?? ''} ${symptoms ?? ''}'.toLowerCase();
      if (normalized.contains('sangre') || normalized.contains('moco')) {
        bloodOrMucus = true;
      }
      if (symptoms != null) anomalies.add(symptoms);
      if (appearance != null &&
          appearance != 'normal' &&
          appearance != 'formed') {
        anomalies.add('Consistencia: $appearance');
      }
    }
    return ClinicalEliminationSummary(
      wetDiapers: wet,
      stools: stools,
      averageWetPerDay: wet / math.max(periodDays, 1),
      averageStoolsPerDay: stools / math.max(periodDays, 1),
      predominantConsistency: _mode(consistency),
      predominantColor: _mode(colors),
      bloodOrMucusRecorded: bloodOrMucus,
      anomalies: List.unmodifiable(anomalies.toSet()),
    );
  }
}

class SleepReportAggregator {
  const SleepReportAggregator();

  ClinicalSleepSummary aggregate(
    Iterable<RegisteredEvent> events, {
    required double periodDays,
  }) {
    final sleeps = events
        .where((event) => event.type == RegisterEventType.sleep)
        .toList(growable: false);
    final completed = sleeps.where((event) => event.isFinished).toList();
    final durations = <double>[];
    final nightDurations = <double>[];
    var naps = 0;
    for (final event in completed) {
      final minutes = _sleepMinutes(event);
      if (minutes == null) continue;
      durations.add(minutes);
      final hour = event.startedAt.toLocal().hour;
      if (hour >= 18 || hour < 6) {
        nightDurations.add(minutes);
      } else {
        naps += 1;
      }
    }
    return ClinicalSleepSummary(
      completedSessions: completed.length,
      activeSessions: sleeps.where((event) => event.isActive).length,
      averageMinutes: _average(durations),
      averageNightMinutes: _average(nightDurations),
      averageNapsPerDay: naps / math.max(periodDays, 1),
    );
  }
}

class MedicationReportAggregator {
  const MedicationReportAggregator();

  List<ClinicalMedicationSummary> aggregate(
    Iterable<RegisteredEvent> events, {
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool includePrivateNotes,
  }) {
    final groups = <String, List<RegisteredEvent>>{};
    for (final event in events.where(
      (event) => event.type == RegisterEventType.medication,
    )) {
      final details = event.details;
      final key = [
        _text(details['name'])?.toLowerCase() ?? 'medicamento',
        details['dose'],
        _text(details['unit']),
        _text(details['frequency']),
        _text(details['route']),
      ].join('|');
      groups.putIfAbsent(key, () => <RegisteredEvent>[]).add(event);
    }
    final result = <ClinicalMedicationSummary>[];
    for (final administrations in groups.values) {
      administrations.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
      final details = administrations.last.details;
      final frequency = _text(details['frequency']) ?? 'No especificada';
      final configuredEnd = DateTime.tryParse(
        _text(details['end_date']) ?? '',
      );
      final startedAt = administrations.first.occurredAt.isAfter(dateFrom)
          ? administrations.first.occurredAt
          : dateFrom;
      final endedAt = configuredEnd != null && configuredEnd.isBefore(dateTo)
          ? configuredEnd
          : dateTo;
      final interval = _frequencyInterval(frequency);
      final scheduled = details['schedule_next_doses'] == true && interval != null
          ? math.max(0, endedAt.difference(startedAt).inMinutes ~/ interval.inMinutes + 1)
          : administrations.length;
      final adverseEvents = <String>{};
      for (final event in administrations) {
        for (final key in const ['adverse_reaction', 'symptoms']) {
          final value = _text(event.details[key]);
          if (value != null) adverseEvents.add(value);
        }
        if (includePrivateNotes) {
          final notes = _text(event.notes);
          if (notes != null) adverseEvents.add(notes);
        }
      }
      result.add(
        ClinicalMedicationSummary(
          name: _text(details['name']) ?? 'Medicamento no especificado',
          dose: _numberText(details['dose']) ?? 'Sin registro',
          unit: _text(details['unit']) ?? '',
          route: _text(details['route']),
          frequency: frequency,
          registeredAdministrations: administrations.length,
          unregisteredAdministrations: math.max(
            0,
            scheduled - administrations.length,
          ),
          startedAt: startedAt,
          endedAt: endedAt,
          lastAdministrationAt: administrations.last.occurredAt,
          adverseEvents: List.unmodifiable(adverseEvents),
        ),
      );
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(result);
  }
}

class GrowthReportAggregator {
  const GrowthReportAggregator();

  List<ClinicalGrowthPoint> aggregate(
    Iterable<ClinicalGrowthPoint> points, {
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    final result = points
        .where(
          (point) =>
              !point.recordedAt.isBefore(dateFrom) &&
              !point.recordedAt.isAfter(dateTo) &&
              point.value.isFinite,
        )
        .toList(growable: false)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return List.unmodifiable(result);
  }
}

class ObservationReportAggregator {
  const ObservationReportAggregator();

  List<ClinicalReportItem> aggregate(
    Iterable<RegisteredEvent> events, {
    required bool includePrivateNotes,
  }) {
    final result = <ClinicalReportItem>[];
    for (final event in events.where(
      (event) => event.type == RegisterEventType.clinicalObservation,
    )) {
      final kind = _text(event.details['observation_type']);
      if (kind == 'pediatrician_profile' ||
          kind == 'medical_consultation' ||
          kind == 'vaccination') {
        continue;
      }
      final detail = [
        _text(event.details['description']),
        _text(event.details['severity']),
        if (includePrivateNotes) _text(event.notes),
      ].whereType<String>().join(' · ');
      result.add(
        ClinicalReportItem(
          occurredAt: event.occurredAt,
          title: _text(event.details['title']) ?? _observationLabel(kind),
          detail: detail.isEmpty ? 'Sin detalle adicional' : detail,
        ),
      );
    }
    result.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(result);
  }
}

double? _sleepMinutes(RegisteredEvent event) {
  final stored = event.details['duration_minutes'];
  if (stored is num && stored.isFinite && stored >= 0) return stored.toDouble();
  final endedAt = event.endedAt;
  if (endedAt == null || endedAt.isBefore(event.startedAt)) return null;
  return endedAt.difference(event.startedAt).inMinutes.toDouble();
}

double? _average(List<double> values) => values.isEmpty
    ? null
    : values.reduce((first, second) => first + second) / values.length;

String? _mode(List<String> values) {
  if (values.isEmpty) return null;
  final counts = <String, int>{};
  for (final value in values) {
    counts.update(value, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

Duration? _frequencyInterval(String value) => switch (value) {
  'Cada 4 horas' => const Duration(hours: 4),
  'Cada 6 horas' => const Duration(hours: 6),
  'Cada 8 horas' => const Duration(hours: 8),
  'Cada 12 horas' => const Duration(hours: 12),
  'Una vez al día' => const Duration(days: 1),
  _ => null,
};

String _observationLabel(String? value) => switch (value) {
  'temperature' => 'Temperatura',
  'vomit' || 'reflux' => 'Vómito / reflujo',
  'respiratory' => 'Síntoma respiratorio',
  'skin' || 'allergy' => 'Piel / alergia',
  'stool' => 'Heces',
  _ => 'Observación clínica',
};

String? _numberText(Object? value) {
  if (value is num) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString().replaceAll('.', ',');
  }
  return _text(value);
}

String? _text(Object? value) {
  if (value == null) return null;
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}
