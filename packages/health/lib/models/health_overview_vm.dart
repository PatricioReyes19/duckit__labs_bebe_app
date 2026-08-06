enum HealthEventType { vaccine, pediatricControl, growthControl }

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

  factory HealthOverviewVm.mock() {
    return const HealthOverviewVm(
      upcomingEvents: [
        HealthUpcomingEventVm(
          id: 'vaccine-pneumococcus-2',
          type: HealthEventType.vaccine,
          title: 'Vacuna Neumococo',
          description: 'Segunda dosis',
          dateLabel: 'Lun, 10 ago',
          timeLabel: '10:00 AM',
          caregiver: HealthCaregiverVm(
            id: 'mother',
            label: 'Mamá',
            role: HealthCaregiverRole.mother,
          ),
        ),
        HealthUpcomingEventVm(
          id: 'pediatric-control',
          type: HealthEventType.pediatricControl,
          title: 'Control pediátrico',
          description: 'Chequeo de rutina',
          dateLabel: 'Vie, 14 ago',
          timeLabel: '09:00 AM',
          caregiver: HealthCaregiverVm(
            id: 'father',
            label: 'Papá',
            role: HealthCaregiverRole.father,
          ),
        ),
        HealthUpcomingEventVm(
          id: 'growth-control',
          type: HealthEventType.growthControl,
          title: 'Control de crecimiento',
          description: 'Registro de peso y talla',
          dateLabel: 'Mar, 18 ago',
          timeLabel: '11:30 AM',
          caregiver: HealthCaregiverVm(
            id: 'mother',
            label: 'Mamá',
            role: HealthCaregiverRole.mother,
          ),
        ),
      ],
      vaccinesSummary: HealthVaccinesSummaryVm(
        completed: 4,
        pending: 1,
        nextVaccineLabel: 'Próxima: Lun, 10 ago',
      ),
      growthSummary: HealthGrowthSummaryVm(
        weightKg: 7.25,
        heightCm: 65,
        weightPercentile: 41,
        recordedAtLabel: 'Actualizado hoy',
      ),
    );
  }
}
