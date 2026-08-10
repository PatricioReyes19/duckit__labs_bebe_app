import '../../entities/notifications/push_device.dart';

abstract interface class PushDeviceRepository {
  Future<void> register(PushDeviceEntity device);

  Future<void> unregister(String token);
}
