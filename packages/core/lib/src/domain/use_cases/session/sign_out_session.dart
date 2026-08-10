import 'package:core/core.dart';

class SignOutSession {
  const SignOutSession(this._repository);

  final SessionRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
