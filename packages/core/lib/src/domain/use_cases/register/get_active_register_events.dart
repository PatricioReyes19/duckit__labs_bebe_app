import '../../entities/register/register.dart';
import '../../repositories/register_event/register_event.dart';

/// Returns every persisted active record for one baby.
///
/// The repository remains the source of baby/account isolation and this use
/// case owns the lifecycle rule, keeping Home free of persistence knowledge.
class GetActiveRegisterEvents {
  const GetActiveRegisterEvents(this._repository);

  final RegisterEventRepository _repository;

  Future<List<RegisteredEvent>> call(String babyId) async {
    final normalizedBabyId = babyId.trim();
    if (normalizedBabyId.isEmpty) {
      throw ArgumentError.value(babyId, 'babyId', 'Cannot be empty.');
    }
    final events = await _repository.listByBaby(normalizedBabyId);
    return events.where((event) => event.isActive).toList(growable: false);
  }
}
