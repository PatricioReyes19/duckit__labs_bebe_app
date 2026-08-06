import '../../entities/register/register.dart';
import '../../repositories/register_event/register_event.dart';

class SaveRegisterEvent {
  const SaveRegisterEvent(this._repository);

  final RegisterEventRepository _repository;

  Future<RegisteredEvent> call(RegisterEventDraft draft) {
    if (draft.babyId.trim().isEmpty) {
      throw ArgumentError.value(draft.babyId, 'babyId', 'Cannot be empty.');
    }
    if (draft.schemaVersion < 1) {
      throw ArgumentError.value(
        draft.schemaVersion,
        'schemaVersion',
        'Must be positive.',
      );
    }
    return _repository.save(draft);
  }
}
