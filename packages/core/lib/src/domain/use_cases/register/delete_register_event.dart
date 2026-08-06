import '../../repositories/register_event/register_event.dart';

class DeleteRegisterEvent {
  const DeleteRegisterEvent(this._repository);

  final RegisterEventRepository _repository;

  Future<void> call(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be empty.');
    }
    return _repository.delete(id);
  }
}
