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

const _openActionId = 'bebeapp_open';
const _snoozeActionId = 'bebeapp_snooze';
const _reminderCategoryId = 'bebeapp_reminder_actions';
const _androidReminderActions = <AndroidNotificationAction>[
  AndroidNotificationAction(
    _openActionId,
    'Abrir BebéApp',
    showsUserInterface: true,
  ),
  AndroidNotificationAction(
    _snoozeActionId,
    'Recordar más tarde',
    showsUserInterface: true,
  ),
];

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
    Future<bool?> Function()? canScheduleExactNotifications,
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
       _markAllRemoteNotificationsRead = markAllRemoteNotificationsRead,
       _canScheduleExactNotificationsOverride = canScheduleExactNotifications;

  static const _channel = AndroidNotificationChannel(
    'bebeapp_high_importance',
    'Notificaciones importantes',
    description: 'Alertas, recordatorios y actividad del círculo de cuidado.',
    importance: Importance.high,
  );

  static const _medicationChannel = AndroidNotificationChannel(
    'medication_high',
    'Medicamentos',
    description: 'Recordatorios importantes de dosis de medicamentos.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const _healthChannel = AndroidNotificationChannel(
    'health_reminders',
    'Salud y controles',
    description: 'Recordatorios de controles, vacunas y atención de salud.',
    importance: Importance.high,
  );

  static const _feedingChannel = AndroidNotificationChannel(
    'feeding_reminders',
    'Alimentación',
    description: 'Recordatorios opcionales de alimentación.',
    importance: Importance.high,
  );

  static const _careChannel = AndroidNotificationChannel(
    'care_reminders',
    'Cuidados diarios',
    description: 'Recordatorios configurados de pañal y cuidados cotidianos.',
    importance: Importance.high,
  );

  static const _systemChannel = AndroidNotificationChannel(
    'system_alerts',
    'Alertas del sistema',
    description: 'Alertas persistentes que requieren atención.',
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
  final Future<bool?> Function()? _canScheduleExactNotificationsOverride;
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
  String? _lastReminderError;
  DateTime? _lastTimeZoneCheckAt;
  bool _timeZoneDatabaseInitialized = false;
  bool _initialized = false;
  Future<void>? _initializing;

  static const _permissionChannel = MethodChannel(
    'com.duckitlabs.bebeapp/notification_permission',
  );
  static const _bulkCancellationThreshold = 20;

  @override
  List<AppNotification> get currentNotifications =>
      List<AppNotification>.unmodifiable(_currentNotifications);

  @override
  Stream<List<AppNotification>> get notifications =>
      _notificationsController.stream;

  @override
  Stream<AppNotification> get openedNotifications => _openedController.stream;

  @override
  Future<void> initialize() {
    if (_initialized) {
      return Future<void>.value();
    }
    final running = _initializing;
    if (running != null) return running;

    final operation = _initializeOnce();
    _initializing = operation;
    return operation.whenComplete(() {
      if (identical(_initializing, operation)) {
        _initializing = null;
      }
    });
  }

  Future<void> _initializeOnce() async {
    try {
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
      if ((localLaunch?.didNotificationLaunchApp ?? false) &&
          localResponse != null) {
        await _handleLocalNotificationResponse(localResponse);
      }

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        await _handleOpenedRemoteMessage(initialMessage);
      }
      _initialized = true;
    } on Object {
      for (final subscription in _subscriptions) {
        await subscription.cancel();
      }
      _subscriptions.clear();
      _initialized = false;
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    await _configureLocalTimeZone();
    final settings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: <DarwinNotificationCategory>[
          DarwinNotificationCategory(
            _reminderCategoryId,
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain(
                _openActionId,
                'Abrir BebéApp',
                options: const <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
              DarwinNotificationAction.plain(
                _snoozeActionId,
                'Recordar más tarde',
                options: const <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
          ),
        ],
      ),
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        unawaited(_handleLocalNotificationResponse(response));
      },
    );

    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final channel in const <AndroidNotificationChannel>[
      _channel,
      _medicationChannel,
      _healthChannel,
      _feedingChannel,
      _careChannel,
      _systemChannel,
    ]) {
      await android?.createNotificationChannel(channel);
    }
  }

  Future<void> _configureLocalTimeZone() async {
    if (!_timeZoneDatabaseInitialized) {
      tz.initializeTimeZones();
      _timeZoneDatabaseInitialized = true;
    }
    final now = DateTime.now();
    final lastCheck = _lastTimeZoneCheckAt;
    if (lastCheck != null &&
        now.difference(lastCheck) < const Duration(seconds: 30)) {
      return;
    }
    _lastTimeZoneCheckAt = now;
    if (kIsWeb) return;
    try {
      final timeZoneName = await _permissionChannel.invokeMethod<String>(
        'timezone',
      );
      if (timeZoneName != null && timeZoneName.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      }
    } on Object catch (error) {
      debugPrint('No se pudo resolver la zona horaria local: $error');
    }
  }

  @override
  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String route = '/agenda',
    NotificationReminderType type = NotificationReminderType.custom,
  }) async {
    final accountId = _auth.currentUser?.uid;
    if (kIsWeb ||
        accountId == null ||
        !scheduledAt.isAfter(DateTime.now()) ||
        !(await permissionState()).canDeliver) {
      return;
    }
    await initialize();
    final reminder = NotificationReminder(
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      route: route,
      type: type,
    );
    final replacement = await _scheduleStore.replace(
      ownerId: id,
      accountId: accountId,
      babyId: '',
      reminderIds: [id],
      reminderData: {id: _scheduleData(reminder)},
    );
    for (final previousId in replacement.previousPlatformIds) {
      await _localNotifications.cancel(id: previousId);
    }
    if (!replacement.reminderIdsToSchedule.contains(id)) return;
    final platformId = replacement.platformIdsByReminder[id]!;
    await _scheduleLocal(
      platformId: platformId,
      reminder: reminder,
      accountId: accountId,
      babyId: '',
    );
  }

  @override
  Future<void> replaceReminders({
    required String ownerId,
    required String accountId,
    required String babyId,
    required List<NotificationReminder> reminders,
  }) async {
    if (kIsWeb) return;
    if (accountId.isEmpty || ownerId.isEmpty) {
      throw ArgumentError('accountId y ownerId son obligatorios.');
    }
    if (_auth.currentUser?.uid != accountId) {
      throw StateError(
        'No se pueden programar recordatorios para otra cuenta.',
      );
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
      reminderData: {
        for (final reminder in futureReminders)
          reminder.id: _scheduleData(reminder),
      },
    );
    for (final previousId in replacement.previousPlatformIds) {
      await _localNotifications.cancel(id: previousId);
    }
    final reminderIdsToSchedule = replacement.reminderIdsToSchedule;
    for (final reminder in futureReminders) {
      if (!reminderIdsToSchedule.contains(reminder.id)) continue;
      final platformId = replacement.platformIdsByReminder[reminder.id];
      if (platformId == null) continue;
      await _scheduleLocal(
        platformId: platformId,
        reminder: reminder,
        accountId: accountId,
        babyId: babyId,
      );
    }
  }

  NotificationScheduleData _scheduleData(NotificationReminder reminder) =>
      NotificationScheduleData(
        title: reminder.title,
        body: reminder.body,
        scheduledAt: reminder.scheduledAt,
        route: reminder.route,
        type: reminder.type.name,
        timeZone: tz.local.name,
      );

  Future<void> _scheduleLocal({
    required int platformId,
    required NotificationReminder reminder,
    required String accountId,
    required String babyId,
  }) async {
    final notification = AppNotification(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      receivedAt: reminder.scheduledAt,
      data: {
        'route': reminder.route,
        'account_id': accountId,
        'reminder_type': reminder.type.name,
        if (babyId.isNotEmpty) 'baby_id': babyId,
      },
    );
    final exactAvailable = await _canScheduleExactNotifications();
    final requiresExact = reminder.type.requiresExactDelivery;
    try {
      await _localNotifications.zonedSchedule(
        id: platformId,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.scheduledAt, tz.local),
        notificationDetails: reminder.type.notificationDetails,
        androidScheduleMode: requiresExact && exactAvailable == true
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: jsonEncode(notification.toJson()),
      );
      _lastReminderError = null;
    } on Object catch (error) {
      _lastReminderError = error.toString();
      rethrow;
    }
  }

  Future<bool?> _canScheduleExactNotifications() async {
    final override = _canScheduleExactNotificationsOverride;
    if (override != null) return override();
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      return await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.canScheduleExactNotifications();
    } on Object {
      return null;
    }
  }

  @override
  Future<void> reconcileReminders() async {
    if (kIsWeb) return;
    await _configureLocalTimeZone();
    final accountId = _auth.currentUser?.uid;
    if (accountId == null || !(await permissionState()).canDeliver) return;
    try {
      await _scheduleStore.pruneExpired(
        accountId: accountId,
        now: DateTime.now().toUtc(),
      );
      final stored = await _scheduleStore.listForAccount(accountId);
      final pending = await _localNotifications.pendingNotificationRequests();
      final pendingIds = pending.map((request) => request.id).toSet();
      for (final record in stored) {
        if (pendingIds.contains(record.platformId) ||
            !record.scheduledAt.isAfter(DateTime.now())) {
          continue;
        }
        await _scheduleLocal(
          platformId: record.platformId,
          reminder: NotificationReminder(
            id: record.reminderId,
            title: record.title,
            body: record.body,
            scheduledAt: record.scheduledAt,
            route: record.route,
            type: NotificationReminderType.values.firstWhere(
              (type) => type.name == record.type,
              orElse: () => NotificationReminderType.custom,
            ),
          ),
          accountId: accountId,
          babyId: record.babyId,
        );
      }
    } on Object catch (error, stackTrace) {
      _lastReminderError = error.toString();
      debugPrint('No se pudieron reconciliar los recordatorios: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<NotificationDiagnostics> diagnostics() async {
    final accountId = _auth.currentUser?.uid;
    final pending = kIsWeb
        ? const <PendingNotificationRequest>[]
        : await _localNotifications.pendingNotificationRequests();
    final stored = accountId == null
        ? const <StoredNotificationSchedule>[]
        : await _scheduleStore.listForAccount(accountId);
    return NotificationDiagnostics(
      permission: await permissionState(),
      timeZone: tz.local.name,
      pendingNativeCount: pending.length,
      hasRegisteredFcmToken: _registeredToken?.isNotEmpty == true,
      canScheduleExactAlarms: await _canScheduleExactNotifications(),
      lastError: _lastReminderError,
      reminders: [
        for (final record in stored)
          NotificationDiagnosticReminder(
            id: record.reminderId,
            platformId: record.platformId,
            title: record.title,
            scheduledAt: record.scheduledAt,
            type: NotificationReminderType.values.firstWhere(
              (type) => type.name == record.type,
              orElse: () => NotificationReminderType.custom,
            ),
            channelId: NotificationReminderType.values
                .firstWhere(
                  (type) => type.name == record.type,
                  orElse: () => NotificationReminderType.custom,
                )
                .channelId,
            payload: <String, Object?>{
              'reminder_id': record.reminderId,
              'route': record.route,
              'type': record.type,
              if (record.babyId.isNotEmpty) 'baby_id': record.babyId,
            },
          ),
      ],
    );
  }

  @override
  Future<void> scheduleTestReminder() => scheduleReminder(
    id: 'debug:test:${DateTime.now().millisecondsSinceEpoch}',
    title: 'Prueba de notificación',
    body: 'Si ves este aviso, el programador local está funcionando.',
    scheduledAt: DateTime.now().add(const Duration(seconds: 10)),
  );

  @override
  Future<void> cancelAllScheduledReminders() async {
    final accountId = _auth.currentUser?.uid;
    if (accountId != null) await cancelRemindersForAccount(accountId);
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
  Future<void> snoozeReminder(
    NotificationReminder reminder, {
    Duration delay = const Duration(minutes: 10),
  }) => scheduleReminder(
    id: 'snooze:${reminder.id}:${DateTime.now().millisecondsSinceEpoch}',
    title: reminder.title,
    body: reminder.body,
    scheduledAt: DateTime.now().add(delay),
    route: reminder.route,
    type: reminder.type,
  );

  @override
  Future<void> cancelRemindersForAccount(String accountId) async {
    if (accountId.isEmpty) return;
    final platformIds = await _scheduleStore.removeAccount(accountId);
    for (final platformId in platformIds) {
      await _localNotifications.cancel(id: platformId);
    }
  }

  @override
  Future<void> retainReminderOwners({
    required String accountId,
    required String babyId,
    required Set<String> ownerIds,
  }) async {
    if (accountId.isEmpty || _auth.currentUser?.uid != accountId) return;
    final platformIds = await _scheduleStore.removeOwnersExcept(
      accountId: accountId,
      babyId: babyId,
      retainedOwnerIds: ownerIds,
    );
    if (platformIds.length >= _bulkCancellationThreshold) {
      await _localNotifications.cancelAllPendingNotifications();
      // Reconciliation computes the desired owner set before calling this
      // method and recreates it immediately afterwards. Clearing the retained
      // snapshot here prevents hundreds of obsolete owners from being read and
      // rewritten once per reminder during that migration.
      await _scheduleStore.removeAccount(accountId);
      return;
    }
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

  Future<void> _handleLocalNotificationResponse(
    NotificationResponse response,
  ) async {
    if (response.actionId != _snoozeActionId) {
      await _handleLocalNotificationTap(response.payload);
      return;
    }
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final raw = jsonDecode(payload);
      if (raw is! Map) return;
      final notification = AppNotification.fromJson(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
      final typeName = notification.data['reminder_type']?.toString();
      await snoozeReminder(
        NotificationReminder(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          scheduledAt: notification.receivedAt,
          route: notification.route ?? '/agenda',
          type: NotificationReminderType.values.firstWhere(
            (type) => type.name == typeName,
            orElse: () => NotificationReminderType.custom,
          ),
        ),
      );
    } on Object catch (error) {
      _lastReminderError = error.toString();
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

extension on NotificationReminderType {
  String get channelId => switch (this) {
    NotificationReminderType.medication => 'medication_high',
    NotificationReminderType.healthControl ||
    NotificationReminderType.vaccine ||
    NotificationReminderType.custom => 'health_reminders',
    NotificationReminderType.feeding => 'feeding_reminders',
    NotificationReminderType.diaper => 'care_reminders',
    NotificationReminderType.syncFailure => 'system_alerts',
  };

  bool get requiresExactDelivery => switch (this) {
    NotificationReminderType.medication ||
    NotificationReminderType.healthControl ||
    NotificationReminderType.vaccine ||
    NotificationReminderType.custom ||
    NotificationReminderType.feeding ||
    NotificationReminderType.diaper => true,
    NotificationReminderType.syncFailure => false,
  };

  NotificationDetails get notificationDetails => switch (this) {
    NotificationReminderType.medication => const NotificationDetails(
      android: AndroidNotificationDetails(
        'medication_high',
        'Medicamentos',
        channelDescription:
            'Recordatorios importantes de dosis de medicamentos.',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        ticker: 'Medicamento de BebéApp',
        actions: _androidReminderActions,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        categoryIdentifier: _reminderCategoryId,
      ),
    ),
    NotificationReminderType.healthControl ||
    NotificationReminderType.vaccine ||
    NotificationReminderType.custom => const NotificationDetails(
      android: AndroidNotificationDetails(
        'health_reminders',
        'Salud y controles',
        channelDescription:
            'Recordatorios de controles, vacunas y atención de salud.',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        ticker: 'Recordatorio de BebéApp',
        actions: _androidReminderActions,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        categoryIdentifier: _reminderCategoryId,
      ),
    ),
    NotificationReminderType.feeding => const NotificationDetails(
      android: AndroidNotificationDetails(
        'feeding_reminders',
        'Alimentación',
        channelDescription: 'Recordatorios opcionales de alimentación.',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        ticker: 'Recordatorio de alimentación',
        actions: _androidReminderActions,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
        categoryIdentifier: _reminderCategoryId,
      ),
    ),
    NotificationReminderType.diaper => const NotificationDetails(
      android: AndroidNotificationDetails(
        'care_reminders',
        'Cuidados diarios',
        channelDescription:
            'Recordatorios configurados de pañal y cuidados cotidianos.',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        ticker: 'Recordatorio de pañal',
        actions: _androidReminderActions,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
        categoryIdentifier: _reminderCategoryId,
      ),
    ),
    NotificationReminderType.syncFailure => const NotificationDetails(
      android: AndroidNotificationDetails(
        'system_alerts',
        'Alertas del sistema',
        channelDescription: 'Alertas persistentes que requieren atención.',
        category: AndroidNotificationCategory.status,
        ticker: 'Alerta de BebéApp',
        actions: _androidReminderActions,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
        categoryIdentifier: _reminderCategoryId,
      ),
    ),
  };
}
