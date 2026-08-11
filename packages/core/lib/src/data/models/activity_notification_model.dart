import '../../domain/entities/notifications/activity_notification.dart';

class ActivityNotificationModel {
  ActivityNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    required this.createdAt,
    required Map<String, Object?> payload,
    this.readAt,
  }) : payload = Map.unmodifiable(payload);

  final String id;
  final String title;
  final String body;
  final String route;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, Object?> payload;

  factory ActivityNotificationModel.fromRemoteJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    return ActivityNotificationModel(
      id: json['id']! as String,
      title: json['title']! as String,
      body: json['body']! as String,
      route: (json['route'] as String?) ?? '/notifications',
      createdAt: DateTime.parse(json['created_at']! as String).toUtc(),
      readAt: switch (json['read_at']) {
        final String value when value.isNotEmpty => DateTime.parse(
          value,
        ).toUtc(),
        _ => null,
      },
      payload: rawPayload is Map
          ? Map<String, Object?>.from(rawPayload)
          : const <String, Object?>{},
    );
  }

  ActivityNotificationEntity toEntity() => ActivityNotificationEntity(
    id: id,
    title: title,
    body: body,
    route: route,
    createdAt: createdAt,
    readAt: readAt,
    payload: payload,
  );
}
