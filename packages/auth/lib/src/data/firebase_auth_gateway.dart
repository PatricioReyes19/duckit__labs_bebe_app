import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../domain/auth_failure.dart';
import '../domain/auth_gateway.dart';

class FirebaseAuthGateway implements AuthGateway, SessionRepository {
  FirebaseAuthGateway({
    firebase.FirebaseAuth? firebaseAuth,
  }) : _auth = firebaseAuth ?? firebase.FirebaseAuth.instance;

  final firebase.FirebaseAuth _auth;

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthFailure(
          AuthFailureCode.unavailable,
          'No fue posible obtener el usuario autenticado.',
        );
      }

      return _toSession(user);
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapAuthFailure(error);
    }
  }

  @override
  Future<AuthSession> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthFailure(
          AuthFailureCode.unavailable,
          'No fue posible crear el usuario.',
        );
      }

      await user.updateDisplayName(
        displayName.trim(),
      );

      await user.reload();

      final refreshedUser = _auth.currentUser ?? user;

      return _toSession(refreshedUser);
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapAuthFailure(error);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapAuthFailure(error);
    }
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  @override
  Future<AuthSession?> currentSession() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _toSession(user);
  }

  @override
  Stream<AuthSession?> sessionChanges() {
    return _auth.userChanges().map(
      (user) {
        if (user == null) {
          return null;
        }

        return _toSession(user);
      },
    );
  }

  @override
  Future<String?> getIdToken({
    bool forceRefresh = false,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    try {
      return await user.getIdToken(
        forceRefresh,
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapSessionFailure(error);
    }
  }

  @override
  Future<AuthSession?> refreshToken() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    try {
      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return null;
      }

      return _toSession(refreshedUser);
    } on firebase.FirebaseAuthException catch (error) {
      if (_isRevoked(error)) {
        await _auth.signOut();

        return null;
      }

      throw _mapSessionFailure(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapSessionFailure(error);
    }
  }

  @override
  Future<void> logout() => signOut();

  // ---------------------------------------------------------------------------
  // Mapping
  // ---------------------------------------------------------------------------

  AuthSession _toSession(
    firebase.User user,
  ) {
    return AuthSession(
      user: AuthUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: _displayNameFor(user),
        emailVerification: user.emailVerified,
        photoUrl: user.photoURL,
      ),
    );
  }

  String _displayNameFor(
    firebase.User user,
  ) {
    final displayName = user.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email;

    if (email == null || email.isEmpty) {
      return 'Cuidador';
    }

    final localPart = email.split('@').first;

    if (localPart.isEmpty) {
      return 'Cuidador';
    }

    return localPart;
  }

  AuthFailure _mapAuthFailure(
    firebase.FirebaseAuthException error,
  ) {
    return switch (error.code) {
      'invalid-email' => const AuthFailure(
          AuthFailureCode.invalidEmail,
          'El correo electrónico no es válido.',
        ),
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' =>
        const AuthFailure(
          AuthFailureCode.invalidCredentials,
          'Correo o contraseña incorrectos.',
        ),
      'email-already-in-use' => const AuthFailure(
          AuthFailureCode.emailAlreadyInUse,
          'Ya existe una cuenta asociada a este correo.',
        ),
      'weak-password' => const AuthFailure(
          AuthFailureCode.weakPassword,
          'La contraseña no cumple los requisitos de seguridad.',
        ),
      'user-disabled' => const AuthFailure(
          AuthFailureCode.userDisabled,
          'Esta cuenta se encuentra deshabilitada.',
        ),
      'network-request-failed' => const AuthFailure(
          AuthFailureCode.network,
          'No fue posible conectar con el servicio.',
        ),
      'too-many-requests' => const AuthFailure(
          AuthFailureCode.tooManyRequests,
          'Se realizaron demasiados intentos. Intenta nuevamente más tarde.',
        ),
      'operation-not-allowed' => const AuthFailure(
          AuthFailureCode.operationNotAllowed,
          'Este método de autenticación no está habilitado.',
        ),
      _ => AuthFailure(
          AuthFailureCode.unknown,
          error.message ?? 'Ocurrió un error de autenticación.',
        ),
    };
  }

  SessionFailure _mapSessionFailure(
    firebase.FirebaseAuthException error,
  ) {
    if (_isRevoked(error)) {
      return const SessionFailure(
        SessionFailureCode.revoked,
        'La sesión ya no es válida.',
      );
    }

    if (error.code == 'network-request-failed') {
      return const SessionFailure(
        SessionFailureCode.network,
        'No fue posible validar la sesión.',
      );
    }

    return SessionFailure(
      SessionFailureCode.unknown,
      error.message ?? 'No fue posible procesar la sesión.',
    );
  }

  bool _isRevoked(
    firebase.FirebaseAuthException error,
  ) {
    return error.code == 'user-disabled' || error.code == 'user-not-found';
  }
}
