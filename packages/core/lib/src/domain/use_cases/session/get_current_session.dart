import 'package:core/core.dart';

class GetCurrentSession {
  GetCurrentSession(this._sessionRepository);

  final SessionRepository _sessionRepository;

  Future<AuthSession?> call() async => _sessionRepository.currentSession();
}
