import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_daily_history_state.dart';

typedef DailyHistoryClock = DateTime Function();

class HomeDailyHistoryCubit extends Cubit<HomeDailyHistoryState> {
  HomeDailyHistoryCubit({
    required GetRegisterEvents getRegisterEvents,
    required this.babyId,
    DailyHistoryClock? clock,
  })  : _getRegisterEvents = getRegisterEvents,
        _clock = clock ?? DateTime.now,
        super(HomeDailyHistoryState.initial());

  final GetRegisterEvents _getRegisterEvents;
  final String babyId;
  final DailyHistoryClock _clock;

  Future<void> load() async {
    emit(
        state.copyWith(status: DailyHistoryStatus.loading, errorMessage: null));
    try {
      final referenceDate = _clock();
      final all = await _getRegisterEvents(babyId);
      final today = all
          .where((event) => _sameLocalDay(event.occurredAt, referenceDate))
          .toList(growable: false)
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      emit(state.copyWith(
        status: DailyHistoryStatus.loaded,
        events: today,
        referenceDate: referenceDate,
        errorMessage: null,
      ));
    } on Object catch (error) {
      emit(state.copyWith(
        status: DailyHistoryStatus.failure,
        errorMessage: '$error',
      ));
    }
  }

  Future<void> reload() => load();

  void typeSelected(RegisterEventType? type) {
    emit(state.copyWith(selectedType: type, clearSelectedType: type == null));
  }

  static bool _sameLocalDay(DateTime first, DateTime second) {
    final a = first.toLocal();
    final b = second.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
