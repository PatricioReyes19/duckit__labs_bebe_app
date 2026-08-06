import 'package:app_base/src/dependencies/startup_module.dart';
import 'package:app_base/src/router/navigation_session_store.dart';
import 'package:app_base/src/router/startup_route_mapper.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalResolveEntryDestination', () {
    test('sin sesión abre la entrada de autenticación', () async {
      final resolver = LocalResolveEntryDestination(
        _FakeAuthGateway(),
        _FakeOnboardingRepository(completed: false),
        bypassEnabled: false,
      );

      final result = await resolver();

      expect(result.destination, EntryDestination.authEntry);
    });

    test('con sesión y onboarding pendiente abre onboarding', () async {
      final resolver = LocalResolveEntryDestination(
        _FakeAuthGateway(session: _session),
        _FakeOnboardingRepository(completed: false),
        bypassEnabled: false,
      );

      final result = await resolver();

      expect(result.destination, EntryDestination.onboarding);
    });

    test('con sesión y onboarding completo abre home', () async {
      final resolver = LocalResolveEntryDestination(
        _FakeAuthGateway(session: _session),
        _FakeOnboardingRepository(completed: true),
        bypassEnabled: false,
      );

      final result = await resolver();

      expect(result.destination, EntryDestination.home);
    });

    test('el bypass temporal abre home sin sesion', () async {
      final resolver = LocalResolveEntryDestination(
        _FakeAuthGateway(),
        _FakeOnboardingRepository(completed: false),
        bypassEnabled: true,
      );

      final result = await resolver();

      expect(result.destination, EntryDestination.home);
    });
  });

  test('StartupRouteMapper cubre todos los destinos declarados', () {
    const mapper = StartupRouteMapper();
    const expectedPaths = <EntryDestination, String>{
      EntryDestination.authEntry: StartupPaths.authEntry,
      EntryDestination.login: StartupPaths.login,
      EntryDestination.signUp: StartupPaths.signUp,
      EntryDestination.onboarding: StartupPaths.onboarding,
      EntryDestination.invitation: StartupPaths.invitation,
      EntryDestination.createCareCircle: StartupPaths.createCareCircle,
      EntryDestination.selectCareCircle: StartupPaths.selectCareCircle,
      EntryDestination.createBaby: StartupPaths.createBaby,
      EntryDestination.selectBaby: StartupPaths.selectBaby,
      EntryDestination.home: StartupPaths.home,
    };

    expect(
      {
        for (final destination in EntryDestination.values)
          destination: mapper.pathFor(destination)
      },
      expectedPaths,
    );
  });

  group('NavigationSessionStore', () {
    test('restaura onboarding sin volver a insertar el splash', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = NavigationSessionStore(preferences);

      await store.remember(Uri.parse(StartupPaths.onboarding));

      expect(store.initialLocation, StartupPaths.onboarding);
    });

    test('el splash limpia la ubicación restaurable', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = NavigationSessionStore(preferences);

      await store.remember(Uri.parse(StartupPaths.onboarding));
      await store.remember(Uri.parse(StartupPaths.splash));

      expect(store.initialLocation, StartupPaths.splash);
    });
  });
}

const _session = AuthSession(
  user: AuthUser(
    id: 'caregiver-1',
    email: 'caregiver@example.com',
    displayName: 'Cuidador',
  ),
);

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway({this.session});

  final AuthSession? session;

  @override
  Future<AuthSession?> currentSession() async => session;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Stream<AuthSession?> sessionChanges() => Stream.value(session);

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async =>
      _session;

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthSession> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async =>
      _session;
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({required this.completed});

  final bool completed;

  @override
  Future<void> acceptInvitation(CareInvitation invitation) async {}

  @override
  Future<void> complete() async {}

  @override
  Future<BabyProfile> createBaby(BabyDraft draft) => throw UnimplementedError();

  @override
  Future<void> declineInvitation(CareInvitation invitation) async {}

  @override
  Future<InvitationLookupResult> findInvitation(String code) =>
      throw UnimplementedError();

  @override
  Future<bool> isCompleted() async => completed;
}
