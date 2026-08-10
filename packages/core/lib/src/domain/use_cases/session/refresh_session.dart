import 'package:core/core.dart';

class RefreshSession {
  const RefreshSession(this._repository);

  final SessionRepository _repository;

  Future<AuthSession?> call() {
    return _repository.refreshToken();
  }
}
