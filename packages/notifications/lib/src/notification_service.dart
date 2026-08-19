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

/// Semantic category used to select the notification channel and delivery
/// policy. UI and domain layers must not choose Android/iOS priorities.
enum NotificationReminderType {
  medication,
  healthControl,
  vaccine,
  feeding,
  diaper,
  syncFailure,
  custom,
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
    this.type = NotificationReminderType.custom,
  });

  /// Stable occurrence identity within its owner (for example an Agenda
  /// event or a medication schedule). It is never shown to the user.
  final String id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String route;
  final NotificationReminderType type;
}

class NotificationDiagnosticReminder {
  const NotificationDiagnosticReminder({
    required this.id,
    required this.platformId,
    required this.title,
    required this.scheduledAt,
    required this.type,
    required this.channelId,
    required this.payload,
  });

  final String id;
  final int platformId;
  final String title;
  final DateTime scheduledAt;
  final NotificationReminderType type;
  final String channelId;
  final Map<String, Object?> payload;
}

class NotificationDiagnostics {
  const NotificationDiagnostics({
    required this.permission,
    required this.timeZone,
    required this.pendingNativeCount,
    required this.hasRegisteredFcmToken,
    required this.reminders,
    this.canScheduleExactAlarms,
    this.lastError,
  });

  final NotificationPermissionState permission;
  final String timeZone;
  final int pendingNativeCount;
  final bool hasRegisteredFcmToken;
  final bool? canScheduleExactAlarms;
  final String? lastError;
  final List<NotificationDiagnosticReminder> reminders;
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
    NotificationReminderType type = NotificationReminderType.custom,
  });

  Future<void> replaceReminders({
    required String ownerId,
    required String accountId,
    required String babyId,
    required List<NotificationReminder> reminders,
  });

  Future<void> cancelReminders(String ownerId);

  Future<void> snoozeReminder(
    NotificationReminder reminder, {
    Duration delay = const Duration(minutes: 10),
  });

  Future<void> cancelRemindersForAccount(String accountId);

  Future<void> retainReminderOwners({
    required String accountId,
    required String babyId,
    required Set<String> ownerIds,
  });

  /// Restores future reminders that are persisted locally but missing from
  /// the platform scheduler (for example after a reboot or process recovery).
  Future<void> reconcileReminders();

  Future<NotificationDiagnostics> diagnostics();

  Future<void> scheduleTestReminder();

  Future<void> cancelAllScheduledReminders();

  Future<void> unregisterCurrentDevice();

  AppNotification? takePendingOpenedNotification();
}
