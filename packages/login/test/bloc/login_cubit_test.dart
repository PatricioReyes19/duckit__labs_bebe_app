import 'package:auth/auth.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login/login.dart';

void main() {
  blocTest<LoginCubit, LoginState>(
    'expone errores de validación sin invocar el backend',
    build: () => LoginCubit(AuthService(_FakeAuthGateway())),
    act: (cubit) => cubit.submitted(),
    verify: (cubit) {
      expect(cubit.state.status, LoginSubmissionStatus.failure);
      expect(cubit.state.emailError, isNotNull);
      expect(cubit.state.passwordError, isNotNull);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'emite éxito cuando auth acepta las credenciales',
    build: () => LoginCubit(AuthService(_FakeAuthGateway())),
    act: (cubit) async {
      cubit.emailChanged('maria@correo.com');
      cubit.passwordChanged('segura123');
      await cubit.submitted();
    },
    verify: (cubit) {
      expect(cubit.state.status, LoginSubmissionStatus.success);
    },
  );
}

class _FakeAuthGateway implements AuthGateway {
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
      user: AuthUser(
        id: '1',
        email: email,
        displayName: 'María',
        emailVerification: true,
      ),
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
    throw UnimplementedError();
  }
}
