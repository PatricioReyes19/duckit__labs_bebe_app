import 'dart:async';

import '../../entities/agenda/agenda.dart';
import '../../entities/home/home.dart';
import '../../entities/health/health.dart';
import '../../entities/register/register.dart';
import '../../repositories/agenda/agenda_repository.dart';
import '../../repositories/family/family_repository.dart';
import '../../repositories/health/health_repository.dart';
import '../../repositories/register_event/register_event_repository.dart';
import '../register/get_active_register_events.dart';

typedef HomeClock = DateTime Function();

class GetHomeOverview {
  GetHomeOverview(
    this._familyRepository,
    this._registerRepository,
    this._healthRepository, {
    required AgendaRepository agendaRepository,
    GetActiveRegisterEvents? getActiveRegisterEvents,
    HomeClock? clock,
  }) : _agendaRepository = agendaRepository,
       _getActiveRegisterEvents =
           getActiveRegisterEvents ??
           GetActiveRegisterEvents(_registerRepository),
       _clock = clock ?? DateTime.now;

  final FamilyRepository _familyRepository;
  final RegisterEventRepository _registerRepository;
  final HealthRepository _healthRepository;
  final AgendaRepository _agendaRepository;
  final GetActiveRegisterEvents _getActiveRegisterEvents;
  final HomeClock _clock;

  Stream<void> get changes {
    late StreamController<void> controller;
    late final StreamSubscription<void> registerSubscription;
    late final StreamSubscription<void> agendaSubscription;
    late final StreamSubscription<String> familySubscription;
    controller = StreamController<void>(
      onListen: () {
        registerSubscription = _registerRepository.changes.listen(
          controller.add,
        );
        agendaSubscription = _agendaRepository.changes.listen(controller.add);
        familySubscription = _familyRepository.activeBabyChanges.listen(
          (_) => controller.add(null),
        );
      },
      onCancel: () async {
        await registerSubscription.cancel();
        await agendaSubscription.cancel();
        await familySubscription.cancel();
      },
    );
    return controller.stream;
  }

  Future<HomeOverviewEntity> call() async {
    final family = await _familyRepository.getCurrent();
    final baby = family.activeBaby;
    final now = _clock();
    final results = await Future.wait<Object>([
      _registerRepository.listByBaby(baby.id, limit: 200),
      _getActiveRegisterEvents(baby.id),
      _healthRepository.getOverview(baby.id),
      _agendaRepository.getOverview(baby.id),
    ]);
    final events = results[0] as List<RegisteredEvent>;
    final activeEvents = results[1] as List<RegisteredEvent>;
    final health = results[2] as HealthOverviewEntity;
    final agenda = results[3] as AgendaOverviewEntity;
    final today = events.where(
      (event) =>
          _sameLocalDay(event.occurredAt, now) ||
          event.isActive ||
          (event.type == RegisterEventType.sleep &&
              _sameLocalDayIfPresent(event.endedAt, now)),
    );
    final metrics = HomeMetricType.values
        .map((type) {
          final matching =
              today.where((event) => _matches(type, event)).toList()
                ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
          return HomeMetricEntity(
            type: type,
            count: matching.length,
            totalMinutes: type == HomeMetricType.sleep
                ? matching.fold<int>(
                    0,
                    (total, event) => event.isActive
                        ? total
                        : total + _intValue(event.details['duration_minutes']),
                  )
                : 0,
            ongoingCount: type == HomeMetricType.sleep
                ? matching.where((event) => event.isActive).length
                : 0,
            lastOccurredAt: matching.isEmpty ? null : matching.first.occurredAt,
          );
        })
        .toList(growable: false);
    final upcoming =
        health.events
            .where((event) => event.startsAt.isAfter(now))
            .toList(growable: false)
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final sortedEvents = events.where((event) => !event.isActive).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    final careReminders = _careReminders(events, agenda.events, now);

    return HomeOverviewEntity(
      family: family,
      activeBaby: baby,
      metrics: metrics,
      activeRegisterEvents: activeEvents,
      upcomingHealthEvent: upcoming.isEmpty ? null : upcoming.first,
      mostRecentEvent: sortedEvents.isEmpty ? null : sortedEvents.first,
      careReminders: careReminders,
    );
  }

  static List<HomeCareReminderEntity> _careReminders(
    List<RegisteredEvent> registerEvents,
    List<AgendaEventEntity> agendaEvents,
    DateTime now,
  ) {
    final reminders = <HomeCareReminderEntity>[
      for (final event in registerEvents) ..._registerReminder(event, now),
      for (final event in agendaEvents)
        if (event.category == AgendaCategory.medication &&
            event.startsAt.isAfter(now))
          HomeCareReminderEntity(
            id: event.id,
            type: HomeCareReminderType.medication,
            startsAt: event.startsAt,
            title: event.title,
          ),
    ]..sort((first, second) => first.startsAt.compareTo(second.startsAt));
    return reminders.take(100).toList(growable: false);
  }

  static List<HomeCareReminderEntity> _registerReminder(
    RegisteredEvent event,
    DateTime now,
  ) {
    if (event.isDeleted) return const [];
    final details = event.details;
    final scheduled = switch (event.type) {
      RegisterEventType.feeding => details['schedule_next_feeding'] == true,
      RegisterEventType.diaper => details['schedule_reminder'] == true,
      _ => false,
    };
    final hours = _intValue(details['reminder_interval_hours']);
    if (!scheduled || hours <= 0) return const [];
    final startsAt = event.occurredAt.add(Duration(hours: hours));
    if (!startsAt.isAfter(now)) return const [];
    return [
      HomeCareReminderEntity(
        id: 'register-reminder-${event.id}',
        type: event.type == RegisterEventType.diaper
            ? HomeCareReminderType.diaper
            : HomeCareReminderType.feeding,
        startsAt: startsAt,
        title: event.type == RegisterEventType.diaper
            ? 'Próximo cambio de pañal'
            : 'Próxima toma',
        subtype: details['subtype'] as String?,
      ),
    ];
  }

  static bool _sameLocalDay(DateTime first, DateTime second) {
    final a = first.toLocal();
    final b = second.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _sameLocalDayIfPresent(DateTime? first, DateTime second) =>
      first != null && _sameLocalDay(first, second);

  static bool _matches(HomeMetricType type, RegisteredEvent event) =>
      switch (type) {
        HomeMetricType.feeding => event.type == RegisterEventType.feeding,
        HomeMetricType.sleep => event.type == RegisterEventType.sleep,
        HomeMetricType.diaper => event.type == RegisterEventType.diaper,
      };

  static int _intValue(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    _ => int.tryParse('$value') ?? 0,
  };
}
