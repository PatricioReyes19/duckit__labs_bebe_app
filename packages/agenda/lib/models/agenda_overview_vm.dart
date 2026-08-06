enum AgendaCategory {
  all,
  vaccines,
  controls,
  medication,
  exams,
}

enum AgendaSyncStatus {
  synced,
  pending,
  failed,
}

enum AgendaConnectionStatus {
  online,
  offline,
}

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
  final AgendaCategory selectedCategory;
  final List<AgendaEventVm> events;
  final List<AgendaMarkerVm> markers;
  final bool remindersEnabled;
  final AgendaConnectionStatus connectionStatus;

  AgendaOverviewVm copyWith({
    DateTime? focusedWeekDay,
    DateTime? selectedWeekDay,
    DateTime? focusedMonthDay,
    DateTime? selectedMonthDay,
    AgendaCategory? selectedCategory,
    bool? remindersEnabled,
    AgendaConnectionStatus? connectionStatus,
  }) {
    return AgendaOverviewVm(
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
  }

  List<AgendaEventVm> eventsFor(DateTime day) {
    return events
        .where((event) => _sameDate(event.startsAt, day))
        .where(_matchesSelectedCategory)
        .toList(growable: false);
  }

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

  bool _matchesSelectedCategory(AgendaEventVm event) {
    return selectedCategory == AgendaCategory.all ||
        event.category == selectedCategory;
  }

  static bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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
  });

  final String id;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final AgendaCaregiverVm? caregiver;
  final AgendaSyncStatus syncStatus;
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
