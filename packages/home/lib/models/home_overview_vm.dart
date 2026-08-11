import 'package:equatable/equatable.dart';
import 'package:core/core.dart' as domain;

class HomeOverviewVm extends Equatable {
  const HomeOverviewVm({
    required this.activeBaby,
    required this.todayMetrics,
    required this.quickActions,
    required this.upcomingHealth,
    required this.recentInformation,
    required this.visualReminders,
    required this.hasCareData,
  });

  final HomeActiveBabyVm activeBaby;
  final List<HomeTodayMetricVm> todayMetrics;
  final List<HomeQuickActionVm> quickActions;
  final HomeUpcomingHealthVm upcomingHealth;
  final HomeRecentInformationVm recentInformation;
  final List<HomeVisualReminderVm> visualReminders;
  final bool hasCareData;

  factory HomeOverviewVm.fromEntity(
    domain.HomeOverviewEntity entity, {
    required DateTime referenceDate,
  }) {
    final siblings = entity.family.babies
        .where((baby) => baby.id != entity.activeBaby.id)
        .toList(growable: false);
    final upcoming = entity.upcomingHealthEvent;
    final recent = entity.mostRecentEvent;
    final recentIsOngoingSleep =
        recent?.type == domain.RegisterEventType.sleep &&
            recent?.details['sleep_status'] == 'ongoing';
    return HomeOverviewVm(
      activeBaby: HomeActiveBabyVm(
        id: entity.activeBaby.id,
        name: entity.activeBaby.name,
        ageLabel: _ageLabel(entity.activeBaby.birthDate, referenceDate),
        avatarAssetPath: entity.activeBaby.avatarAssetPath,
        familyContextLabel: entity.family.name,
        siblings: siblings
            .map(
              (baby) => HomeSiblingVm(
                id: baby.id,
                name: baby.name,
                ageLabel: _ageLabel(baby.birthDate, referenceDate),
                avatarAssetPath: baby.avatarAssetPath,
              ),
            )
            .toList(growable: false),
      ),
      todayMetrics: entity.metrics
          .map((metric) => _metric(metric, referenceDate))
          .toList(growable: false),
      quickActions: const [
        HomeQuickActionVm(
          id: 'feeding',
          type: HomeQuickActionKind.feeding,
          label: 'Alimentación',
        ),
        HomeQuickActionVm(
          id: 'sleep',
          type: HomeQuickActionKind.sleep,
          label: 'Sueño',
        ),
        HomeQuickActionVm(
          id: 'diaper',
          type: HomeQuickActionKind.diaper,
          label: 'Cambio',
        ),
        HomeQuickActionVm(
          id: 'observation',
          type: HomeQuickActionKind.observation,
          label: 'Observación',
        ),
        HomeQuickActionVm(
          id: 'medicine',
          type: HomeQuickActionKind.medicine,
          label: 'Medicina',
        ),
      ],
      upcomingHealth: HomeUpcomingHealthVm(
        title: upcoming?.title ?? 'Sin próximos controles',
        dateLabel:
            upcoming == null ? 'Agenda al día' : _dateLabel(upcoming.startsAt),
        timeLabel: upcoming == null ? '--:--' : _timeLabel(upcoming.startsAt),
        caregiverLabel: upcoming?.caregiver == null
            ? 'Sin cuidador asignado'
            : 'Acompaña: ${upcoming!.caregiver!.role}',
        type: switch (upcoming?.type) {
          domain.HealthEventType.vaccine => HomeUpcomingHealthKind.vaccine,
          domain.HealthEventType.pediatricControl ||
          domain.HealthEventType.growthControl =>
            HomeUpcomingHealthKind.control,
          null => HomeUpcomingHealthKind.control,
        },
      ),
      recentInformation: HomeRecentInformationVm(
        title: recent == null
            ? 'Sin actividad reciente'
            : _eventTitle(recent.type),
        dateLabel: recent == null
            ? 'Hoy'
            : _relativeTime(recent.occurredAt, referenceDate),
        description: recent == null
            ? 'Los nuevos registros aparecerán en esta sección.'
            : recentIsOngoingSleep
                ? 'El sueño sigue en curso. Registra el despertar desde el historial.'
                : 'Registro guardado correctamente en este dispositivo.',
        status: recent == null
            ? HomeRecentStatus.information
            : recentIsOngoingSleep
                ? HomeRecentStatus.information
                : HomeRecentStatus.success,
        statusLabel: recent == null
            ? 'Sin registros'
            : recentIsOngoingSleep
                ? 'En curso'
                : 'Completado',
      ),
      visualReminders: entity.careReminders
          .map(HomeVisualReminderVm.fromEntity)
          .toList(growable: false),
      hasCareData: entity.metrics.any((metric) => metric.count > 0) ||
          upcoming != null ||
          recent != null ||
          entity.careReminders.isNotEmpty,
    );
  }

  static HomeTodayMetricVm _metric(
    domain.HomeMetricEntity metric,
    DateTime referenceDate,
  ) {
    final type = switch (metric.type) {
      domain.HomeMetricType.feeding => HomeMetricType.feeding,
      domain.HomeMetricType.sleep => HomeMetricType.sleep,
      domain.HomeMetricType.diaper => HomeMetricType.diaper,
    };
    return HomeTodayMetricVm(
      type: type,
      label: switch (type) {
        HomeMetricType.feeding => 'Alimentación',
        HomeMetricType.sleep => 'Sueño',
        HomeMetricType.diaper => 'Pañales',
      },
      value: type == HomeMetricType.sleep && metric.ongoingCount > 0
          ? 'En curso'
          : type == HomeMetricType.sleep
              ? _duration(metric.totalMinutes)
              : '${metric.count}',
      unit: switch (type) {
        HomeMetricType.feeding => 'tomas',
        HomeMetricType.sleep => metric.ongoingCount > 0 ? 'ahora' : 'total',
        HomeMetricType.diaper => 'cambios',
      },
      lastLabel: 'Última vez',
      lastValue: metric.lastOccurredAt == null
          ? 'Sin registros'
          : _relativeTime(metric.lastOccurredAt!, referenceDate),
    );
  }

  static String _duration(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder min';
    return remainder == 0 ? '$hours h' : '$hours h $remainder min';
  }

  static String _eventTitle(domain.RegisterEventType type) => switch (type) {
        domain.RegisterEventType.feeding => 'Alimentación registrada',
        domain.RegisterEventType.sleep => 'Sueño registrado',
        domain.RegisterEventType.diaper => 'Cambio registrado',
        domain.RegisterEventType.clinicalObservation =>
          'Observación registrada',
        domain.RegisterEventType.medication => 'Medicación registrada',
        domain.RegisterEventType.measurement => 'Medición registrada',
      };

  static String _relativeTime(DateTime value, DateTime referenceDate) {
    final difference = referenceDate.difference(value.toLocal());
    if (difference.inMinutes < 1) return 'Ahora';
    if (difference.inHours < 1) return 'Hace ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Hace ${difference.inHours} h';
    return _dateLabel(value);
  }

  static String _dateLabel(DateTime value) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final local = value.toLocal();
    return '${local.day} de ${months[local.month - 1]}';
  }

  static String _timeLabel(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  static String _ageLabel(DateTime birthDate, DateTime referenceDate) {
    final birth = birthDate.toLocal();
    final reference = referenceDate.toLocal();
    var months =
        (reference.year - birth.year) * 12 + reference.month - birth.month;
    if (reference.day < birth.day) months--;
    if (months <= 0) return 'Menos de un mes';
    return months == 1 ? '1 mes' : '$months meses';
  }

  @override
  List<Object?> get props => [
        activeBaby,
        todayMetrics,
        quickActions,
        upcomingHealth,
        recentInformation,
        visualReminders,
        hasCareData,
      ];
}

enum HomeVisualReminderKind { feeding, bottle, formula, diaper, medication }

class HomeVisualReminderVm extends Equatable {
  const HomeVisualReminderVm({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
    required this.startsAt,
  });

  static const visibilityWindow = Duration(minutes: 10);

  final String id;
  final HomeVisualReminderKind kind;
  final String title;
  final String detail;
  final DateTime startsAt;

  factory HomeVisualReminderVm.fromEntity(
    domain.HomeCareReminderEntity entity,
  ) {
    final subtype = entity.subtype?.trim().toLowerCase();
    final kind = switch (entity.type) {
      domain.HomeCareReminderType.diaper => HomeVisualReminderKind.diaper,
      domain.HomeCareReminderType.medication =>
        HomeVisualReminderKind.medication,
      domain.HomeCareReminderType.feeding when subtype == 'formula' =>
        HomeVisualReminderKind.formula,
      domain.HomeCareReminderType.feeding
          when subtype == 'bottle' || subtype == 'expressed' =>
        HomeVisualReminderKind.bottle,
      domain.HomeCareReminderType.feeding => HomeVisualReminderKind.feeding,
    };
    final medicationName =
        entity.title.replaceFirst(RegExp(r'^Próxima dosis:\s*'), '').trim();
    return HomeVisualReminderVm(
      id: entity.id,
      kind: kind,
      title: switch (kind) {
        HomeVisualReminderKind.formula => 'Se aproxima un relleno',
        HomeVisualReminderKind.bottle => 'Se aproxima una mamadera',
        HomeVisualReminderKind.feeding => 'Se aproxima una toma',
        HomeVisualReminderKind.diaper => 'Se aproxima un cambio de pañal',
        HomeVisualReminderKind.medication => 'Se aproxima una medicina',
      },
      detail: switch (kind) {
        HomeVisualReminderKind.medication when medicationName.isNotEmpty =>
          'Próxima dosis de $medicationName',
        HomeVisualReminderKind.medication => 'Próxima dosis programada',
        HomeVisualReminderKind.formula => 'Relleno programado',
        HomeVisualReminderKind.bottle => 'Mamadera programada',
        HomeVisualReminderKind.feeding => 'Próxima toma programada',
        HomeVisualReminderKind.diaper => 'Cambio programado',
      },
      startsAt: entity.startsAt.toLocal(),
    );
  }

  static HomeVisualReminderVm? activeAt(
    Iterable<HomeVisualReminderVm> reminders,
    DateTime referenceDate,
  ) {
    final windowEnd = referenceDate.add(visibilityWindow);
    final visible = reminders
        .where((reminder) => reminder.startsAt.isAfter(referenceDate))
        .where((reminder) => !reminder.startsAt.isAfter(windowEnd))
        .toList()
      ..sort((first, second) => first.startsAt.compareTo(second.startsAt));
    return visible.firstOrNull;
  }

  static DateTime? nextTransitionAt(
    Iterable<HomeVisualReminderVm> reminders,
    DateTime referenceDate,
  ) {
    final transitions = <DateTime>[];
    for (final reminder in reminders) {
      final appearsAt = reminder.startsAt.subtract(visibilityWindow);
      if (appearsAt.isAfter(referenceDate)) transitions.add(appearsAt);
      if (reminder.startsAt.isAfter(referenceDate)) {
        transitions.add(reminder.startsAt);
      }
    }
    transitions.sort();
    return transitions.firstOrNull;
  }

  @override
  List<Object?> get props => [id, kind, title, detail, startsAt];
}

class HomeActiveBabyVm extends Equatable {
  const HomeActiveBabyVm({
    this.id = '',
    required this.name,
    required this.ageLabel,
    required this.avatarAssetPath,
    required this.familyContextLabel,
    this.siblings = const [],
  });

  final String id;
  final String name;
  final String ageLabel;
  final String? avatarAssetPath;
  final String familyContextLabel;
  final List<HomeSiblingVm> siblings;

  @override
  List<Object?> get props => [
        id,
        name,
        ageLabel,
        avatarAssetPath,
        familyContextLabel,
        siblings,
      ];
}

class HomeSiblingVm extends Equatable {
  const HomeSiblingVm({
    required this.id,
    required this.name,
    required this.ageLabel,
    required this.avatarAssetPath,
  });

  final String id;
  final String name;
  final String ageLabel;
  final String? avatarAssetPath;

  @override
  List<Object?> get props => [id, name, ageLabel, avatarAssetPath];
}

enum HomeMetricType { feeding, sleep, diaper }

enum HomeQuickActionKind { feeding, sleep, diaper, observation, medicine }

enum HomeUpcomingHealthKind { control, vaccine, medicine }

enum HomeRecentStatus { success, warning, information }

class HomeTodayMetricVm extends Equatable {
  const HomeTodayMetricVm({
    required this.type,
    required this.label,
    required this.value,
    required this.unit,
    required this.lastLabel,
    required this.lastValue,
  });

  final HomeMetricType type;
  final String label;
  final String value;
  final String unit;
  final String lastLabel;
  final String lastValue;

  @override
  List<Object?> get props => [
        type,
        label,
        value,
        unit,
        lastLabel,
        lastValue,
      ];
}

class HomeQuickActionVm extends Equatable {
  const HomeQuickActionVm({
    required this.id,
    required this.type,
    required this.label,
  });

  final String id;
  final HomeQuickActionKind type;
  final String label;

  @override
  List<Object?> get props => [id, type, label];
}

class HomeUpcomingHealthVm extends Equatable {
  const HomeUpcomingHealthVm({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.caregiverLabel,
    required this.type,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final String caregiverLabel;
  final HomeUpcomingHealthKind type;

  @override
  List<Object?> get props => [
        title,
        dateLabel,
        timeLabel,
        caregiverLabel,
        type,
      ];
}

class HomeRecentInformationVm extends Equatable {
  const HomeRecentInformationVm({
    required this.title,
    required this.dateLabel,
    required this.description,
    required this.status,
    required this.statusLabel,
  });

  final String title;
  final String dateLabel;
  final String description;
  final HomeRecentStatus status;
  final String statusLabel;

  @override
  List<Object?> get props => [
        title,
        dateLabel,
        description,
        status,
        statusLabel,
      ];
}
