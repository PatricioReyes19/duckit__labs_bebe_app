import '../../entities/register/register.dart';
import '../../repositories/register_event/register_event.dart';

class UpdateRegisterEvent {
  const UpdateRegisterEvent(this._repository);

  final RegisterEventRepository _repository;

  Future<RegisteredEvent?> call(String id, RegisterEventPatch patch) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be empty.');
    }
    if (patch.schemaVersion != null && patch.schemaVersion! < 1) {
      throw ArgumentError.value(
        patch.schemaVersion,
        'schemaVersion',
        'Must be positive.',
      );
    }
    return _repository.update(id, patch);
  }
}
