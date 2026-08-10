import 'package:core/core.dart';

class ObserveSession {
  const ObserveSession(this._repository);

  final SessionRepository _repository;

  Stream<AuthSession?> call() {
    return _repository.sessionChanges();
  }
}
