import 'dart:async';

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_daily_history_state.dart';

typedef DailyHistoryClock = DateTime Function();

class HomeDailyHistoryCubit extends Cubit<HomeDailyHistoryState> {
  HomeDailyHistoryCubit({
    required GetRegisterEvents getRegisterEvents,
    required this.babyId,
    DeleteRegisterEvent? deleteRegisterEvent,
    RegisterEventSyncService? syncService,
    DailyHistoryClock? clock,
  })  : _getRegisterEvents = getRegisterEvents,
        _deleteRegisterEvent = deleteRegisterEvent,
        _syncService = syncService,
        _clock = clock ?? DateTime.now,
        super(HomeDailyHistoryState.initial(referenceDate: clock?.call()));

  final GetRegisterEvents _getRegisterEvents;
  final DeleteRegisterEvent? _deleteRegisterEvent;
  final RegisterEventSyncService? _syncService;
  final String babyId;
  final DailyHistoryClock _clock;
  StreamSubscription<List<RegisteredEvent>>? _eventsSubscription;
  StreamSubscription<RegisterSyncState>? _syncSubscription;

  Future<void> load() async {
    await _eventsSubscription?.cancel();
    await _syncSubscription?.cancel();
    emit(
      state.copyWith(
        status: DailyHistoryStatus.loading,
        errorMessage: null,
      ),
    );
    final referenceDate = _clock();
    try {
      _eventsSubscription = _getRegisterEvents.watch(babyId).listen(
        (all) {
          final today = all
              .where((event) => _sameLocalDay(event.occurredAt, referenceDate))
              .toList(growable: false)
            ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
          emit(
            state.copyWith(
              status: DailyHistoryStatus.loaded,
              events: today,
              referenceDate: referenceDate,
              errorMessage: null,
            ),
          );
        },
        onError: (Object _) => emit(
          state.copyWith(
            status: DailyHistoryStatus.failure,
            errorMessage: 'No pudimos cargar los registros del día.',
          ),
        ),
      );
      final syncService = _syncService;
      if (syncService != null) {
        emit(state.copyWith(syncState: syncService.state));
        _syncSubscription = syncService.states.listen(
          (syncState) => emit(state.copyWith(syncState: syncState)),
        );
        unawaited(syncService.synchronize());
      }
    } on Object {
      emit(
        state.copyWith(
          status: DailyHistoryStatus.failure,
          errorMessage: 'No pudimos cargar los registros del día.',
        ),
      );
    }
  }

  Future<void> reload() => load();

  Future<void> deleteEvent(String id) async {
    final delete = _deleteRegisterEvent;
    if (delete == null) return;
    await delete(id);
  }

  Future<void> synchronize() async {
    await _syncService?.synchronize();
  }

  void typeSelected(RegisterEventType? type) {
    emit(state.copyWith(selectedType: type, clearSelectedType: type == null));
  }

  static bool _sameLocalDay(DateTime first, DateTime second) {
    final a = first.toLocal();
    final b = second.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    await _syncSubscription?.cancel();
    return super.close();
  }
}
