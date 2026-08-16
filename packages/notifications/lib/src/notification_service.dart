import 'notification_message.dart';

typedef RegisterRemoteNotificationDevice =
    Future<void> Function({required String token, required String platform});

typedef UnregisterRemoteNotificationDevice =
    Future<void> Function(String token);

typedef LoadRemoteNotifications = Future<List<AppNotification>> Function();
typedef MarkRemoteNotificationRead = Future<void> Function(String id);
typedef MarkAllRemoteNotificationsRead = Future<void> Function();

enum NotificationPermissionState {
  unknown,
  notDetermined,
  denied,
  granted,
  permanentlyDenied,
  restricted,
}

extension NotificationPermissionStatePolicy on NotificationPermissionState {
  bool get canDeliver => this == NotificationPermissionState.granted;

  bool get requiresSettings =>
      this == NotificationPermissionState.permanentlyDenied ||
      this == NotificationPermissionState.restricted;
}

class NotificationReminder {
  const NotificationReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.route,
  });

  /// Stable occurrence identity within its owner (for example an Agenda
  /// event or a medication schedule). It is never shown to the user.
  final String id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String route;
}

abstract interface class NotificationService {
  List<AppNotification> get currentNotifications;

  Stream<List<AppNotification>> get notifications;

  Stream<AppNotification> get openedNotifications;

  Future<void> initialize();

  Future<void> refreshInbox();

  Future<NotificationPermissionState> permissionState();

  Future<NotificationPermissionState> requestPermission();

  Future<bool> openNotificationSettings();

  Future<void> clearAll();

  Future<void> markOpened(AppNotification notification);

  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String route = '/agenda',
  });

  Future<void> replaceReminders({
    required String ownerId,
    required String accountId,
    required String babyId,
    required List<NotificationReminder> reminders,
  });

  Future<void> cancelReminders(String ownerId);

  Future<void> cancelRemindersForAccount(String accountId);

  Future<void> unregisterCurrentDevice();

  AppNotification? takePendingOpenedNotification();
}
