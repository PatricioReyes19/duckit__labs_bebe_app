import '../../entities/home/home.dart';
import '../../entities/health/health.dart';
import '../../entities/register/register.dart';
import '../../repositories/family/family_repository.dart';
import '../../repositories/health/health_repository.dart';
import '../../repositories/register_event/register_event_repository.dart';

typedef HomeClock = DateTime Function();

class GetHomeOverview {
  GetHomeOverview(
    this._familyRepository,
    this._registerRepository,
    this._healthRepository, {
    HomeClock? clock,
  }) : _clock = clock ?? DateTime.now;

  final FamilyRepository _familyRepository;
  final RegisterEventRepository _registerRepository;
  final HealthRepository _healthRepository;
  final HomeClock _clock;

  Stream<void> get changes => _registerRepository.changes;

  Future<HomeOverviewEntity> call() async {
    final family = await _familyRepository.getCurrent();
    final baby = family.activeBaby;
    final now = _clock();
    final results = await Future.wait<Object>([
      _registerRepository.listByBaby(baby.id, limit: 200),
      _healthRepository.getOverview(baby.id),
    ]);
    final events = results[0] as List<RegisteredEvent>;
    final health = results[1] as HealthOverviewEntity;
    final today = events.where((event) => _sameLocalDay(event.occurredAt, now));
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
                    (total, event) =>
                        total + _intValue(event.details['duration_minutes']),
                  )
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
    final sortedEvents = [...events]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return HomeOverviewEntity(
      family: family,
      activeBaby: baby,
      metrics: metrics,
      upcomingHealthEvent: upcoming.isEmpty ? null : upcoming.first,
      mostRecentEvent: sortedEvents.isEmpty ? null : sortedEvents.first,
    );
  }

  static bool _sameLocalDay(DateTime first, DateTime second) {
    final a = first.toLocal();
    final b = second.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
