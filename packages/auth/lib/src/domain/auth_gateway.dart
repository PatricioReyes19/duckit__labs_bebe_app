import 'package:core/core.dart';

/// Puerto implementable con Firebase Auth, Supabase o un fake.
///
/// La UI y AuthService no conocen el SDK concreto. Una futura integración con
/// Firebase solo debe implementar este contrato y registrarlo en la composición.
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
