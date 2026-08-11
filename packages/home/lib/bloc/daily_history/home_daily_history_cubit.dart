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
    UpdateRegisterEvent? updateRegisterEvent,
    RegisterEventSyncService? syncService,
    DailyHistoryClock? clock,
  })  : _getRegisterEvents = getRegisterEvents,
        _deleteRegisterEvent = deleteRegisterEvent,
        _updateRegisterEvent = updateRegisterEvent,
        _syncService = syncService,
        _clock = clock ?? DateTime.now,
        super(HomeDailyHistoryState.initial(referenceDate: clock?.call()));

  final GetRegisterEvents _getRegisterEvents;
  final DeleteRegisterEvent? _deleteRegisterEvent;
  final UpdateRegisterEvent? _updateRegisterEvent;
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
              .where(
                (event) =>
                    _sameLocalDay(event.occurredAt, referenceDate) ||
                    _isOngoingSleep(event),
              )
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

  Future<bool> finishSleep(RegisteredEvent event, DateTime endedAt) async {
    final update = _updateRegisterEvent;
    final localEnd = endedAt.toLocal();
    final localStart = event.occurredAt.toLocal();
    if (update == null ||
        event.type != RegisterEventType.sleep ||
        event.details['sleep_status'] != 'ongoing' ||
        !localEnd.isAfter(localStart)) {
      return false;
    }
    final elapsedMinutes = localEnd.difference(localStart).inMinutes;
    final durationMinutes = elapsedMinutes < 1 ? 1 : elapsedMinutes;
    final details = <String, Object?>{
      ...event.details,
      'sleep_status': 'completed',
      'duration_minutes': durationMinutes,
      'end_at': localEnd.toUtc().toIso8601String(),
    };
    await update(event.id, RegisterEventPatch(details: details));
    return true;
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

  static bool _isOngoingSleep(RegisteredEvent event) =>
      event.type == RegisterEventType.sleep &&
      event.details['sleep_status'] == 'ongoing';

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    await _syncSubscription?.cancel();
    return super.close();
  }
}
