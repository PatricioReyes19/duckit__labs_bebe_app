import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 8, 16, 18);

  test('UT-SYNCUX-001 SYNCED is silent', () {
    final state = resolveSyncUxState(_allSynced(now));
    final alerts = SyncErrorAlertDeduplicator();

    expect(state.status, SyncUxStatus.synced);
    expect(state.lastSuccessfulSyncAt, now);
    expect(alerts.shouldAlert(state), isFalse);
  });

  test('UT-SYNCUX-002 SYNCING exposes a consolidated state', () {
    final states = _allSynced(now)
      ..[SyncUxScope.register] = const RegisterSyncState(
        phase: RegisterSyncPhase.syncing,
        pendingCount: 2,
      );

    final state = resolveSyncUxState(states);

    expect(state.status, SyncUxStatus.syncing);
    expect(state.pendingOperations, 2);
  });

  test('UT-SYNCUX-003 PENDING exposes locally persisted operations', () {
    final states = _allSynced(now)
      ..[SyncUxScope.agenda] = const RegisterSyncState(
        phase: RegisterSyncPhase.idle,
        pendingCount: 3,
      );

    final state = resolveSyncUxState(states);

    expect(state.status, SyncUxStatus.pending);
    expect(state.pendingOperations, 3);
    expect(state.hasLocallyPersistedChanges, isTrue);
  });

  test('UT-SYNCUX-004 ERROR is actionable without exposing it to UI', () {
    final states = _allSynced(now)
      ..[SyncUxScope.health] = const RegisterSyncState(
        phase: RegisterSyncPhase.failed,
        failedCount: 1,
        message: 'PostgrestException: internal detail',
      );

    final state = resolveSyncUxState(states);

    expect(state.status, SyncUxStatus.error);
    expect(state.canRetry, isTrue);
    expect(state.errorScopes, {SyncUxScope.health});
  });

  test('UT-SYNCUX-005 a persistent error alerts only once', () {
    final alerts = SyncErrorAlertDeduplicator();
    const error = SyncUxState(
      status: SyncUxStatus.error,
      errorKey: 'register:failure-a',
    );

    expect(alerts.shouldAlert(error), isTrue);
    expect(alerts.shouldAlert(error), isFalse);
    expect(
      alerts.shouldAlert(const SyncUxState(status: SyncUxStatus.syncing)),
      isFalse,
    );
    expect(alerts.shouldAlert(error), isFalse);
  });

  test('WT-FAMILY-SYNC-003 connectivity failures resolve to OFFLINE', () {
    final states = _allSynced(now)
      ..[SyncUxScope.family] = const RegisterSyncState(
        phase: RegisterSyncPhase.failed,
        pendingCount: 1,
        failedCount: 1,
        message: 'SocketException: Failed host lookup',
      );

    final state = resolveSyncUxState(states);

    expect(state.status, SyncUxStatus.offline);
    expect(state.pendingOperations, 1);
    expect(state.canRetry, isFalse);
  });

  test('IT-SYNCUX-001 twenty successful syncs produce zero alerts', () {
    final alerts = SyncErrorAlertDeduplicator();
    final successes = List.generate(
      20,
      (index) => SyncUxState(
        status: SyncUxStatus.synced,
        lastSuccessfulSyncAt: now.add(Duration(minutes: index)),
      ),
    );

    expect(successes.where(alerts.shouldAlert), isEmpty);
  });

  test('IT-SYNCUX-002 one persistent error produces one alert', () {
    final alerts = SyncErrorAlertDeduplicator();
    const error = SyncUxState(
      status: SyncUxStatus.error,
      errorKey: 'agenda:persistent-failure',
    );

    final decisions = List.generate(5, (_) => alerts.shouldAlert(error));

    expect(decisions.where((decision) => decision), hasLength(1));
  });

  test('IT-SYNCUX-004 offline create converges through pending to synced', () {
    var states = _allSynced(now)
      ..[SyncUxScope.register] = const RegisterSyncState(
        phase: RegisterSyncPhase.failed,
        pendingCount: 1,
        failedCount: 1,
        message: 'SocketException: Network is unreachable',
      );
    expect(resolveSyncUxState(states).status, SyncUxStatus.offline);

    states = _allSynced(now)
      ..[SyncUxScope.register] = const RegisterSyncState(
        phase: RegisterSyncPhase.idle,
        pendingCount: 1,
      );
    expect(resolveSyncUxState(states).status, SyncUxStatus.pending);

    expect(resolveSyncUxState(_allSynced(now)).status, SyncUxStatus.synced);
  });
}

Map<SyncUxScope, RegisterSyncState> _allSynced(DateTime at) => {
  for (final scope in SyncUxScope.values)
    scope: RegisterSyncState(phase: RegisterSyncPhase.synced, lastSyncedAt: at),
};
