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
  ) {
    return LocalAuthGateway(preferences);
  }

  @lazySingleton
  AuthService authService(AuthGateway gateway) => AuthService(gateway);

  @lazySingleton
  OnboardingRepository onboardingRepository(
    @Named('startupPreferences') SharedPreferencesAsync preferences,
  ) {
    return LocalOnboardingRepository(preferences);
  }

  @lazySingleton
  ResolveEntryDestination resolveEntryDestination(
    AuthGateway authGateway,
    OnboardingRepository onboardingRepository,
  ) {
    return LocalResolveEntryDestination(authGateway, onboardingRepository);
  }
}

class LocalResolveEntryDestination implements ResolveEntryDestination {
  LocalResolveEntryDestination(
    this._authGateway,
    this._onboardingRepository, {
    bool? bypassEnabled,
  }) : _bypassEnabled = bypassEnabled ?? _temporaryStartupBypass;

  final AuthGateway _authGateway;
  final OnboardingRepository _onboardingRepository;
  final bool _bypassEnabled;

  // Herramienta de desarrollo opt-in. El flujo normal siempre debe resolver
  // sesión y onboarding; para saltarlo se requiere:
  // --dart-define=BEBE_APP_BYPASS_STARTUP=true
  static const _temporaryStartupBypass = bool.fromEnvironment(
    'BEBE_APP_BYPASS_STARTUP',
    defaultValue: false,
  );

  @override
  Future<EntryResolution> call() async {
    if (_bypassEnabled) {
      return const EntryResolution(
        destination: EntryDestination.home,
        reason: 'Bypass temporal de inicio habilitado.',
      );
    }

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
