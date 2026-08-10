import '../../entities/register/register.dart';
import '../../repositories/register_event/register_event.dart';

class GetRegisterEvents {
  const GetRegisterEvents(this._repository);

  final RegisterEventRepository _repository;

  Future<List<RegisteredEvent>> call(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) {
    if (babyId.trim().isEmpty) {
      throw ArgumentError.value(babyId, 'babyId', 'Cannot be empty.');
    }
    if (limit != null && limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'Must be positive.');
    }
    return _repository.listByBaby(babyId, type: type, limit: limit);
  }

  Stream<List<RegisteredEvent>> watch(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) {
    if (babyId.trim().isEmpty) {
      throw ArgumentError.value(babyId, 'babyId', 'Cannot be empty.');
    }
    if (limit != null && limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'Must be positive.');
    }
    return _repository.observeByBaby(babyId, type: type, limit: limit);
  }
}
