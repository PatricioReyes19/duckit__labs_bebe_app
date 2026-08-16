import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications/notifications.dart';
import 'package:notifications/src/notification_inbox_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  late BebeTheme bebeTheme;
  const permissionChannel =
      MethodChannel('com.duckitlabs.bebeapp/notification_permission');

  setUpAll(() {
    final candidates = [
      File('assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
      File('../design_system/assets/json/bebe_theme.json'),
    ];
    final file = candidates.firstWhere((candidate) => candidate.existsSync());
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    bebeTheme = BebeTheme.fromJson(json);
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(tz.TZDateTime.utc(2026));
    registerFallbackValue(const NotificationDetails());
  });

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
      if (call.method == 'status') return 'granted';
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('AppNotification', () {
    const receivedAt = '2026-08-10T12:30:00.000Z';

    test('round-trips through JSON', () {
      final notification = AppNotification(
        id: 'message-1',
        title: 'Recordatorio',
        body: 'Hora del medicamento',
        receivedAt: DateTime.parse(receivedAt),
        data: const {'route': '/health'},
      );

      final restored = AppNotification.fromJson(notification.toJson());

      expect(restored.id, notification.id);
      expect(restored.title, notification.title);
      expect(restored.body, notification.body);
      expect(restored.receivedAt, notification.receivedAt);
      expect(restored.data, notification.data);
    });

    test('accepts only internal application routes', () {
      final allowed = AppNotification(
        id: 'allowed',
        title: 'Allowed',
        body: 'Allowed',
        receivedAt: DateTime.parse(receivedAt),
        data: const {'route': '/family/settings'},
      );
      final rejected = AppNotification(
        id: 'rejected',
        title: 'Rejected',
        body: 'Rejected',
        receivedAt: DateTime.parse(receivedAt),
        data: const {'route': 'https://example.com'},
      );

      expect(allowed.route, '/family/settings');
      expect(rejected.route, isNull);
    });

    test('allows invitation deep links with their code', () {
      final invitation = AppNotification(
        id: 'invitation',
        title: 'Invitación recibida',
        body: 'Únete al círculo de Mateo',
        receivedAt: DateTime.parse(receivedAt),
        data: const {'route': '/invitation?code=MATEO2026'},
      );

      expect(invitation.route, '/invitation?code=MATEO2026');
    });
  });

  test(
    'remote event from another caregiver reaches the in-app inbox once',
    () async {
      var remoteWasOpened = false;
      final markedRead = <String>[];
      AppNotification remoteNotification() => AppNotification(
        id: 'notification-user-a-feeding-1',
        title: 'Nueva alimentación registrada',
        body: 'Otro cuidador registró una toma de 90 ml.',
        receivedAt: DateTime.utc(2026, 8, 12, 12),
        data: const {
          'route': '/home/history',
          'actor_id': 'user-b',
          'event_type': 'feeding',
        },
        wasOpened: remoteWasOpened,
      );
      final auth = _MockFirebaseAuth();
      final user = _MockUser();
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.uid).thenReturn('user-a');
      final service = FirebaseNotificationService(
        messaging: _MockFirebaseMessaging(),
        auth: auth,
        localNotifications: _MockLocalNotifications(),
        inboxStore: NotificationInboxStore(
          preferences: SharedPreferencesAsync(),
        ),
        loadRemoteNotifications: () async => [remoteNotification()],
        markRemoteNotificationRead: (id) async {
          markedRead.add(id);
          remoteWasOpened = true;
        },
      );
      final nextInbox = service.notifications.first;

      await service.refreshInbox();

      expect((await nextInbox).single.id, 'notification-user-a-feeding-1');
      expect(service.currentNotifications, hasLength(1));
      expect(service.currentNotifications.single.route, '/home/history');
      expect(service.currentNotifications.single.data['actor_id'], 'user-b');

      await service.markOpened(service.currentNotifications.single);
      await service.refreshInbox();

      expect(markedRead, ['notification-user-a-feeding-1']);
      expect(service.currentNotifications, hasLength(1));
      expect(service.currentNotifications.single.wasOpened, isTrue);
    },
  );

  testWidgets('notification button exposes an unread dot', (tester) async {
    final service = _MockNotificationService();
    when(
      () => service.notifications,
    ).thenAnswer((_) => const Stream<List<AppNotification>>.empty());
    when(() => service.currentNotifications).thenReturn([
      AppNotification(
        id: 'unread-1',
        title: 'Registro sincronizado',
        body: 'Se recibió una toma.',
        receivedAt: DateTime.utc(2026, 8, 12, 12),
      ),
    ]);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: bebeTheme.lightTheme(),
        home: Scaffold(
          appBar: AppBar(
            actions: [
              NotificationInboxButton(
                notificationService: service,
                onPressed: () => pressed = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(BebeIndicatorDot), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(pressed, isTrue);
  });

  test('due reminders use an exact audible alarm', () async {
    final messaging = _MockFirebaseMessaging();
    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    final localNotifications = _MockLocalNotifications();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('user-1');
    when(
      () => messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      ),
    ).thenAnswer((_) async {});
    when(
      () => messaging.onTokenRefresh,
    ).thenAnswer((_) => const Stream<String>.empty());
    when(messaging.getInitialMessage).thenAnswer((_) async => null);
    when(
      () => auth.userChanges(),
    ).thenAnswer((_) => const Stream<User?>.empty());
    when(
      () => localNotifications.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async => true);
    when(
      localNotifications.getNotificationAppLaunchDetails,
    ).thenAnswer((_) async => null);
    when(
      () => localNotifications.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    final service = FirebaseNotificationService(
      messaging: messaging,
      auth: auth,
      localNotifications: localNotifications,
      inboxStore: NotificationInboxStore(preferences: SharedPreferencesAsync()),
    );

    await service.scheduleReminder(
      id: 'diaper-due',
      title: 'Cambio de pañal',
      body: 'Se cumplió el plazo del recordatorio.',
      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final details =
        verify(
              () => localNotifications.zonedSchedule(
                id: any(named: 'id'),
                title: 'Cambio de pañal',
                body: 'Se cumplió el plazo del recordatorio.',
                scheduledDate: any(named: 'scheduledDate'),
                notificationDetails: captureAny(named: 'notificationDetails'),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                payload: any(named: 'payload'),
              ),
            ).captured.single
            as NotificationDetails;
    expect(details.android?.importance, Importance.max);
    expect(details.android?.priority, Priority.max);
    expect(details.android?.category, AndroidNotificationCategory.alarm);
    expect(details.android?.audioAttributesUsage, AudioAttributesUsage.alarm);
    expect(details.iOS?.presentSound, isTrue);
    expect(details.iOS?.interruptionLevel, InterruptionLevel.timeSensitive);
  });
}

class _MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockLocalNotifications extends Mock
    implements FlutterLocalNotificationsPlugin {}

class _MockNotificationService extends Mock implements NotificationService {}
