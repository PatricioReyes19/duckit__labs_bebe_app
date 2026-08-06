import 'package:core/core.dart';

export 'package:core/core.dart' show HealthEventType;

enum HealthCaregiverRole { mother, father, other }

class HealthCaregiverVm {
  const HealthCaregiverVm({
    required this.id,
    required this.label,
    required this.role,
  });

  final String id;
  final String label;
  final HealthCaregiverRole role;
}

class HealthUpcomingEventVm {
  const HealthUpcomingEventVm({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.dateLabel,
    required this.timeLabel,
    required this.caregiver,
  });

  final String id;
  final HealthEventType type;
  final String title;
  final String description;
  final String dateLabel;
  final String timeLabel;
  final HealthCaregiverVm caregiver;
}

class HealthVaccinesSummaryVm {
  const HealthVaccinesSummaryVm({
    required this.completed,
    required this.pending,
    this.nextVaccineLabel,
  });

  final int completed;
  final int pending;
  final String? nextVaccineLabel;
}

class HealthGrowthSummaryVm {
  const HealthGrowthSummaryVm({
    required this.weightKg,
    this.heightCm,
    this.weightPercentile,
    this.recordedAtLabel,
  });

  final double weightKg;
  final double? heightCm;
  final int? weightPercentile;
  final String? recordedAtLabel;
}

class HealthOverviewVm {
  const HealthOverviewVm({
    required this.upcomingEvents,
    required this.vaccinesSummary,
    required this.growthSummary,
  });

  final List<HealthUpcomingEventVm> upcomingEvents;
  final HealthVaccinesSummaryVm vaccinesSummary;
  final HealthGrowthSummaryVm growthSummary;

  factory HealthOverviewVm.fromEntity(HealthOverviewEntity entity) {
    final scheduled =
        entity.events
            .where((event) => event.status == HealthEventStatus.scheduled)
            .toList(growable: false)
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final weights = entity.measurements
        .where((item) => item.type == HealthMeasurementType.weight)
        .toList(growable: false);
    final heights = entity.measurements
        .where((item) => item.type == HealthMeasurementType.height)
        .toList(growable: false);
    final vaccineEvents = scheduled
        .where((event) => event.type == HealthEventType.vaccine)
        .toList(growable: false);
    final nextVaccine = vaccineEvents.isEmpty ? null : vaccineEvents.first;
    return HealthOverviewVm(
      upcomingEvents: scheduled
          .map(
            (event) => HealthUpcomingEventVm(
              id: event.id,
              type: event.type,
              title: event.title,
              description: event.description,
              dateLabel: _dateLabel(event.startsAt),
              timeLabel: _timeLabel(event.startsAt),
              caregiver: HealthCaregiverVm(
                id: event.caregiver?.id ?? 'unassigned',
                label: event.caregiver?.role ?? 'Sin asignar',
                role: switch (event.caregiver?.id) {
                  'mother' => HealthCaregiverRole.mother,
                  'father' => HealthCaregiverRole.father,
                  _ => HealthCaregiverRole.other,
                },
              ),
            ),
          )
          .toList(growable: false),
      vaccinesSummary: HealthVaccinesSummaryVm(
        completed: entity.completedVaccines,
        pending: entity.pendingVaccines,
        nextVaccineLabel: nextVaccine == null
            ? null
            : 'Próxima: ${_dateLabel(nextVaccine.startsAt)}',
      ),
      growthSummary: HealthGrowthSummaryVm(
        weightKg: weights.isEmpty ? 0 : weights.first.value,
        heightCm: heights.isEmpty ? null : heights.first.value,
        recordedAtLabel: weights.isEmpty ? null : 'Último registro disponible',
      ),
    );
  }

  static String _dateLabel(DateTime value) {
    const weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sept',
      'oct',
      'nov',
      'dic',
    ];
    final local = value.toLocal();
    return '${weekdays[local.weekday - 1]}, '
        '${local.day} ${months[local.month - 1]}';
  }

  static String _timeLabel(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
