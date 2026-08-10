import '../../domain/entities/notifications/push_device.dart';

class PushDeviceModel {
  const PushDeviceModel({required this.token, required this.platform});

  final String token;
  final String platform;

  factory PushDeviceModel.fromEntity(PushDeviceEntity entity) =>
      PushDeviceModel(token: entity.token, platform: entity.platform);

  Map<String, Object?> toRemoteJson() => {
    'p_token': token,
    'p_platform': platform,
  };
}
