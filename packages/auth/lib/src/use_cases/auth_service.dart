import '../domain/auth_failure.dart';
import '../domain/auth_gateway.dart';
import '../domain/auth_validation.dart';
import '../domain/entities/auth_session.dart';

class AuthService {
  const AuthService(this._gateway);

  final AuthGateway _gateway;

  Future<AuthSession?> currentSession() => _gateway.currentSession();

  Stream<AuthSession?> sessionChanges() => _gateway.sessionChanges();

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

    return _gateway.signIn(
      email: email.trim().toLowerCase(),
      password: password,
    );
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

    return _gateway.signUp(
      displayName: displayName.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> signOut() => _gateway.signOut();

  Future<void> sendPasswordResetEmail(String email) async {
    final error = AuthValidation.email(email);
    if (error != null) {
      throw AuthValidationFailure({'email': error});
    }
    await _gateway.sendPasswordResetEmail(email.trim().toLowerCase());
  }
}
