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
    return events
        .where((event) => event.startsAt.isAfter(endOfDay))
        .where(_matchesSelectedCategory)
        .toList(growable: false);
  }

  AgendaEventVm? get nextEvent {
    final sorted = [...events]
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

class AgendaEventVm {
  const AgendaEventVm({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.caregiver,
    this.syncStatus = AgendaSyncStatus.synced,
  });

  final String id;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final AgendaCaregiverVm? caregiver;
  final AgendaSyncStatus syncStatus;

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
