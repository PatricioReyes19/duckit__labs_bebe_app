import 'entities/auth_session.dart';

abstract interface class AuthGateway {
  Future<AuthSession?> currentSession();

  Stream<AuthSession?> sessionChanges();

  Future<AuthSession> signIn({
    required String email,
    required String password,
  });

  Future<AuthSession> signUp({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
