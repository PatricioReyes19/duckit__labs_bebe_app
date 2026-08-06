import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_gateway.dart';
import '../domain/entities/auth_session.dart';
import '../domain/entities/auth_user.dart';

/// Adaptador local para desarrollo. No persiste ni compara contraseñas.
///
/// Debe reemplazarse por `FirebaseAuthGateway` en la composición productiva.
class LocalAuthGateway implements AuthGateway {
  LocalAuthGateway(this._preferences);

  final SharedPreferencesAsync _preferences;
  final StreamController<AuthSession?> _sessionController =
      StreamController<AuthSession?>.broadcast();

  static const sessionActiveKey = 'bebeapp.session.active';
  static const userIdKey = 'bebeapp.session.user_id';
  static const userEmailKey = 'bebeapp.session.email';
  static const displayNameKey = 'bebeapp.session.display_name';
  static const onboardingCompletedKey = 'bebeapp.onboarding.completed';

  @override
  Future<AuthSession?> currentSession() async {
    final isActive = await _preferences.getBool(sessionActiveKey) ?? false;
    if (!isActive) {
      return null;
    }

    final email = await _preferences.getString(userEmailKey);
    if (email == null || email.isEmpty) {
      return null;
    }

    return AuthSession(
      user: AuthUser(
        id: await _preferences.getString(userIdKey) ?? _idFor(email),
        email: email,
        displayName:
            await _preferences.getString(displayNameKey) ?? _nameFor(email),
      ),
    );
  }

  @override
  Stream<AuthSession?> sessionChanges() async* {
    yield await currentSession();
    yield* _sessionController.stream;
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final session = AuthSession(
      user: AuthUser(
        id: _idFor(email),
        email: email,
        displayName:
            await _preferences.getString(displayNameKey) ?? _nameFor(email),
      ),
    );
    await _persist(session);
    return session;
  }

  @override
  Future<AuthSession> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final session = AuthSession(
      user: AuthUser(
        id: _idFor(email),
        email: email,
        displayName: displayName,
      ),
    );
    await _preferences.setBool(onboardingCompletedKey, false);
    await _persist(session);
    return session;
  }

  Future<void> _persist(AuthSession session) async {
    await _preferences.setBool(sessionActiveKey, true);
    await _preferences.setString(userIdKey, session.user.id);
    await _preferences.setString(userEmailKey, session.user.email);
    await _preferences.setString(displayNameKey, session.user.displayName);
    _sessionController.add(session);
  }

  @override
  Future<void> signOut() async {
    await _preferences.setBool(sessionActiveKey, false);
    _sessionController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // No-op intencional en el adaptador local. Firebase enviará el correo real.
  }

  String _idFor(String email) => 'local-${email.hashCode.abs()}';

  String _nameFor(String email) {
    final localPart = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    if (localPart.isEmpty) {
      return 'Cuidador';
    }
    return localPart
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
