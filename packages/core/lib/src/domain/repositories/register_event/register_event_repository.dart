import '../../entities/register/register.dart';

abstract interface class RegisterEventRepository {
  Future<RegisteredEvent> save(RegisterEventDraft draft);

  Future<RegisteredEvent?> findById(String id);

  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  });

  Future<RegisteredEvent?> update(String id, RegisterEventPatch patch);

  Future<void> delete(String id);
}
