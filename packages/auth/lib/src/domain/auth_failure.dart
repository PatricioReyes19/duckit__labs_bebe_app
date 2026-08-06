enum AuthFailureCode {
  invalidCredentials,
  emailAlreadyInUse,
  network,
  tooManyRequests,
  unavailable,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);

  final AuthFailureCode code;
  final String message;

  @override
  String toString() => 'AuthFailure($code, $message)';
}

class AuthValidationFailure implements Exception {
  const AuthValidationFailure(this.fieldErrors);

  final Map<String, String> fieldErrors;

  @override
  String toString() => 'AuthValidationFailure($fieldErrors)';
}
