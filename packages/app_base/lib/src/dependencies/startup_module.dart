import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:notifications/notifications.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../startup/startup.dart';

@module
abstract class StartupModule {
  @Named('startupPreferences')
  @lazySingleton
  SharedPreferencesAsync get startupPreferences => SharedPreferencesAsync();

  @lazySingleton
  ActiveContextRepository activeContextRepository(
    @Named('startupPreferences') SharedPreferencesAsync preferences,
  ) =>
      SharedPreferencesActiveContextRepository(preferences);

  @lazySingleton
  FirebaseAuthGateway firebaseAuthGateway() => FirebaseAuthGateway();

  @lazySingleton
  AuthGateway authGateway(FirebaseAuthGateway gateway) => gateway;

  @lazySingleton
  SessionRepository sessionRepository(FirebaseAuthGateway gateway) => gateway;

  @lazySingleton
  NotificationService notificationService(
    PushDeviceRepository pushDeviceRepository,
    ActivityNotificationRepository activityNotificationRepository,
  ) =>
      FirebaseNotificationService(
        registerRemoteDevice: ({
          required String token,
          required String platform,
        }) =>
            pushDeviceRepository.register(
          PushDeviceEntity(token: token, platform: platform),
        ),
        unregisterRemoteDevice: pushDeviceRepository.unregister,
        loadRemoteNotifications: () async {
          final items = await activityNotificationRepository.listUnread();
          return items
              .map(
                (item) => AppNotification(
                  id: item.id,
                  title: item.title,
                  body: item.body,
                  receivedAt: item.createdAt,
                  data: {
                    'route': item.route,
                    for (final entry in item.payload.entries)
                      entry.key: '${entry.value}',
                  },
                  wasOpened: item.readAt != null,
                ),
              )
              .toList(growable: false);
        },
        markRemoteNotificationRead: activityNotificationRepository.markRead,
        markAllRemoteNotificationsRead:
            activityNotificationRepository.markAllRead,
      );

  @lazySingleton
  AuthService authService(
    AuthGateway gateway,
    NotificationService notificationService,
    ProfileRemoteDataSource profileRemoteDataSource,
  ) =>
      AuthService(
        gateway,
        beforeSignOut: notificationService.unregisterCurrentDevice,
        afterAuthentication: (session) =>
            profileRemoteDataSource.syncAuthenticatedUser(session.user),
      );

  @lazySingleton
  ObserveSession observeSession(SessionRepository repository) =>
      ObserveSession(repository);

  @lazySingleton
  GetCurrentSession getCurrentSession(SessionRepository repository) =>
      GetCurrentSession(repository);

  @lazySingleton
  RefreshSession refreshSession(SessionRepository repository) =>
      RefreshSession(repository);

  @lazySingleton
  SignOutSession signOutSession(SessionRepository repository) =>
      SignOutSession(repository);

  @lazySingleton
  OnboardingRepository onboardingRepository(
    @Named('startupPreferences') SharedPreferencesAsync preferences,
    AuthGateway authGateway,
    FamilyRepository familyRepository,
    SupabaseRestClient remoteClient,
  ) =>
      LocalOnboardingRepository(
        preferences,
        currentUserId: () async =>
            (await authGateway.currentSession())?.user.id,
        currentUser: () async => (await authGateway.currentSession())?.user,
        familyRepository: familyRepository,
        remoteClient: remoteClient,
      );

  @lazySingleton
  ResolveEntryDestination resolveEntryDestination(
    AuthGateway authGateway,
    AuthenticatedStartupCoordinator authenticatedStartupCoordinator,
  ) =>
      LocalResolveEntryDestination(
          authGateway, authenticatedStartupCoordinator);

  @lazySingleton
  AuthenticatedStartupCoordinator authenticatedStartupCoordinator(
    GetCurrentSession getCurrentSession,
    BebeDatabase database,
    InitialDataSyncCoordinator initialDataSyncCoordinator,
    FamilySyncService familySyncService,
    SqliteFamilyRepository familyRepository,
    ActiveContextRepository activeContextRepository,
    SupabaseRealtimeSyncCoordinator realtimeSyncCoordinator,
  ) =>
      AuthenticatedStartupCoordinator(
        getCurrentSession: getCurrentSession.call,
        openAccountStorage: () async {
          await database.database;
        },
        synchronizeInitialData: initialDataSyncCoordinator.synchronize,
        readAuthoritativeFamilies: () => familySyncService.lastPulledSnapshots,
        readCachedFamilies: familyRepository.listAvailable,
        activateFamilyBaby: familyRepository.setActiveBaby,
        activeContextRepository: activeContextRepository,
        startRealtime: realtimeSyncCoordinator.start,
      );
}

class LocalResolveEntryDestination implements ResolveEntryDestination {
  LocalResolveEntryDestination(
    this._authGateway,
    this._authenticatedStartupCoordinator, {
    StartupTraceSink trace = emitStartupTrace,
  }) : _trace = trace;

  final AuthGateway _authGateway;
  final AuthenticatedStartupCoordinator _authenticatedStartupCoordinator;
  final StartupTraceSink _trace;

  @override
  Future<EntryResolution> call() async {
    final stopwatch = Stopwatch()..start();
    _trace('entry_resolution_started', const {'result': 'started'});
    try {
      final session = await _authGateway.currentSession();
      if (session == null) {
        _trace('session_resolved', {
          'durationMs': stopwatch.elapsedMilliseconds,
          'result': 'none',
        });
        _trace('entry_resolution_completed', {
          'durationMs': stopwatch.elapsedMilliseconds,
          'result': 'success',
          'destination': EntryDestination.authEntry.name,
        });
        return const EntryResolution(
          destination: EntryDestination.authEntry,
          reason: 'No existe una sesión activa.',
        );
      }
      return _authenticatedStartupCoordinator.resolve(user: session.user);
    } on Object catch (error) {
      _trace('entry_resolution_failed', {
        'durationMs': stopwatch.elapsedMilliseconds,
        'result': 'failure',
        'errorType': error.runtimeType.toString(),
      });
      rethrow;
    }
  }
}
