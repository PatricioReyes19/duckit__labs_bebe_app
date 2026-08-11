import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:notifications/notifications.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class StartupModule {
  @Named('startupPreferences')
  @lazySingleton
  SharedPreferencesAsync get startupPreferences => SharedPreferencesAsync();

  @lazySingleton
  FirebaseAuthGateway firebaseAuthGateway() => FirebaseAuthGateway();

  @lazySingleton
  AuthGateway authGateway(FirebaseAuthGateway gateway) => gateway;

  @lazySingleton
  SessionRepository sessionRepository(FirebaseAuthGateway gateway) => gateway;

  @lazySingleton
  NotificationService notificationService(
    PushDeviceRepository pushDeviceRepository,
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
      );

  @lazySingleton
  AuthService authService(
    AuthGateway gateway,
    NotificationService notificationService,
  ) =>
      AuthService(
        gateway,
        beforeSignOut: notificationService.unregisterCurrentDevice,
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
    OnboardingRepository onboardingRepository,
  ) =>
      LocalResolveEntryDestination(authGateway, onboardingRepository);
}

class LocalResolveEntryDestination implements ResolveEntryDestination {
  const LocalResolveEntryDestination(
    this._authGateway,
    this._onboardingRepository,
  );

  final AuthGateway _authGateway;
  final OnboardingRepository _onboardingRepository;

  @override
  Future<EntryResolution> call() async {
    final session = await _authGateway.currentSession();
    if (session == null) {
      return const EntryResolution(
        destination: EntryDestination.authEntry,
        reason: 'No existe una sesión activa.',
      );
    }

    if (!await _onboardingRepository.isCompleted()) {
      return const EntryResolution(
        destination: EntryDestination.onboarding,
        reason: 'El onboarding está pendiente.',
      );
    }

    return const EntryResolution(
      destination: EntryDestination.home,
      reason: 'Sesión y contexto inicial disponibles.',
    );
  }
}
