import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
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
  });
}

class _FakeAuthGateway implements AuthGateway {
  int signUpCalls = 0;
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
    return AuthSession(
      user: AuthUser(id: '1', email: email, displayName: 'María'),
    );
  }

  @override
  Future<void> signOut() async {}

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
      user: AuthUser(id: '1', email: email, displayName: displayName),
    );
  }
}
