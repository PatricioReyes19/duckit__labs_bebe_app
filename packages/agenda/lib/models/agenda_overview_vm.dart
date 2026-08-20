import 'package:core/core.dart';

export 'package:core/core.dart' show AgendaCategory, AgendaSyncStatus;

enum AgendaFilterCategory { all, vaccines, controls, medication, exams }

enum AgendaConnectionStatus { online, offline }

class AgendaOverviewVm {
  const AgendaOverviewVm({
    required this.firstDay,
    required this.lastDay,
    required this.focusedWeekDay,
    required this.selectedWeekDay,
    required this.focusedMonthDay,
    required this.selectedMonthDay,
    required this.selectedCategory,
    required this.events,
    required this.registerEvents,
    required this.markers,
    required this.remindersEnabled,
    required this.connectionStatus,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedWeekDay;
  final DateTime selectedWeekDay;
  final DateTime focusedMonthDay;
  final DateTime selectedMonthDay;
  final AgendaFilterCategory selectedCategory;
  final List<AgendaEventVm> events;
  final List<AgendaRegisterEventVm> registerEvents;
  final List<AgendaMarkerVm> markers;
  final bool remindersEnabled;
  final AgendaConnectionStatus connectionStatus;

  factory AgendaOverviewVm.fromEntity(
    AgendaOverviewEntity entity, {
    required DateTime selectedDay,
  }) {
    final localDay = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    return AgendaOverviewVm(
      firstDay: DateTime(localDay.year - 1),
      lastDay: DateTime(localDay.year + 1, 12, 31),
      focusedWeekDay: localDay,
      selectedWeekDay: localDay,
      focusedMonthDay: localDay,
      selectedMonthDay: localDay,
      selectedCategory: AgendaFilterCategory.all,
      events: entity.events
          .map(AgendaEventVm.fromEntity)
          .toList(growable: false),
      registerEvents: entity.registerEvents
          .map(AgendaRegisterEventVm.fromEntity)
          .toList(growable: false),
      markers: entity.events
          .map(
            (event) => AgendaMarkerVm(
              id: event.id,
              date: event.startsAt.toLocal(),
              category: event.category,
            ),
          )
          .toList(growable: false),
      remindersEnabled: entity.remindersEnabled,
      connectionStatus: entity.isOffline
          ? AgendaConnectionStatus.offline
          : AgendaConnectionStatus.online,
    );
  }

  AgendaOverviewVm copyWith({
    DateTime? focusedWeekDay,
    DateTime? selectedWeekDay,
    DateTime? focusedMonthDay,
    DateTime? selectedMonthDay,
    AgendaFilterCategory? selectedCategory,
    bool? remindersEnabled,
    AgendaConnectionStatus? connectionStatus,
  }) => AgendaOverviewVm(
    firstDay: firstDay,
    lastDay: lastDay,
    focusedWeekDay: focusedWeekDay ?? this.focusedWeekDay,
    selectedWeekDay: selectedWeekDay ?? this.selectedWeekDay,
    focusedMonthDay: focusedMonthDay ?? this.focusedMonthDay,
    selectedMonthDay: selectedMonthDay ?? this.selectedMonthDay,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    events: events,
    registerEvents: registerEvents,
    markers: markers,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    connectionStatus: connectionStatus ?? this.connectionStatus,
  );

  List<AgendaEventVm> eventsFor(DateTime day) => events
      .where((event) => _sameDate(event.startsAt, day))
      .where(_matchesSelectedCategory)
      .toList(growable: false);

  List<AgendaEventVm> upcomingAfter(DateTime day) {
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);
    final candidates = events
        .where((event) => event.startsAt.isAfter(endOfDay))
        .where(_matchesSelectedCategory)
        .toList();
    candidates.sort(
      (first, second) => first.startsAt.compareTo(second.startsAt),
    );

    // A recurrence is materialized as many agenda rows for notifications, but
    // the future-facing UI represents one series by its next occurrence.
    final representedSeries = <String>{};
    return candidates.where((event) {
      final seriesId = event.sourceRegisterEventId?.trim();
      return seriesId == null ||
          seriesId.isEmpty ||
          representedSeries.add(seriesId);
    }).toList(growable: false);
  }

  List<AgendaRegisterEventVm> recordsFor(DateTime day) => registerEvents
      .where((event) => _sameDate(event.occurredAt, day))
      .toList(growable: false);

  AgendaEventVm? get nextEvent {
    final now = DateTime.now();
    final sorted = events.where((event) => event.startsAt.isAfter(now)).toList()
      ..sort((first, second) => first.startsAt.compareTo(second.startsAt));
    return sorted.isEmpty ? null : sorted.first;
  }

  bool _matchesSelectedCategory(AgendaEventVm event) =>
      selectedCategory == AgendaFilterCategory.all ||
      event.category.name == selectedCategory.name;

  static bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class AgendaRegisterEventVm {
  const AgendaRegisterEventVm({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
    required this.syncStatus,
  });

  final String id;
  final RegisterEventType type;
  final String title;
  final String description;
  final DateTime occurredAt;
  final RegisterSyncStatus syncStatus;

  factory AgendaRegisterEventVm.fromEntity(RegisteredEvent entity) =>
      AgendaRegisterEventVm(
        id: entity.id,
        type: entity.type,
        title: _title(entity),
        description: _description(entity),
        occurredAt: entity.occurredAt.toLocal(),
        syncStatus: entity.syncStatus,
      );

  static String _title(RegisteredEvent event) => switch (event.type) {
    RegisterEventType.feeding => 'Alimentación',
    RegisterEventType.sleep => 'Sueño',
    RegisterEventType.diaper => 'Cambio de pañal',
    RegisterEventType.clinicalObservation => 'Observación clínica',
    RegisterEventType.medication =>
      (event.details['name'] as String?)?.trim().isNotEmpty == true
          ? 'Medicamento: ${event.details['name']}'
          : 'Medicamento',
    RegisterEventType.measurement => 'Medición',
  };

  static String _description(RegisteredEvent event) {
    final details = event.details;
    return switch (event.type) {
      RegisterEventType.feeding => _feedingDescription(details),
      RegisterEventType.sleep => _durationDescription(details),
      RegisterEventType.diaper => _diaperDescription(details),
      RegisterEventType.clinicalObservation =>
        (details['description'] as String?) ?? event.notes ?? 'Registrada',
      RegisterEventType.medication => [
        if (details['dose'] != null)
          '${details['dose']} ${details['unit'] ?? ''}',
        if (details['subtype'] != null) '${details['subtype']}',
      ].join(' · '),
      RegisterEventType.measurement =>
        '${details['value'] ?? ''} ${details['unit'] ?? ''}'.trim(),
    };
  }

  static String _feedingDescription(Map<String, Object?> details) {
    final amount = details['amount_ml'];
    if (amount != null) return '$amount mL';
    final duration = details['duration_minutes'];
    return duration == null ? 'Registrada' : '$duration min';
  }

  static String _durationDescription(Map<String, Object?> details) {
    if (details['sleep_status'] == 'ongoing') return 'En curso';
    final duration = details['duration_minutes'];
    return duration == null ? 'Registrado' : '$duration min';
  }

  static String _diaperDescription(Map<String, Object?> details) {
    final subtype = details['subtype'];
    return switch (subtype) {
      'wet' => 'Orina · ${details['urine_amount'] ?? 'normal'}',
      'dirty' => 'Deposición · ${details['amount'] ?? 'normal'}',
      'mixed' => 'Orina y deposición',
      _ => 'Registrado',
    };
  }
}

class AgendaEventVm {
  const AgendaEventVm({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.caregiver,
    this.syncStatus = AgendaSyncStatus.synced,
    this.sourceRegisterEventId,
  });

  final String id;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final AgendaCaregiverVm? caregiver;
  final AgendaSyncStatus syncStatus;
  final String? sourceRegisterEventId;

  bool get isRecurring => sourceRegisterEventId?.trim().isNotEmpty == true;

  factory AgendaEventVm.fromEntity(AgendaEventEntity entity) => AgendaEventVm(
    id: entity.id,
    category: entity.category,
    title: entity.title,
    description: entity.description,
    startsAt: entity.startsAt.toLocal(),
    caregiver: entity.caregiver == null
        ? null
        : AgendaCaregiverVm(
            name: entity.caregiver!.name,
            role: entity.caregiver!.role,
            initials: _initials(entity.caregiver!.name),
          ),
    syncStatus: entity.syncStatus,
    sourceRegisterEventId: entity.sourceRegisterEventId,
  );

  static String _initials(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class AgendaCaregiverVm {
  const AgendaCaregiverVm({
    required this.name,
    required this.role,
    required this.initials,
  });

  final String name;
  final String role;
  final String initials;
}

class AgendaMarkerVm {
  const AgendaMarkerVm({
    required this.id,
    required this.date,
    required this.category,
  });

  final String id;
  final DateTime date;
  final AgendaCategory category;
}
