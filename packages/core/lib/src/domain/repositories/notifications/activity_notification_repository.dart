import '../../entities/notifications/activity_notification.dart';

abstract interface class ActivityNotificationRepository {
  Future<List<ActivityNotificationEntity>> listUnread({int limit = 100});

  Future<void> markRead(String id);

  Future<void> markAllRead();
}
