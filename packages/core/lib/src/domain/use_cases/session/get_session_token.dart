import 'package:core/core.dart';

class GetSessionToken {
  const GetSessionToken(this._repository);

  final SessionRepository _repository;

  Future<String?> call({bool forceRefresh = false}) {
    return _repository.getIdToken(forceRefresh: forceRefresh);
  }
}
