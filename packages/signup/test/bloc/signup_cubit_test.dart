import 'package:auth/auth.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup/signup.dart';

void main() {
  blocTest<SignUpCubit, SignUpState>(
    'requiere términos y campos válidos',
    build: () => SignUpCubit(AuthService(_FakeAuthGateway())),
    act: (cubit) => cubit.submitted(),
    verify: (cubit) {
      expect(cubit.state.status, SignUpSubmissionStatus.failure);
      expect(cubit.state.displayNameError, isNotNull);
      expect(cubit.state.emailError, isNotNull);
      expect(cubit.state.passwordError, isNotNull);
      expect(cubit.state.termsError, isNotNull);
    },
  );

  blocTest<SignUpCubit, SignUpState>(
    'crea la cuenta al completar el formulario',
    build: () => SignUpCubit(AuthService(_FakeAuthGateway())),
    act: (cubit) async {
      cubit.displayNameChanged('María López');
      cubit.emailChanged('maria@correo.com');
      cubit.passwordChanged('segura123');
      cubit.termsChanged(true);
      await cubit.submitted();
    },
    verify: (cubit) {
      expect(cubit.state.status, SignUpSubmissionStatus.success);
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
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthSession> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
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
