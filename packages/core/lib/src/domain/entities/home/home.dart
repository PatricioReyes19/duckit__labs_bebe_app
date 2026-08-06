import '../family/family.dart';
import '../health/health.dart';
import '../register/register.dart';

enum HomeMetricType { feeding, sleep, diaper }

class HomeMetricEntity {
  const HomeMetricEntity({
    required this.type,
    required this.count,
    required this.totalMinutes,
    this.lastOccurredAt,
  });

  final HomeMetricType type;
  final int count;
  final int totalMinutes;
  final DateTime? lastOccurredAt;
}

class HomeOverviewEntity {
  const HomeOverviewEntity({
    required this.family,
    required this.activeBaby,
    required this.metrics,
    required this.upcomingHealthEvent,
    required this.mostRecentEvent,
  });

  final FamilyOverviewEntity family;
  final BabyEntity activeBaby;
  final List<HomeMetricEntity> metrics;
  final HealthEventEntity? upcomingHealthEvent;
  final RegisteredEvent? mostRecentEvent;
}
