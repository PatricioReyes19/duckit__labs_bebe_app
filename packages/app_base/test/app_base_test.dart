import 'package:app_base/app_base.dart' as app_base;
import 'package:app_base/src/dependencies/startup_module.dart';
import 'package:app_base/src/router/app_layout_configuration.dart';
import 'package:app_base/src/router/navigation_session_store.dart';
import 'package:app_base/src/router/startup_route_mapper.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('el punto de entrada público incluye el contenedor generado', () {
    expect(app_base.setupAppBaseDependencies, isA<Function>());
  });

  group('LocalResolveEntryDestination', () {
    test('sin sesión abre la entrada de autenticación', () async {
      final resolver = LocalResolveEntryDestination(
        _FakeAuthGateway(),
        _startupCoordinator(const []),
        trace: (_, __) {},
      );

      final result = await resolver();

      expect(result.destination, EntryDestination.authEntry);
    });

    test('con sesión y contexto remoto existente abre home', () async {
      final resolver = LocalResolveEntryDestination(
        _FakeAuthGateway(session: _session),
        _startupCoordinator([_family]),
        trace: (_, __) {},
      );

      final result = await resolver();

      expect(result.destination, EntryDestination.home);
    });

    test('con resolución remota vacía abre onboarding', () async {
      final resolver = LocalResolveEntryDestination(
        _FakeAuthGateway(session: _session),
        _startupCoordinator(const []),
        trace: (_, __) {},
      );

      final result = await resolver();

      expect(result.destination, EntryDestination.onboarding);
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

    test('login y crear cuenta restauran el selector de acceso', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = NavigationSessionStore(preferences);

      await store.remember(Uri.parse(StartupPaths.authEntry));
      await store.remember(Uri.parse(StartupPaths.signUp));
      await store.remember(Uri.parse(StartupPaths.login));

      expect(store.initialLocation, StartupPaths.authEntry);
    });

    test('restaura subrutas funcionales sin perder su nivel padre', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = NavigationSessionStore(preferences);

      await store.remember(Uri.parse('/register/observation'));

      expect(store.initialLocation, '/register/observation');

      await store.remember(Uri.parse('/family/settings'));

      expect(store.initialLocation, '/family/settings');

      await store.remember(Uri.parse('/agenda/events/control-42'));

      expect(store.initialLocation, '/agenda/events/control-42');

      await store.remember(Uri.parse('/family/settings/privacy'));

      expect(store.initialLocation, '/family/settings/privacy');
    });

    test('cerrar sesión elimina la última ruta privada', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = NavigationSessionStore(preferences);

      await store.remember(Uri.parse('/health'));
      await store.clear();

      expect(store.initialLocation, StartupPaths.splash);
    });
  });

  group('AppLayoutVisibilityPolicy', () {
    test('muestra la navegación inferior sólo en las vistas principales', () {
      for (final path in const ['/home', '/agenda', '/health', '/family']) {
        final chrome = appLayoutVisibilityPolicy.resolve(path);

        expect(chrome.showBottomBar, isTrue, reason: path);
        expect(chrome.showPrimaryAction, isTrue, reason: path);
        expect(chrome.showBackButton, isFalse, reason: path);
      }
    });

    test('las subrutas ocultan la navegación inferior y permiten volver', () {
      for (final path in const [
        '/home/history',
        '/agenda/reminders/new',
        '/agenda/events/control-42',
        '/health/vaccines',
        '/family/babies/new',
        '/family/settings/privacy',
      ]) {
        final chrome = appLayoutVisibilityPolicy.resolve(path);

        expect(chrome.showBottomBar, isFalse, reason: path);
        expect(chrome.showPrimaryAction, isFalse, reason: path);
        expect(chrome.showBackButton, isTrue, reason: path);
      }
    });
  });
}

const _session = AuthSession(
  user: AuthUser(
    id: 'caregiver-1',
    email: 'caregiver@example.com',
    displayName: 'Cuidador',
    emailVerification: true,
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

final _family = FamilyOverviewEntity(
  id: 'family-1',
  name: 'Familia',
  activeBabyId: 'baby-1',
  babies: [
    BabyEntity(
      id: 'baby-1',
      familyId: 'family-1',
      name: 'Emma',
      birthDate: DateTime.utc(2026),
    ),
  ],
  members: const [],
);

app_base.AuthenticatedStartupCoordinator _startupCoordinator(
  List<FamilyOverviewEntity> families,
) {
  final contextRepository = _MemoryActiveContextRepository();
  return app_base.AuthenticatedStartupCoordinator(
    getCurrentSession: () async => _session,
    openAccountStorage: () async {},
    synchronizeInitialData: (
        {startRealtime, onMilestone, beforeDomainSync}) async {
      onMilestone?.call(InitialDataSyncMilestone.profileHydrated);
      onMilestone?.call(InitialDataSyncMilestone.familyHydrated);
      final continueSync = await beforeDomainSync?.call() ?? true;
      if (continueSync) {
        onMilestone?.call(InitialDataSyncMilestone.domainSyncStarted);
        await startRealtime?.call();
        onMilestone?.call(InitialDataSyncMilestone.domainSyncCompleted);
      }
      return InitialDataSyncState(
        phase: InitialDataSyncPhase.ready,
        familyState: const RegisterSyncState(
          phase: RegisterSyncPhase.synced,
        ),
      );
    },
    readAuthoritativeFamilies: () => families
        .map(
          (family) => FamilySyncSnapshot(
            overview: family,
            updatedAt: DateTime.utc(2026),
          ),
        )
        .toList(growable: false),
    readCachedFamilies: () async => const [],
    activateFamilyBaby: (_) async => families.single,
    activeContextRepository: contextRepository,
    startRealtime: () async {},
    trace: (_, __) {},
  );
}

class _MemoryActiveContextRepository implements ActiveContextRepository {
  ActiveContext? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<ActiveContext?> read() async => value;

  @override
  Future<void> save(ActiveContext context) async => value = context;
}
