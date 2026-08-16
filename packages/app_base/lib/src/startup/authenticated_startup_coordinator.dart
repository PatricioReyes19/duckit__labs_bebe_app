import 'dart:async';

import 'package:core/core.dart';

import 'startup_trace.dart';

typedef OpenAccountStorage = Future<void> Function();
typedef ReadCachedFamilies = Future<List<FamilyOverviewEntity>> Function();
typedef ReadAuthoritativeFamilies = List<FamilySyncSnapshot>? Function();
typedef ActivateFamilyBaby = Future<FamilyOverviewEntity> Function(
  String babyId,
);
typedef RunInitialDataSync = Future<InitialDataSyncState> Function({
  Future<void> Function()? startRealtime,
  InitialDataSyncObserver? onMilestone,
  InitialDataSyncContextBarrier? beforeDomainSync,
});

class AuthenticatedStartupFailure implements Exception {
  const AuthenticatedStartupFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthenticatedStartupFailure: $message';
}

class AuthenticatedStartupCoordinator {
  AuthenticatedStartupCoordinator({
    required Future<AuthSession?> Function() getCurrentSession,
    required OpenAccountStorage openAccountStorage,
    required RunInitialDataSync synchronizeInitialData,
    required ReadAuthoritativeFamilies readAuthoritativeFamilies,
    required ReadCachedFamilies readCachedFamilies,
    required ActivateFamilyBaby activateFamilyBaby,
    required ActiveContextRepository activeContextRepository,
    required Future<void> Function() startRealtime,
    StartupTraceSink trace = emitStartupTrace,
  })  : _getCurrentSession = getCurrentSession,
        _openAccountStorage = openAccountStorage,
        _synchronizeInitialData = synchronizeInitialData,
        _readAuthoritativeFamilies = readAuthoritativeFamilies,
        _readCachedFamilies = readCachedFamilies,
        _activateFamilyBaby = activateFamilyBaby,
        _activeContextRepository = activeContextRepository,
        _startRealtime = startRealtime,
        _trace = trace;

  final Future<AuthSession?> Function() _getCurrentSession;
  final OpenAccountStorage _openAccountStorage;
  final RunInitialDataSync _synchronizeInitialData;
  final ReadAuthoritativeFamilies _readAuthoritativeFamilies;
  final ReadCachedFamilies _readCachedFamilies;
  final ActivateFamilyBaby _activateFamilyBaby;
  final ActiveContextRepository _activeContextRepository;
  final Future<void> Function() _startRealtime;
  final StartupTraceSink _trace;
  final Map<String, Future<EntryResolution>> _inFlight = {};
  Future<void> _tail = Future<void>.value();

  Future<EntryResolution> resolve({required AuthUser user}) {
    final existing = _inFlight[user.id];
    if (existing != null) return existing;

    final completer = Completer<EntryResolution>();
    late final Future<EntryResolution> operation;
    operation = completer.future.whenComplete(() {
      if (identical(_inFlight[user.id], operation)) {
        _inFlight.remove(user.id);
      }
    });
    _inFlight[user.id] = operation;
    _tail = _tail.then((_) async {
      try {
        completer.complete(await _resolve(user));
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return operation;
  }

  Future<EntryResolution> _resolve(AuthUser user) async {
    final stopwatch = Stopwatch()..start();
    try {
      await _requireCurrentUser(user.id);
      _trace('session_resolved', {
        'durationMs': stopwatch.elapsedMilliseconds,
        'result': 'authenticated',
      });

      await _openAccountStorage();
      await _requireCurrentUser(user.id);
      _trace('account_storage_ready', {
        'durationMs': stopwatch.elapsedMilliseconds,
        'result': 'ready',
      });

      EntryResolution? contextResolution;
      final syncState = await _synchronizeInitialData(
        startRealtime: _startRealtime,
        onMilestone: (milestone) => _traceMilestone(milestone, stopwatch),
        beforeDomainSync: () async {
          await _requireCurrentUser(user.id);
          final authoritative = _readAuthoritativeFamilies();
          final families = authoritative == null
              ? await _readCachedFamilies()
              : authoritative
                  .map((snapshot) => snapshot.overview)
                  .toList(growable: false);
          final source = authoritative == null ? 'cache' : 'remote';
          _trace('babies_hydrated', {
            'durationMs': stopwatch.elapsedMilliseconds,
            'result': 'resolved',
            'source': source,
            'count': families.fold<int>(
              0,
              (count, family) => count + family.babies.length,
            ),
          });
          contextResolution = await _resolveContext(
            userId: user.id,
            families: families,
            source: source,
            stopwatch: stopwatch,
          );
          return contextResolution!.destination == EntryDestination.home;
        },
      );

      if (syncState.phase == InitialDataSyncPhase.failed ||
          syncState.phase == InitialDataSyncPhase.waitingForAuthentication) {
        throw AuthenticatedStartupFailure(
          syncState.message ?? 'No se pudo hidratar el contexto autenticado.',
        );
      }
      final resolution = contextResolution;
      if (resolution == null) {
        throw const AuthenticatedStartupFailure(
          'La sincronización no produjo una resolución de contexto.',
        );
      }
      await _requireCurrentUser(user.id);
      _trace('entry_resolution_completed', {
        'durationMs': stopwatch.elapsedMilliseconds,
        'result': 'success',
        'destination': resolution.destination.name,
      });
      return resolution;
    } on Object catch (error) {
      _trace('entry_resolution_failed', {
        'durationMs': stopwatch.elapsedMilliseconds,
        'result': 'failure',
        'errorType': error.runtimeType.toString(),
      });
      rethrow;
    }
  }

  Future<EntryResolution> _resolveContext({
    required String userId,
    required List<FamilyOverviewEntity> families,
    required String source,
    required Stopwatch stopwatch,
  }) async {
    final persisted = await _activeContextRepository.read();
    final ownedContext = persisted?.userId == userId ? persisted : null;

    if (families.isEmpty) {
      if (ownedContext != null) await _activeContextRepository.clear();
      return const EntryResolution(
        destination: EntryDestination.onboarding,
        reason: 'La cuenta no posee un círculo de cuidado accesible.',
      );
    }

    FamilyOverviewEntity? family;
    if (ownedContext != null) {
      family = _familyById(families, ownedContext.circleId);
    }
    if (family == null && families.length > 1) {
      if (ownedContext != null) await _activeContextRepository.clear();
      return const EntryResolution(
        destination: EntryDestination.selectCareCircle,
        reason: 'Hay más de un círculo accesible y ninguno está activo.',
      );
    }
    family ??= families.single;

    if (family.babies.isEmpty) {
      if (ownedContext != null) await _activeContextRepository.clear();
      return const EntryResolution(
        destination: EntryDestination.createBaby,
        reason: 'El círculo accesible no posee bebés.',
      );
    }

    BabyEntity? baby;
    if (ownedContext?.circleId == family.id) {
      baby = _babyById(family.babies, ownedContext!.babyId);
    }
    if (baby == null && family.babies.length > 1) {
      if (ownedContext != null) await _activeContextRepository.clear();
      return const EntryResolution(
        destination: EntryDestination.selectBaby,
        reason: 'Hay más de un bebé accesible y ninguno está activo.',
      );
    }
    baby ??= family.babies.single;

    await _activateFamilyBaby(baby.id);
    await _activeContextRepository.save(
      ActiveContext(userId: userId, circleId: family.id, babyId: baby.id),
    );
    _trace(
      ownedContext?.circleId == family.id && ownedContext?.babyId == baby.id
          ? 'active_context_restored'
          : 'active_context_resolved',
      {
        'durationMs': stopwatch.elapsedMilliseconds,
        'result': 'valid',
        'source': source,
      },
    );
    return const EntryResolution(
      destination: EntryDestination.home,
      reason: 'El contexto autenticado fue validado e hidratado.',
    );
  }

  Future<void> _requireCurrentUser(String expectedUserId) async {
    final current = await _getCurrentSession();
    if (current?.user.id != expectedUserId) {
      throw const AuthenticatedStartupFailure(
        'La sesión cambió durante la restauración del contexto.',
      );
    }
  }

  void _traceMilestone(
    InitialDataSyncMilestone milestone,
    Stopwatch stopwatch,
  ) {
    final event = switch (milestone) {
      InitialDataSyncMilestone.profileHydrated => 'profile_hydrated',
      InitialDataSyncMilestone.familyHydrated => 'family_hydrated',
      InitialDataSyncMilestone.domainSyncStarted => 'domain_sync_started',
      InitialDataSyncMilestone.domainSyncCompleted => 'domain_sync_completed',
    };
    _trace(event, {
      'durationMs': stopwatch.elapsedMilliseconds,
      'result': 'success',
    });
  }

  static FamilyOverviewEntity? _familyById(
    List<FamilyOverviewEntity> families,
    String id,
  ) {
    for (final family in families) {
      if (family.id == id) return family;
    }
    return null;
  }

  static BabyEntity? _babyById(List<BabyEntity> babies, String id) {
    for (final baby in babies) {
      if (baby.id == id) return baby;
    }
    return null;
  }
}
