import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_inbox_store.dart';
import 'notification_message.dart';
import 'notification_schedule_store.dart';
import 'notification_service.dart';

bool _backgroundHandlerRegistered = false;

void registerNotificationBackgroundHandler() {
  if (_backgroundHandlerRegistered) {
    return;
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  _backgroundHandlerRegistered = true;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final notification = AppNotification.fromRemoteMessage(message);
    final accountId = notification.accountId;
    if (accountId == null) return;
    await NotificationInboxStore().add(notification, accountId: accountId);
  } on Object catch (error) {
    debugPrint('No se pudo guardar la notificación en segundo plano: $error');
  }
}

class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FlutterLocalNotificationsPlugin? localNotifications,
    NotificationInboxStore? inboxStore,
    NotificationScheduleStore? scheduleStore,
    RegisterRemoteNotificationDevice? registerRemoteDevice,
    UnregisterRemoteNotificationDevice? unregisterRemoteDevice,
    LoadRemoteNotifications? loadRemoteNotifications,
    MarkRemoteNotificationRead? markRemoteNotificationRead,
    MarkAllRemoteNotificationsRead? markAllRemoteNotificationsRead,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _inboxStore = inboxStore ?? NotificationInboxStore(),
       _scheduleStore = scheduleStore ?? NotificationScheduleStore(),
       _registerRemoteDevice = registerRemoteDevice,
       _unregisterRemoteDevice = unregisterRemoteDevice,
       _loadRemoteNotifications = loadRemoteNotifications,
       _markRemoteNotificationRead = markRemoteNotificationRead,
       _markAllRemoteNotificationsRead = markAllRemoteNotificationsRead;

  static const _channel = AndroidNotificationChannel(
    'bebeapp_high_importance',
    'Notificaciones importantes',
    description: 'Alertas, recordatorios y actividad del círculo de cuidado.',
    importance: Importance.high,
  );

  static const _reminderChannel = AndroidNotificationChannel(
    'bebeapp_reminders',
    'Alarmas y recordatorios',
    description: 'Alarmas de medicamentos, alimentación y cambios de pañal.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationInboxStore _inboxStore;
  final NotificationScheduleStore _scheduleStore;
  final RegisterRemoteNotificationDevice? _registerRemoteDevice;
  final UnregisterRemoteNotificationDevice? _unregisterRemoteDevice;
  final LoadRemoteNotifications? _loadRemoteNotifications;
  final MarkRemoteNotificationRead? _markRemoteNotificationRead;
  final MarkAllRemoteNotificationsRead? _markAllRemoteNotificationsRead;
  final StreamController<List<AppNotification>> _notificationsController =
      StreamController<List<AppNotification>>.broadcast();
  final StreamController<AppNotification> _openedController =
      StreamController<AppNotification>.broadcast();

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  List<AppNotification> _currentNotifications = <AppNotification>[];
  AppNotification? _pendingOpenedNotification;
  String? _registeredUserId;
  String? _registeredToken;
  bool _initialized = false;

  static const _permissionChannel = MethodChannel(
    'com.duckitlabs.bebeapp/notification_permission',
  );

  @override
  List<AppNotification> get currentNotifications =>
      List<AppNotification>.unmodifiable(_currentNotifications);

  @override
  Stream<List<AppNotification>> get notifications =>
      _notificationsController.stream;

  @override
  Stream<AppNotification> get openedNotifications => _openedController.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    await refreshInbox();
    await _initializeLocalNotifications();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _subscriptions
      ..add(
        FirebaseMessaging.onMessage.listen(
          (message) => unawaited(_handleForegroundMessage(message)),
        ),
      )
      ..add(
        FirebaseMessaging.onMessageOpenedApp.listen(
          (message) => unawaited(_handleOpenedRemoteMessage(message)),
        ),
      )
      ..add(
        _messaging.onTokenRefresh.listen(
          (token) => unawaited(_registerToken(token)),
        ),
      )
      ..add(
        _auth.userChanges().listen(
          (user) => unawaited(_handleAuthenticatedUser(user)),
        ),
      );

    final localLaunch = await _localNotifications
        .getNotificationAppLaunchDetails();
    final localResponse = localLaunch?.notificationResponse;
    if (localLaunch?.didNotificationLaunchApp ?? false) {
      await _handleLocalNotificationTap(localResponse?.payload);
    }

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await _handleOpenedRemoteMessage(initialMessage);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        unawaited(_handleLocalNotificationTap(response.payload));
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_reminderChannel);
  }

  @override
  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String route = '/agenda',
  }) async {
    final accountId = _auth.currentUser?.uid;
    if (kIsWeb ||
        accountId == null ||
        !scheduledAt.isAfter(DateTime.now()) ||
        !(await permissionState()).canDeliver) {
      return;
    }
    await initialize();
    final replacement = await _scheduleStore.replace(
      ownerId: id,
      accountId: accountId,
      babyId: '',
      reminderIds: [id],
    );
    for (final previousId in replacement.previousPlatformIds) {
      await _localNotifications.cancel(id: previousId);
    }
    final platformId = replacement.platformIdsByReminder[id]!;
    final notification = AppNotification(
      id: id,
      title: title,
      body: body,
      receivedAt: scheduledAt,
      data: {'route': route, 'account_id': accountId},
    );
    await _localNotifications.zonedSchedule(
      id: platformId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt.toUtc(), tz.UTC),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'bebeapp_reminders',
          'Alarmas y recordatorios',
          channelDescription:
              'Alarmas de medicamentos, alimentación y cambios de pañal.',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          ticker: 'Recordatorio de BebéApp',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(notification.toJson()),
    );
  }

  @override
  Future<void> replaceReminders({
    required String ownerId,
    required String accountId,
    required String babyId,
    required List<NotificationReminder> reminders,
  }) async {
    if (kIsWeb ||
        accountId.isEmpty ||
        ownerId.isEmpty ||
        _auth.currentUser?.uid != accountId) {
      return;
    }
    final permission = await permissionState();
    await initialize();
    final futureReminders = permission.canDeliver
        ? reminders
              .where((reminder) => reminder.scheduledAt.isAfter(DateTime.now()))
              .toList(growable: false)
        : const <NotificationReminder>[];
    final replacement = await _scheduleStore.replace(
      ownerId: ownerId,
      accountId: accountId,
      babyId: babyId,
      reminderIds: futureReminders.map((reminder) => reminder.id),
    );
    for (final previousId in replacement.previousPlatformIds) {
      await _localNotifications.cancel(id: previousId);
    }
    for (final reminder in futureReminders) {
      final platformId = replacement.platformIdsByReminder[reminder.id];
      if (platformId == null) continue;
      final notification = AppNotification(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        receivedAt: reminder.scheduledAt,
        data: {
          'route': reminder.route,
          'account_id': accountId,
          if (babyId.isNotEmpty) 'baby_id': babyId,
        },
      );
      await _localNotifications.zonedSchedule(
        id: platformId,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.scheduledAt.toUtc(), tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'bebeapp_reminders',
            'Alarmas y recordatorios',
            channelDescription:
                'Alarmas y recordatorios configurados en BebéApp.',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.alarm,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            ticker: 'Recordatorio de BebéApp',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode(notification.toJson()),
      );
    }
  }

  @override
  Future<void> cancelReminders(String ownerId) async {
    if (ownerId.isEmpty) return;
    final platformIds = await _scheduleStore.removeOwner(ownerId);
    for (final platformId in platformIds) {
      await _localNotifications.cancel(id: platformId);
    }
  }

  @override
  Future<void> cancelRemindersForAccount(String accountId) async {
    if (accountId.isEmpty) return;
    final platformIds = await _scheduleStore.removeAccount(accountId);
    for (final platformId in platformIds) {
      await _localNotifications.cancel(id: platformId);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = AppNotification.fromRemoteMessage(message);
    if (!await _record(notification)) return;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications.show(
        id: notification.id.hashCode & 0x7fffffff,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'bebeapp_high_importance',
            'Notificaciones importantes',
            channelDescription:
                'Alertas, recordatorios y actividad del círculo de cuidado.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(notification.toJson()),
      );
    }
  }

  Future<void> _handleOpenedRemoteMessage(RemoteMessage message) async {
    final notification = AppNotification.fromRemoteMessage(
      message,
      wasOpened: true,
    );
    if (!await _record(notification)) return;
    await _tryMarkRemoteRead(notification.id);
    _publishOpened(notification);
  }

  Future<void> _handleLocalNotificationTap(String? payload) async {
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final raw = jsonDecode(payload);
      if (raw is! Map) {
        return;
      }
      final notification = AppNotification.fromJson(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      ).copyWith(wasOpened: true);
      if (!await _record(notification)) return;
      await _tryMarkRemoteRead(notification.id);
      _publishOpened(notification);
    } on Object {
      return;
    }
  }

  Future<bool> _record(AppNotification notification) async {
    final currentAccountId = _auth.currentUser?.uid;
    if (currentAccountId == null ||
        (notification.accountId != null &&
            notification.accountId != currentAccountId)) {
      return false;
    }
    final scoped = notification.accountId == null
        ? notification.copyWith(
            data: {...notification.data, 'account_id': currentAccountId},
          )
        : notification;
    _currentNotifications = await _inboxStore.add(
      scoped,
      accountId: currentAccountId,
    );
    _emitNotifications();
    return true;
  }

  void _publishOpened(AppNotification notification) {
    if (_openedController.hasListener) {
      _openedController.add(notification);
      return;
    }
    _pendingOpenedNotification = notification;
  }

  @override
  AppNotification? takePendingOpenedNotification() {
    final pending = _pendingOpenedNotification;
    _pendingOpenedNotification = null;
    return pending;
  }

  @override
  Future<void> refreshInbox() async {
    final accountId = _auth.currentUser?.uid;
    if (accountId == null) {
      _currentNotifications = <AppNotification>[];
      _pendingOpenedNotification = null;
      _emitNotifications();
      return;
    }
    final local = await _inboxStore.load(accountId: accountId);
    var remote = const <AppNotification>[];
    try {
      remote = await _loadRemoteNotifications?.call() ?? const [];
    } on Object catch (error) {
      debugPrint('No se pudo actualizar la bandeja desde Supabase: $error');
    }
    final merged =
        <String, AppNotification>{
          for (final item in local) item.id: item,
          for (final item in remote)
            item.id: item.copyWith(
              data: {...item.data, 'account_id': accountId},
            ),
        }.values.toList()..sort(
          (first, second) => second.receivedAt.compareTo(first.receivedAt),
        );
    _currentNotifications = merged.take(100).toList(growable: false);
    await _inboxStore.save(_currentNotifications, accountId: accountId);
    _emitNotifications();
  }

  @override
  Future<void> clearAll() async {
    final accountId = _auth.currentUser?.uid ?? _registeredUserId;
    try {
      await _markAllRemoteNotificationsRead?.call();
    } on Object catch (error) {
      debugPrint('No se pudo marcar la bandeja remota como leída: $error');
    } finally {
      if (accountId != null) {
        await _inboxStore.clear(accountId: accountId);
      }
      _currentNotifications = <AppNotification>[];
      _pendingOpenedNotification = null;
      _emitNotifications();
    }
  }

  @override
  Future<void> markOpened(AppNotification notification) async {
    final opened = notification.copyWith(wasOpened: true);
    _currentNotifications = [
      for (final item in _currentNotifications)
        if (item.id == notification.id) opened else item,
    ];
    final accountId = _auth.currentUser?.uid;
    if (accountId != null) {
      await _inboxStore.save(_currentNotifications, accountId: accountId);
    }
    _emitNotifications();
    await _tryMarkRemoteRead(notification.id);
  }

  Future<void> _tryMarkRemoteRead(String id) async {
    try {
      await _markRemoteNotificationRead?.call(id);
    } on Object catch (error) {
      debugPrint('No se pudo marcar la notificación remota como leída: $error');
    }
  }

  void _emitNotifications() {
    if (!_notificationsController.isClosed) {
      _notificationsController.add(currentNotifications);
    }
  }

  @override
  Future<NotificationPermissionState> permissionState() async {
    if (!kIsWeb) {
      try {
        final value = await _permissionChannel.invokeMethod<String>('status');
        final nativeState = _permissionStateFromName(value);
        if (nativeState != NotificationPermissionState.unknown) {
          return nativeState;
        }
      } on MissingPluginException {
        // Unit tests and unsupported platforms use the Firebase fallback.
      } on PlatformException {
        // A permission query must never break the main feature.
      }
    }
    try {
      final settings = await _messaging.getNotificationSettings();
      return mapNotificationAuthorizationStatus(
        settings.authorizationStatus,
        deniedIsPermanent:
            !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS),
      );
    } on Object {
      return NotificationPermissionState.unknown;
    }
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    final current = await permissionState();
    if (current.requiresSettings) return current;
    if (!kIsWeb) {
      try {
        await _permissionChannel.invokeMethod<void>('markRequested');
      } on Object {
        // Firebase still owns the system permission dialog.
      }
    }
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    var state = await permissionState();
    if (state == NotificationPermissionState.unknown) {
      state = mapNotificationAuthorizationStatus(
        settings.authorizationStatus,
        deniedIsPermanent:
            !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS),
      );
    }
    if (state.canDeliver &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
    }
    if (state.canDeliver) {
      final token = await _getTokenWhenAvailable();
      if (token != null) {
        await _registerToken(token);
      }
    }
    return state;
  }

  @override
  Future<bool> openNotificationSettings() async {
    if (kIsWeb) return false;
    try {
      return await _permissionChannel.invokeMethod<bool>('openSettings') ??
          false;
    } on Object {
      return false;
    }
  }

  Future<void> _handleAuthenticatedUser(User? user) async {
    if (user == null) {
      _registeredUserId = null;
      _registeredToken = null;
      await clearAll();
      return;
    }

    try {
      final state = await permissionState();
      await refreshInbox();
      if (state.canDeliver) {
        final token = await _getTokenWhenAvailable();
        if (token != null) await _registerToken(token);
      }
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudo inicializar FCM para el usuario: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<String?> _getTokenWhenAvailable() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      for (var attempt = 0; attempt < 5; attempt += 1) {
        if (await _messaging.getAPNSToken() != null) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      if (await _messaging.getAPNSToken() == null) {
        return null;
      }
    }
    return _messaging.getToken();
  }

  Future<void> _registerToken(String token) async {
    final user = _auth.currentUser;
    if (user == null || token.isEmpty) {
      return;
    }

    if (_registeredUserId == user.uid && _registeredToken == token) {
      return;
    }

    try {
      if (_registeredUserId == user.uid && _registeredToken != null) {
        await _unregisterRemoteDevice?.call(_registeredToken!);
      }
      await _registerRemoteDevice?.call(
        token: token,
        platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
      );
      _registeredUserId = user.uid;
      _registeredToken = token;
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudo registrar el token FCM: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> unregisterCurrentDevice() async {
    final user = _auth.currentUser;
    final accountId = user?.uid ?? _registeredUserId;
    String? token = _registeredToken;

    try {
      token ??= await _messaging.getToken();
      if (user != null && token != null && token.isNotEmpty) {
        await _unregisterRemoteDevice?.call(token);
      }
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudo retirar el token FCM: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await _messaging.deleteToken();
    } on Object catch (error) {
      debugPrint('No se pudo eliminar el token FCM local: $error');
    } finally {
      if (accountId != null) {
        await cancelRemindersForAccount(accountId);
        await _inboxStore.clear(accountId: accountId);
      }
      _currentNotifications = <AppNotification>[];
      _pendingOpenedNotification = null;
      _emitNotifications();
      _registeredUserId = null;
      _registeredToken = null;
    }
  }
}

NotificationPermissionState mapNotificationAuthorizationStatus(
  AuthorizationStatus status, {
  bool deniedIsPermanent = false,
}) => switch (status) {
  AuthorizationStatus.authorized ||
  AuthorizationStatus.provisional => NotificationPermissionState.granted,
  AuthorizationStatus.denied =>
    deniedIsPermanent
        ? NotificationPermissionState.permanentlyDenied
        : NotificationPermissionState.denied,
  AuthorizationStatus.notDetermined =>
    NotificationPermissionState.notDetermined,
};

NotificationPermissionState _permissionStateFromName(String? value) =>
    switch (value) {
      'notDetermined' => NotificationPermissionState.notDetermined,
      'granted' => NotificationPermissionState.granted,
      'denied' => NotificationPermissionState.denied,
      'permanentlyDenied' => NotificationPermissionState.permanentlyDenied,
      'restricted' => NotificationPermissionState.restricted,
      _ => NotificationPermissionState.unknown,
    };
