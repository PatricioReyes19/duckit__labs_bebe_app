import 'dart:async';

import 'package:app_base/app_base.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UT-ENTRY-002: existing remote context resolves home', () async {
    final harness = _StartupHarness(authoritative: [_family()]);

    final result = await harness.coordinator.resolve(user: _userA);
    await harness.backgroundDomainCompleted.future;

    expect(result.destination, EntryDestination.home);
    expect(harness.activatedBabyIds, ['baby-1']);
    expect(harness.domainSyncCount, 1);
    expect(harness.realtimeCount, 1);
  });

  test(
    'UT-ENTRY-003: empty local cache does not override existing remote baby',
    () async {
      final harness = _StartupHarness(
        authoritative: [_family()],
        cached: const [],
      );

      final result = await harness.coordinator.resolve(user: _userA);

      expect(result.destination, EntryDestination.home);
      expect(result.destination, isNot(EntryDestination.createBaby));
      expect(result.destination, isNot(EntryDestination.onboarding));
    },
  );

  test(
    'UT-STARTUP-INV-002: invited caregiver resolves an accessible baby',
    () async {
      final harness = _StartupHarness(
        user: _userB,
        authoritative: [
          _family(id: 'shared-circle', babyIds: const ['baby-d']),
        ],
        cached: const [],
      );

      final result = await harness.coordinator.resolve(user: _userB);

      expect(result.destination, EntryDestination.home);
      expect(result.destination, isNot(EntryDestination.createBaby));
      expect(harness.activatedBabyIds, ['baby-d']);
    },
  );

  test('UT-ENTRY-004: confirmed circle without babies creates baby', () async {
    final harness = _StartupHarness(
      authoritative: [_family(babyIds: const [])],
    );

    final result = await harness.coordinator.resolve(user: _userA);

    expect(result.destination, EntryDestination.createBaby);
    expect(harness.domainSyncCount, 0);
    expect(harness.activatedBabyIds, isEmpty);
  });

  test('UT-ENTRY-005: remote failure never becomes create baby', () async {
    final harness = _StartupHarness(
      authoritative: const [],
      syncPhase: InitialDataSyncPhase.failed,
    );

    await expectLater(
      harness.coordinator.resolve(user: _userA),
      throwsA(isA<AuthenticatedStartupFailure>()),
    );
    expect(harness.domainSyncCount, 0);
    expect(harness.activatedBabyIds, isEmpty);
  });

  test('UT-ENTRY-006: multiple circles without valid selection asks', () async {
    final harness = _StartupHarness(
      authoritative: [
        _family(id: 'family-1', babyIds: const ['baby-1']),
        _family(id: 'family-2', babyIds: const ['baby-2']),
      ],
    );

    final result = await harness.coordinator.resolve(user: _userA);

    expect(result.destination, EntryDestination.selectCareCircle);
    expect(harness.domainSyncCount, 0);
  });

  test('UT-ENTRY-007: multiple babies without valid selection asks', () async {
    final harness = _StartupHarness(
      authoritative: [
        _family(babyIds: const ['baby-1', 'baby-2']),
      ],
    );

    final result = await harness.coordinator.resolve(user: _userA);

    expect(result.destination, EntryDestination.selectBaby);
    expect(harness.domainSyncCount, 0);
  });

  test('UT-CTX-001: valid persisted context for same user restores', () async {
    final contexts = _MemoryActiveContextRepository(
      const ActiveContext(
        userId: 'user-a',
        circleId: 'family-1',
        babyId: 'baby-2',
      ),
    );
    final harness = _StartupHarness(
      authoritative: [
        _family(babyIds: const ['baby-1', 'baby-2']),
      ],
      contexts: contexts,
    );

    final result = await harness.coordinator.resolve(user: _userA);

    expect(result.destination, EntryDestination.home);
    expect(harness.activatedBabyIds, ['baby-2']);
    expect(contexts.value?.babyId, 'baby-2');
    expect(harness.trace, contains('active_context_restored'));
  });

  test('UT-CTX-002: persisted context from another user is ignored', () async {
    final contexts = _MemoryActiveContextRepository(
      const ActiveContext(
        userId: 'user-a',
        circleId: 'family-a',
        babyId: 'baby-a',
      ),
    );
    final harness = _StartupHarness(
      user: _userB,
      authoritative: [
        _family(
          id: 'family-b',
          babyIds: const ['baby-b1', 'baby-b2'],
        ),
      ],
      contexts: contexts,
    );

    final result = await harness.coordinator.resolve(user: _userB);

    expect(result.destination, EntryDestination.selectBaby);
    expect(contexts.value?.userId, 'user-a');
    expect(contexts.clearCount, 0);
    expect(harness.activatedBabyIds, isEmpty);
  });

  test('UT-CTX-003: revoked persisted baby resolves another baby', () async {
    final contexts = _MemoryActiveContextRepository(
      const ActiveContext(
        userId: 'user-a',
        circleId: 'family-1',
        babyId: 'revoked-baby',
      ),
    );
    final harness = _StartupHarness(
      authoritative: [
        _family(babyIds: const ['baby-available']),
      ],
      contexts: contexts,
    );

    final result = await harness.coordinator.resolve(user: _userA);

    expect(result.destination, EntryDestination.home);
    expect(harness.activatedBabyIds, ['baby-available']);
    expect(contexts.value?.babyId, 'baby-available');
  });

  test('authoritative empty result wins over stale local cache', () async {
    final harness = _StartupHarness(
      authoritative: const [],
      cached: [_family(id: 'stale-family')],
    );

    final result = await harness.coordinator.resolve(user: _userA);

    expect(result.destination, EntryDestination.onboarding);
    expect(harness.activatedBabyIds, isEmpty);
  });

  test('IT-RESTORE-001: same account restores context after login', () async {
    final contexts = _MemoryActiveContextRepository();
    final firstLogin = _StartupHarness(
      authoritative: [_family()],
      contexts: contexts,
    );
    await firstLogin.coordinator.resolve(user: _userA);
    final restoredLogin = _StartupHarness(
      authoritative: [_family()],
      contexts: contexts,
    );

    final result = await restoredLogin.coordinator.resolve(user: _userA);

    expect(result.destination, EntryDestination.home);
    expect(restoredLogin.activatedBabyIds, ['baby-1']);
    expect(restoredLogin.trace, contains('active_context_restored'));
  });

  test('IT-ACCOUNT-001: account B never activates account A context', () async {
    final contexts = _MemoryActiveContextRepository(
      const ActiveContext(
        userId: 'user-a',
        circleId: 'family-a',
        babyId: 'baby-a',
      ),
    );
    final accountB = _StartupHarness(
      user: _userB,
      authoritative: [
        _family(id: 'family-b', babyIds: const ['baby-b']),
      ],
      contexts: contexts,
    );

    final result = await accountB.coordinator.resolve(user: _userB);

    expect(result.destination, EntryDestination.home);
    expect(accountB.activatedBabyIds, ['baby-b']);
    expect(accountB.activatedBabyIds, isNot(contains('baby-a')));
    expect(contexts.value?.userId, 'user-b');
    expect(contexts.value?.circleId, 'family-b');
  });

  test('UT-SYNC-001: context is validated before domain sync', () async {
    final contexts = _MemoryActiveContextRepository();
    final harness = _StartupHarness(
      authoritative: [_family()],
      contexts: contexts,
    );

    await harness.coordinator.resolve(user: _userA);
    await harness.backgroundDomainCompleted.future;

    expect(
      harness.trace,
      containsAllInOrder([
        'profile_hydrated',
        'family_hydrated',
        'babies_hydrated',
        'active_context_resolved',
        'entry_resolution_completed',
        'background_domain_sync_started',
        'background_domain_sync_completed',
      ]),
    );
    expect(contexts.value?.babyId, 'baby-1');
  });

  test('IT-NET-001: slow startup stays unresolved and single-flight', () async {
    final gate = Completer<void>();
    final harness = _StartupHarness(
      authoritative: [_family()],
      syncGate: gate,
    );

    final first = harness.coordinator.resolve(user: _userA);
    final second = harness.coordinator.resolve(user: _userA);
    var completed = false;
    unawaited(first.whenComplete(() => completed = true));
    await Future<void>.delayed(Duration.zero);

    expect(harness.syncCount, 1);
    expect(completed, isFalse);
    expect(harness.domainSyncCount, 0);
    gate.complete();
    expect((await first).destination, EntryDestination.home);
    expect((await second).destination, EntryDestination.home);
    await harness.backgroundDomainCompleted.future;
    expect(harness.syncCount, 2);
    expect(harness.domainSyncCount, 1);
  });

  test('IT-RESUME-001: domain hydration does not retain splash', () async {
    final domainGate = Completer<void>();
    final harness = _StartupHarness(
      authoritative: [_family()],
      domainSyncGate: domainGate,
    );

    final result = await harness.coordinator.resolve(user: _userA);
    await harness.backgroundDomainStarted.future;

    expect(result.destination, EntryDestination.home);
    expect(harness.domainSyncCount, 1);
    expect(harness.realtimeCount, 0);

    domainGate.complete();
    await harness.backgroundDomainCompleted.future;
    expect(harness.realtimeCount, 1);
  });
}

const _userA = AuthUser(
  id: 'user-a',
  email: 'a@example.com',
  displayName: 'A',
  emailVerification: true,
);
const _userB = AuthUser(
  id: 'user-b',
  email: 'b@example.com',
  displayName: 'B',
  emailVerification: true,
);

FamilyOverviewEntity _family({
  String id = 'family-1',
  List<String> babyIds = const ['baby-1'],
}) {
  final babies = babyIds
      .map(
        (babyId) => BabyEntity(
          id: babyId,
          familyId: id,
          name: 'Baby',
          birthDate: DateTime.utc(2026),
        ),
      )
      .toList(growable: false);
  return FamilyOverviewEntity(
    id: id,
    name: 'Family',
    activeBabyId: babies.isEmpty ? '' : babies.first.id,
    babies: babies,
    members: const [],
  );
}

class _StartupHarness {
  _StartupHarness({
    required this.authoritative,
    this.cached = const [],
    this.user = _userA,
    this.syncPhase = InitialDataSyncPhase.ready,
    _MemoryActiveContextRepository? contexts,
    this.syncGate,
    this.domainSyncGate,
  }) : contexts = contexts ?? _MemoryActiveContextRepository() {
    coordinator = AuthenticatedStartupCoordinator(
      getCurrentSession: () async => AuthSession(user: user),
      openAccountStorage: () async {},
      synchronizeInitialData: _synchronize,
      readAuthoritativeFamilies: () => authoritative
          ?.map(
            (family) => FamilySyncSnapshot(
              overview: family,
              updatedAt: DateTime.utc(2026),
            ),
          )
          .toList(growable: false),
      readCachedFamilies: () async => cached,
      activateFamilyBaby: (babyId) async {
        activatedBabyIds.add(babyId);
        return _familyContainingBaby(babyId);
      },
      activeContextRepository: this.contexts,
      startRealtime: () async => realtimeCount += 1,
      trace: (event, _) => trace.add(event),
    );
  }

  final List<FamilyOverviewEntity>? authoritative;
  final List<FamilyOverviewEntity> cached;
  final AuthUser user;
  final InitialDataSyncPhase syncPhase;
  final _MemoryActiveContextRepository contexts;
  final Completer<void>? syncGate;
  final Completer<void>? domainSyncGate;
  late final AuthenticatedStartupCoordinator coordinator;
  final activatedBabyIds = <String>[];
  final trace = <String>[];
  var syncCount = 0;
  var domainSyncCount = 0;
  var realtimeCount = 0;
  final backgroundDomainStarted = Completer<void>();
  final backgroundDomainCompleted = Completer<void>();

  Future<InitialDataSyncState> _synchronize({
    Future<void> Function()? startRealtime,
    InitialDataSyncObserver? onMilestone,
    InitialDataSyncContextBarrier? beforeDomainSync,
  }) async {
    syncCount += 1;
    await syncGate?.future;
    if (syncPhase == InitialDataSyncPhase.failed) {
      return const InitialDataSyncState(
        phase: InitialDataSyncPhase.failed,
        message: 'Remote unavailable',
      );
    }
    onMilestone?.call(InitialDataSyncMilestone.profileHydrated);
    onMilestone?.call(InitialDataSyncMilestone.familyHydrated);
    final continueSync = await beforeDomainSync?.call() ?? true;
    if (continueSync) {
      domainSyncCount += 1;
      if (!backgroundDomainStarted.isCompleted) {
        backgroundDomainStarted.complete();
      }
      onMilestone?.call(InitialDataSyncMilestone.domainSyncStarted);
      await domainSyncGate?.future;
      await startRealtime?.call();
      onMilestone?.call(InitialDataSyncMilestone.domainSyncCompleted);
      if (!backgroundDomainCompleted.isCompleted) {
        backgroundDomainCompleted.complete();
      }
    }
    return InitialDataSyncState(
      phase: syncPhase,
      familyState: RegisterSyncState(
        phase: syncPhase == InitialDataSyncPhase.disabled
            ? RegisterSyncPhase.disabled
            : RegisterSyncPhase.synced,
      ),
    );
  }

  FamilyOverviewEntity _familyContainingBaby(String babyId) {
    final families = authoritative ?? cached;
    return families.firstWhere(
      (family) => family.babies.any((baby) => baby.id == babyId),
    );
  }
}

class _MemoryActiveContextRepository implements ActiveContextRepository {
  _MemoryActiveContextRepository([this.value]);

  ActiveContext? value;
  var clearCount = 0;

  @override
  Future<void> clear() async {
    clearCount += 1;
    value = null;
  }

  @override
  Future<ActiveContext?> read() async => value;

  @override
  Future<void> save(ActiveContext context) async => value = context;
}
