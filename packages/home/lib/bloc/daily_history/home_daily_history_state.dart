part of 'home_daily_history_cubit.dart';

enum DailyHistoryStatus { initial, loading, loaded, failure }

class HomeDailyHistoryState extends Equatable {
  const HomeDailyHistoryState({
    required this.status,
    required this.events,
    required this.referenceDate,
    this.selectedType,
    this.errorMessage,
  });

  factory HomeDailyHistoryState.initial() => HomeDailyHistoryState(
        status: DailyHistoryStatus.initial,
        events: const [],
        referenceDate: DateTime.fromMillisecondsSinceEpoch(0),
      );

  final DailyHistoryStatus status;
  final List<RegisteredEvent> events;
  final DateTime referenceDate;
  final RegisterEventType? selectedType;
  final String? errorMessage;

  List<RegisteredEvent> get filteredEvents => selectedType == null
      ? events
      : events
          .where((event) => event.type == selectedType)
          .toList(growable: false);

  HomeDailyHistoryState copyWith({
    DailyHistoryStatus? status,
    List<RegisteredEvent>? events,
    DateTime? referenceDate,
    RegisterEventType? selectedType,
    bool clearSelectedType = false,
    String? errorMessage,
  }) =>
      HomeDailyHistoryState(
        status: status ?? this.status,
        events: events ?? this.events,
        referenceDate: referenceDate ?? this.referenceDate,
        selectedType:
            clearSelectedType ? null : selectedType ?? this.selectedType,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        events,
        referenceDate,
        selectedType,
        errorMessage,
      ];
}
