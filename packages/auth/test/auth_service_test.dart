import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('AuthService', () {
    test('acepta un nombre de usuario y contraseña local de 5 caracteres',
        () async {
      final gateway = _FakeAuthGateway();
      final service = AuthService(gateway);

      await service.signIn(email: 'bypass', password: '12345');

      expect(gateway.lastEmail, 'bypass');
    });
    test('normaliza credenciales antes de crear una cuenta', () async {
      final gateway = _FakeAuthGateway();
      final service = AuthService(gateway);

      await service.signUp(
        displayName: '  María López  ',
        email: '  MARIA@CORREO.COM ',
        password: 'segura123',
        acceptedTerms: true,
      );

      expect(gateway.lastDisplayName, 'María López');
      expect(gateway.lastEmail, 'maria@correo.com');
    });

    test('sincroniza el perfil luego de crear cuenta e iniciar sesión',
        () async {
      final gateway = _FakeAuthGateway();
      final synchronizedUsers = <AuthUser>[];
      final service = AuthService(
        gateway,
        afterAuthentication: (session) async {
          synchronizedUsers.add(session.user);
        },
      );

      await service.signUp(
        displayName: 'María López',
        email: 'maria@correo.com',
        password: 'segura123',
        acceptedTerms: true,
      );
      await service.signIn(
        email: 'maria@correo.com',
        password: 'segura123',
      );

      expect(synchronizedUsers, hasLength(2));
      expect(synchronizedUsers.first.displayName, 'María López');
      expect(synchronizedUsers.last.email, 'maria@correo.com');
    });

    test('no bloquea la sesión si falla la sincronización de perfil', () async {
      final gateway = _FakeAuthGateway();
      final service = AuthService(
        gateway,
        afterAuthentication: (_) => throw StateError('Supabase sin conexión'),
      );

      final session = await service.signIn(
        email: 'maria@correo.com',
        password: 'segura123',
      );

      expect(session.user.email, 'maria@correo.com');
    });

    test('no llama al gateway cuando el formulario es inválido', () async {
      final gateway = _FakeAuthGateway();
      final service = AuthService(gateway);

      await expectLater(
        service.signUp(
          displayName: '',
          email: 'correo-invalido',
          password: '123',
          acceptedTerms: false,
        ),
        throwsA(
          isA<AuthValidationFailure>().having(
            (failure) => failure.fieldErrors.keys,
            'campos con error',
            containsAll(['displayName', 'email', 'password', 'terms']),
          ),
        ),
      );
      expect(gateway.signUpCalls, 0);
    });

    test('cierra sesión aunque falle la limpieza previa', () async {
      final gateway = _FakeAuthGateway();
      final service = AuthService(
        gateway,
        beforeSignOut: () => throw StateError('sin conexión'),
      );

      await service.signOut();

      expect(gateway.signOutCalls, 1);
    });
  });

  group('LocalAuthGateway', () {
    test('la cuenta bypass crea sesión y completa el onboarding local',
        () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = SharedPreferencesAsync();
      final gateway = LocalAuthGateway(preferences);

      final session = await gateway.signIn(
        email: 'bypass',
        password: '12345',
      );

      expect(session.user.id, 'local-bypass');
      expect((await gateway.currentSession())?.user.id, 'local-bypass');
      expect(
        await preferences.getBool(LocalAuthGateway.onboardingCompletedKey),
        isTrue,
      );
    });

    test('rechaza cualquier otra credencial local', () async {
      SharedPreferences.setMockInitialValues({});
      final gateway = LocalAuthGateway(SharedPreferencesAsync());

      await expectLater(
        gateway.signIn(email: 'bypass', password: 'incorrecta'),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            AuthFailureCode.invalidCredentials,
          ),
        ),
      );
    });
  });
}

class _FakeAuthGateway implements AuthGateway {
  int signUpCalls = 0;
  int signOutCalls = 0;
  String? lastDisplayName;
  String? lastEmail;

  @override
  Future<AuthSession?> currentSession() async => null;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Stream<AuthSession?> sessionChanges() => const Stream.empty();

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    return AuthSession(
      user: AuthUser(
        id: '1',
        email: email,
        displayName: 'María',
        emailVerification: true,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }

  @override
  Future<AuthSession> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    signUpCalls += 1;
    lastDisplayName = displayName;
    lastEmail = email;
    return AuthSession(
      user: AuthUser(
        id: '1',
        email: email,
        displayName: displayName,
        emailVerification: true,
      ),
    );
  }
}
