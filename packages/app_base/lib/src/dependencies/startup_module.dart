import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class StartupModule {
  @Named('startupPreferences')
  @lazySingleton
  SharedPreferencesAsync get startupPreferences => SharedPreferencesAsync();

  @lazySingleton
  AuthGateway authGateway(
    @Named('startupPreferences') SharedPreferencesAsync preferences,
  ) =>
      LocalAuthGateway(preferences);

  @lazySingleton
  AuthService authService(AuthGateway gateway) => AuthService(gateway);

  @lazySingleton
  OnboardingRepository onboardingRepository(
    @Named('startupPreferences') SharedPreferencesAsync preferences,
  ) =>
      LocalOnboardingRepository(preferences);

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
