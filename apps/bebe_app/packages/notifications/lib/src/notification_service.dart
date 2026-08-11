import 'notification_message.dart';

typedef RegisterRemoteNotificationDevice =
    Future<void> Function({required String token, required String platform});

typedef UnregisterRemoteNotificationDevice =
    Future<void> Function(String token);

typedef LoadRemoteNotifications = Future<List<AppNotification>> Function();
typedef MarkRemoteNotificationRead = Future<void> Function(String id);
typedef MarkAllRemoteNotificationsRead = Future<void> Function();

enum NotificationPermissionState {
  notDetermined,
  denied,
  authorized,
  provisional,
}

abstract interface class NotificationService {
  List<AppNotification> get currentNotifications;

  Stream<List<AppNotification>> get notifications;

  Stream<AppNotification> get openedNotifications;

  Future<void> initialize();

  Future<void> refreshInbox();

  Future<NotificationPermissionState> permissionState();

  Future<NotificationPermissionState> requestPermission();

  Future<void> clearAll();

  Future<void> markOpened(AppNotification notification);

  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String route = '/agenda',
  });

  Future<void> unregisterCurrentDevice();

  AppNotification? takePendingOpenedNotification();
}
