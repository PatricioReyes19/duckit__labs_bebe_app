import 'package:core/core.dart';

abstract interface class SessionRepository {
  Future<AuthSession?> currentSession();

  Stream<AuthSession?> sessionChanges();

  Future<String?> getIdToken({required bool forceRefresh});

  Future<AuthSession?> refreshToken();

  Future<void> logout();
}
