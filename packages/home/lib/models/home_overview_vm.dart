import 'package:equatable/equatable.dart';

class HomeOverviewVm extends Equatable {
  const HomeOverviewVm({
    required this.activeBaby,
    required this.todayMetrics,
    required this.quickActions,
    required this.upcomingHealth,
    required this.recentInformation,
  });

  final HomeActiveBabyVm activeBaby;
  final List<HomeTodayMetricVm> todayMetrics;
  final List<HomeQuickActionVm> quickActions;
  final HomeUpcomingHealthVm upcomingHealth;
  final HomeRecentInformationVm recentInformation;

  @override
  List<Object?> get props => [
        activeBaby,
        todayMetrics,
        quickActions,
        upcomingHealth,
        recentInformation,
      ];
}

class HomeActiveBabyVm extends Equatable {
  const HomeActiveBabyVm({
    required this.name,
    required this.ageLabel,
    required this.avatarAssetPath,
    required this.familyContextLabel,
    this.sibling,
  });

  final String name;
  final String ageLabel;
  final String avatarAssetPath;
  final String familyContextLabel;
  final HomeSiblingVm? sibling;

  @override
  List<Object?> get props => [
        name,
        ageLabel,
        avatarAssetPath,
        familyContextLabel,
        sibling,
      ];
}

class HomeSiblingVm extends Equatable {
  const HomeSiblingVm({
    required this.name,
    required this.ageLabel,
    required this.avatarAssetPath,
  });

  final String name;
  final String ageLabel;
  final String avatarAssetPath;

  @override
  List<Object?> get props => [name, ageLabel, avatarAssetPath];
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
