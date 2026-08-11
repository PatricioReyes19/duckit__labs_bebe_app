class ActivityNotificationEntity {
  ActivityNotificationEntity({
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
}
