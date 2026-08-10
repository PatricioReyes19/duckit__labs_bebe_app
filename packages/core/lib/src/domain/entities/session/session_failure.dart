enum SessionFailureCode { network, revoked, unavailable, unknown }

class SessionFailure implements Exception {
  const SessionFailure(this.code, this.message);

  final SessionFailureCode code;
  final String message;

  @override
  String toString() {
    return 'SessionFailure('
        'code: $code, '
        'message: $message'
        ')';
  }
}
