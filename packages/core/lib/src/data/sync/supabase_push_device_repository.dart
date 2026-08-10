import '../../domain/entities/notifications/push_device.dart';
import '../../domain/repositories/notifications/push_device_repository.dart';
import '../models/push_device_model.dart';
import '../network/supabase_rest_client.dart';

class SupabasePushDeviceRepository implements PushDeviceRepository {
  const SupabasePushDeviceRepository(this._client);

  static const registerFunction = 'register_push_device';
  static const unregisterFunction = 'unregister_push_device';

  final SupabaseRestClient _client;

  @override
  Future<void> register(PushDeviceEntity device) async {
    if (!await _client.isAuthenticated()) return;
    await _client.rpc(
      registerFunction,
      parameters: PushDeviceModel.fromEntity(device).toRemoteJson(),
    );
  }

  @override
  Future<void> unregister(String token) async {
    if (!await _client.isAuthenticated()) return;
    await _client.rpc(unregisterFunction, parameters: {'p_token': token});
  }
}
