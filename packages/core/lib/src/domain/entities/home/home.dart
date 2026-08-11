import '../family/family.dart';
import '../health/health.dart';
import '../register/register.dart';

enum HomeMetricType { feeding, sleep, diaper }

enum HomeCareReminderType { feeding, diaper, medication }

class HomeCareReminderEntity {
  const HomeCareReminderEntity({
    required this.id,
    required this.type,
    required this.startsAt,
    required this.title,
    this.subtype,
  });

  final String id;
  final HomeCareReminderType type;
  final DateTime startsAt;
  final String title;
  final String? subtype;
}

class HomeMetricEntity {
  const HomeMetricEntity({
    required this.type,
    required this.count,
    required this.totalMinutes,
    this.ongoingCount = 0,
    this.lastOccurredAt,
  });

  final HomeMetricType type;
  final int count;
  final int totalMinutes;
  final int ongoingCount;
  final DateTime? lastOccurredAt;
}

class HomeOverviewEntity {
  const HomeOverviewEntity({
    required this.family,
    required this.activeBaby,
    required this.metrics,
    required this.upcomingHealthEvent,
    required this.mostRecentEvent,
    this.careReminders = const [],
  });

  final FamilyOverviewEntity family;
  final BabyEntity activeBaby;
  final List<HomeMetricEntity> metrics;
  final HealthEventEntity? upcomingHealthEvent;
  final RegisteredEvent? mostRecentEvent;
  final List<HomeCareReminderEntity> careReminders;
}
