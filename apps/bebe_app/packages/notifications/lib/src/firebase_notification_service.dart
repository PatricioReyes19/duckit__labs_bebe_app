import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_inbox_store.dart';
import 'notification_message.dart';
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
    await NotificationInboxStore().add(
      AppNotification.fromRemoteMessage(message),
    );
  } on Object catch (error) {
    debugPrint('No se pudo guardar la notificación en segundo plano: $error');
  }
}

class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? localNotifications,
    NotificationInboxStore? inboxStore,
    RegisterRemoteNotificationDevice? registerRemoteDevice,
    UnregisterRemoteNotificationDevice? unregisterRemoteDevice,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _inboxStore = inboxStore ?? NotificationInboxStore(),
       _registerRemoteDevice = registerRemoteDevice,
       _unregisterRemoteDevice = unregisterRemoteDevice;

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
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationInboxStore _inboxStore;
  final RegisterRemoteNotificationDevice? _registerRemoteDevice;
  final UnregisterRemoteNotificationDevice? _unregisterRemoteDevice;
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
    if (kIsWeb || !scheduledAt.isAfter(DateTime.now())) return;
    await initialize();
    final notification = AppNotification(
      id: id,
      title: title,
      body: body,
      receivedAt: scheduledAt,
      data: {'route': route},
    );
    await _localNotifications.zonedSchedule(
      id: id.hashCode & 0x7fffffff,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: jsonEncode(notification.toJson()),
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = AppNotification.fromRemoteMessage(message);
    await _record(notification);

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
    await _record(notification);
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
      await _record(notification);
      _publishOpened(notification);
    } on Object {
      return;
    }
  }

  Future<void> _record(AppNotification notification) async {
    _currentNotifications = await _inboxStore.add(notification);
    _emitNotifications();
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
    _currentNotifications = await _inboxStore.load();
    _emitNotifications();
  }

  @override
  Future<void> clearAll() async {
    await _inboxStore.clear();
    _currentNotifications = <AppNotification>[];
    _emitNotifications();
  }

  void _emitNotifications() {
    if (!_notificationsController.isClosed) {
      _notificationsController.add(currentNotifications);
    }
  }

  @override
  Future<NotificationPermissionState> permissionState() async {
    final settings = await _messaging.getNotificationSettings();
    return _mapAuthorizationStatus(settings.authorizationStatus);
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final state = _mapAuthorizationStatus(settings.authorizationStatus);
    if (state == NotificationPermissionState.authorized ||
        state == NotificationPermissionState.provisional) {
      final token = await _getTokenWhenAvailable();
      if (token != null) {
        await _registerToken(token);
      }
    }
    return state;
  }

  NotificationPermissionState _mapAuthorizationStatus(
    AuthorizationStatus status,
  ) {
    return switch (status) {
      AuthorizationStatus.authorized => NotificationPermissionState.authorized,
      AuthorizationStatus.provisional =>
        NotificationPermissionState.provisional,
      AuthorizationStatus.denied => NotificationPermissionState.denied,
      AuthorizationStatus.notDetermined =>
        NotificationPermissionState.notDetermined,
    };
  }

  Future<void> _handleAuthenticatedUser(User? user) async {
    if (user == null) {
      _registeredUserId = null;
      _registeredToken = null;
      await clearAll();
      return;
    }

    try {
      await _syncUserProfile(user);
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudo sincronizar el perfil del usuario: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      final state = await requestPermission();
      if (state == NotificationPermissionState.denied) {
        return;
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

  Future<void> _syncUserProfile(User user) async {
    final reference = _firestore.collection('users').doc(user.uid);
    await reference.set(<String, Object?>{
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'emailVerified': user.emailVerified,
      'lastSeenAt': FieldValue.serverTimestamp(),
      if (user.metadata.creationTime case final creationTime?)
        'createdAt': Timestamp.fromDate(creationTime),
    }, SetOptions(merge: true));
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
        await _deviceReference(user.uid, _registeredToken!).delete();
      }

      await _deviceReference(user.uid, token).set(<String, Object?>{
        'token': token,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'enabled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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

  DocumentReference<Map<String, dynamic>> _deviceReference(
    String userId,
    String token,
  ) {
    final tokenId = base64Url.encode(utf8.encode(token)).replaceAll('=', '');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(tokenId);
  }

  @override
  Future<void> unregisterCurrentDevice() async {
    final user = _auth.currentUser;
    String? token = _registeredToken;

    try {
      token ??= await _messaging.getToken();
      if (user != null && token != null && token.isNotEmpty) {
        await _deviceReference(user.uid, token).delete();
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
      _registeredUserId = null;
      _registeredToken = null;
      await clearAll();
    }
  }
}
