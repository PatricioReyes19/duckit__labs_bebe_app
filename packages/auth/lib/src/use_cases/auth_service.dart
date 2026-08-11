import 'package:core/core.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_gateway.dart';
import '../domain/auth_validation.dart';

class AuthService {
  const AuthService(
    this._gateway, {
    this.beforeSignOut,
    this.afterAuthentication,
  });

  final AuthGateway _gateway;
  final Future<void> Function()? beforeSignOut;
  final Future<void> Function(AuthSession session)? afterAuthentication;

  Future<AuthSession?> currentSession() {
    return _gateway.currentSession();
  }

  Stream<AuthSession?> sessionChanges() {
    return _gateway.sessionChanges();
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final errors = <String, String>{
      if (AuthValidation.loginIdentifier(email) case final error?)
        'email': error,
      if (AuthValidation.signInPassword(password) case final error?)
        'password': error,
    };

    if (errors.isNotEmpty) {
      throw AuthValidationFailure(errors);
    }

    final session = await _gateway.signIn(
      email: email.trim().toLowerCase(),
      password: password,
    );
    await _runAfterAuthentication(session);
    return session;
  }

  Future<AuthSession> signUp({
    required String displayName,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    final errors = <String, String>{
      if (AuthValidation.displayName(displayName) case final error?)
        'displayName': error,
      if (AuthValidation.email(email) case final error?) 'email': error,
      if (AuthValidation.password(password) case final error?)
        'password': error,
      if (!acceptedTerms)
        'terms': 'Debes aceptar los términos y la política de privacidad.',
    };

    if (errors.isNotEmpty) {
      throw AuthValidationFailure(errors);
    }

    final session = await _gateway.signUp(
      displayName: displayName.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );
    await _runAfterAuthentication(session);
    return session;
  }

  Future<void> _runAfterAuthentication(AuthSession session) async {
    // Firebase remains the source of truth for the session. Profile syncing is
    // best-effort so a temporary Supabase outage cannot lock the user out.
    try {
      await afterAuthentication?.call(session).timeout(
            const Duration(seconds: 8),
          );
    } on Object {
      // The next login/app resume retries the remote profile synchronization.
    }
  }

  Future<void> signOut() async {
    // La limpieza de notificaciones es complementaria. Un fallo de red al
    // desregistrar el dispositivo nunca debe impedir el cierre de la sesión.
    try {
      await beforeSignOut?.call().timeout(const Duration(seconds: 4));
    } on Object {
      // El gateway sigue siendo la fuente de verdad para cerrar la sesión.
    }
    await _gateway.signOut();
  }

  Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    final error = AuthValidation.email(email);

    if (error != null) {
      throw AuthValidationFailure(
        {'email': error},
      );
    }

    await _gateway.sendPasswordResetEmail(
      email.trim().toLowerCase(),
    );
  }
}
