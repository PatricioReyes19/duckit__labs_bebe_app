import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications/notifications.dart';
import 'package:notifications/src/notification_inbox_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:timezone/timezone.dart' as tz;

const _permissionChannel = MethodChannel(
  'com.duckitlabs.bebeapp/notification_permission',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String permissionStatus;
  late String timeZone;

  setUpAll(() {
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(tz.TZDateTime.utc(2026));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    permissionStatus = 'granted';
    timeZone = 'UTC';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, (call) async {
          if (call.method == 'status') return permissionStatus;
          if (call.method == 'timezone') return timeZone;
          if (call.method == 'openSettings') return true;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, null);
  });

  test('UT-NOTIF-001 permission unknown', () async {
    final messaging = _MockFirebaseMessaging();
    when(messaging.getNotificationSettings).thenThrow(StateError('unknown'));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _permissionChannel,
          (_) => throw PlatformException(code: 'unavailable'),
        );
    final service = FirebaseNotificationService(
      messaging: messaging,
      auth: _MockFirebaseAuth(),
      localNotifications: _MockLocalNotifications(),
    );

    expect(
      await service.permissionState(),
      NotificationPermissionState.unknown,
    );
  });

  test('UT-NOTIF-002 permission granted', () async {
    final service = _permissionOnlyService();
    expect(
      await service.permissionState(),
      NotificationPermissionState.granted,
    );
  });

  test('UT-NOTIF-003 permission denied', () async {
    permissionStatus = 'denied';
    final service = _permissionOnlyService();
    expect(await service.permissionState(), NotificationPermissionState.denied);
  });

  test('UT-NOTIF-004 permission permanently denied', () async {
    permissionStatus = 'permanentlyDenied';
    final service = _permissionOnlyService();
    expect(
      await service.permissionState(),
      NotificationPermissionState.permanentlyDenied,
    );
  });

  test('UT-NOTIF-005 schedule creates a stable platform identifier', () async {
    final fixture = _serviceFixture();
    final firstAt = DateTime.now().add(const Duration(hours: 2));
    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:event-1',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [
        NotificationReminder(
          id: 'agenda:event-1',
          title: 'Recordatorio de Agenda',
          body: 'Tienes un recordatorio programado.',
          scheduledAt: firstAt,
          route: '/agenda/events/event-1',
        ),
      ],
    );
    final firstId =
        verify(
              () => fixture.local.zonedSchedule(
                id: captureAny(named: 'id'),
                title: any(named: 'title'),
                body: any(named: 'body'),
                scheduledDate: any(named: 'scheduledDate'),
                notificationDetails: any(named: 'notificationDetails'),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                payload: any(named: 'payload'),
              ),
            ).captured.single
            as int;

    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:event-1',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [
        NotificationReminder(
          id: 'agenda:event-1',
          title: 'Recordatorio de Agenda',
          body: 'Tienes un recordatorio programado.',
          scheduledAt: firstAt.add(const Duration(hours: 1)),
          route: '/agenda/events/event-1',
        ),
      ],
    );
    final allScheduledIds = verify(
      () => fixture.local.zonedSchedule(
        id: captureAny(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: any(named: 'payload'),
      ),
    ).captured.cast<int>();
    expect(allScheduledIds, [firstId]);
  });

  test('UT-NOTIF-006 edit cancels and reschedules the same reminder', () async {
    final fixture = _serviceFixture();
    final reminder = NotificationReminder(
      id: 'agenda:event-2',
      title: 'Recordatorio de Agenda',
      body: 'Tienes un recordatorio programado.',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      route: '/agenda/events/event-2',
    );
    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:event-2',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [reminder],
    );
    final scheduledId =
        verify(
              () => fixture.local.zonedSchedule(
                id: captureAny(named: 'id'),
                title: any(named: 'title'),
                body: any(named: 'body'),
                scheduledDate: any(named: 'scheduledDate'),
                notificationDetails: any(named: 'notificationDetails'),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                payload: any(named: 'payload'),
              ),
            ).captured.single
            as int;

    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:event-2',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [
        NotificationReminder(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          scheduledAt: reminder.scheduledAt.add(const Duration(hours: 1)),
          route: reminder.route,
        ),
      ],
    );

    verify(() => fixture.local.cancel(id: scheduledId)).called(1);
    verify(
      () => fixture.local.zonedSchedule(
        id: scheduledId,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test('UT-NOTIF-007 delete cancels the scheduled reminder', () async {
    final fixture = _serviceFixture();
    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:event-3',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [
        NotificationReminder(
          id: 'agenda:event-3',
          title: 'Recordatorio de Agenda',
          body: 'Tienes un recordatorio programado.',
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          route: '/agenda/events/event-3',
        ),
      ],
    );
    final scheduledId =
        verify(
              () => fixture.local.zonedSchedule(
                id: captureAny(named: 'id'),
                title: any(named: 'title'),
                body: any(named: 'body'),
                scheduledDate: any(named: 'scheduledDate'),
                notificationDetails: any(named: 'notificationDetails'),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                payload: any(named: 'payload'),
              ),
            ).captured.single
            as int;

    await fixture.service.cancelReminders('account:user-1|agenda:event-3');

    verify(() => fixture.local.cancel(id: scheduledId)).called(1);
  });

  test('UT-NOTIF-008 reconciliation restores a missing native alarm', () async {
    final fixture = _serviceFixture();
    final scheduledAt = DateTime.now().add(const Duration(hours: 2));
    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:reconcile',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [
        NotificationReminder(
          id: 'agenda:reconcile',
          title: 'Medicamento',
          body: 'Vitamina D · 1 gota',
          scheduledAt: scheduledAt,
          route: '/agenda/events/reconcile',
          type: NotificationReminderType.medication,
        ),
      ],
    );
    clearInteractions(fixture.local);

    await fixture.service.reconcileReminders();

    verify(
      () => fixture.local.zonedSchedule(
        id: any(named: 'id'),
        title: 'Medicamento',
        body: 'Vitamina D · 1 gota',
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test('UT-NOTIF-009 exact alarm denial falls back without losing it', () async {
    final fixture = _serviceFixture(exactAlarmsAvailable: false);
    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:exact-denied',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [
        NotificationReminder(
          id: 'agenda:exact-denied',
          title: 'Medicamento',
          body: 'Vitamina D · 1 gota',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          route: '/agenda',
          type: NotificationReminderType.medication,
        ),
      ],
    );

    verify(
      () => fixture.local.zonedSchedule(
        id: any(named: 'id'),
        title: 'Medicamento',
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test('UT-NOTIF-010 schedules in the device IANA timezone', () async {
    timeZone = 'America/Santiago';
    final fixture = _serviceFixture();
    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:timezone',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [
        NotificationReminder(
          id: 'agenda:timezone',
          title: 'Control',
          body: 'Control pediátrico',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          route: '/agenda',
          type: NotificationReminderType.healthControl,
        ),
      ],
    );

    expect((await fixture.service.diagnostics()).timeZone, 'America/Santiago');
  });

  test('UT-NOTIF-011 snooze schedules a new occurrence', () async {
    final fixture = _serviceFixture();
    final before = DateTime.now();
    await fixture.service.snoozeReminder(
      NotificationReminder(
        id: 'medication-original',
        title: 'Medicamento',
        body: 'Vitamina D · 1 gota',
        scheduledAt: before,
        route: '/agenda',
        type: NotificationReminderType.medication,
      ),
    );

    final scheduledAt =
        verify(
              () => fixture.local.zonedSchedule(
                id: any(named: 'id'),
                title: 'Medicamento',
                body: any(named: 'body'),
                scheduledDate: captureAny(named: 'scheduledDate'),
                notificationDetails: any(named: 'notificationDetails'),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                payload: any(named: 'payload'),
              ),
            ).captured.single
            as tz.TZDateTime;
    expect(
      scheduledAt.toUtc().isAfter(
        before.add(const Duration(minutes: 9)).toUtc(),
      ),
      isTrue,
    );
  });

  test('IT-NOTIF-001 granted schedules a reminder', () async {
    final fixture = _serviceFixture();
    await fixture.service.replaceReminders(
      ownerId: 'account:user-1|agenda:granted',
      accountId: 'user-1',
      babyId: 'baby-1',
      reminders: [
        NotificationReminder(
          id: 'agenda:granted',
          title: 'Recordatorio de Agenda',
          body: 'Tienes un recordatorio programado.',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          route: '/agenda',
        ),
      ],
    );
    verify(
      () => fixture.local.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test(
    'IT-NOTIF-002 denied keeps the app working without scheduling',
    () async {
      permissionStatus = 'denied';
      final fixture = _serviceFixture();
      await expectLater(
        fixture.service.replaceReminders(
          ownerId: 'account:user-1|agenda:denied',
          accountId: 'user-1',
          babyId: 'baby-1',
          reminders: [
            NotificationReminder(
              id: 'agenda:denied',
              title: 'Recordatorio de Agenda',
              body: 'Tienes un recordatorio programado.',
              scheduledAt: DateTime.now().add(const Duration(hours: 1)),
              route: '/agenda',
            ),
          ],
        ),
        completes,
      );
      verifyNever(
        () => fixture.local.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          payload: any(named: 'payload'),
        ),
      );
    },
  );

  testWidgets('IT-NOTIF-003 permanently denied exposes settings CTA', (
    tester,
  ) async {
    final service = _MockNotificationService();
    when(() => service.currentNotifications).thenReturn(const []);
    when(
      () => service.notifications,
    ).thenAnswer((_) => const Stream<List<AppNotification>>.empty());
    when(service.refreshInbox).thenAnswer((_) async {});
    when(
      service.permissionState,
    ).thenAnswer((_) async => NotificationPermissionState.permanentlyDenied);
    when(service.openNotificationSettings).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(notificationService: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Abrir configuración'), findsOneWidget);
    await tester.tap(find.text('Abrir configuración'));
    await tester.pump();
    verify(service.openNotificationSettings).called(1);
    verifyNever(service.requestPermission);
  });
}

FirebaseNotificationService _permissionOnlyService() =>
    FirebaseNotificationService(
      messaging: _MockFirebaseMessaging(),
      auth: _MockFirebaseAuth(),
      localNotifications: _MockLocalNotifications(),
    );

_ServiceFixture _serviceFixture({bool? exactAlarmsAvailable}) {
  final messaging = _MockFirebaseMessaging();
  final auth = _MockFirebaseAuth();
  final user = _MockUser();
  final local = _MockLocalNotifications();
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
  when(() => auth.userChanges()).thenAnswer((_) => const Stream<User?>.empty());
  when(
    () => local.initialize(
      settings: any(named: 'settings'),
      onDidReceiveNotificationResponse: any(
        named: 'onDidReceiveNotificationResponse',
      ),
    ),
  ).thenAnswer((_) async => true);
  when(local.getNotificationAppLaunchDetails).thenAnswer((_) async => null);
  when(local.pendingNotificationRequests).thenAnswer((_) async => const []);
  when(
    () => local.zonedSchedule(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      scheduledDate: any(named: 'scheduledDate'),
      notificationDetails: any(named: 'notificationDetails'),
      androidScheduleMode: any(named: 'androidScheduleMode'),
      payload: any(named: 'payload'),
    ),
  ).thenAnswer((_) async {});
  when(() => local.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
  return _ServiceFixture(
    FirebaseNotificationService(
      messaging: messaging,
      auth: auth,
      localNotifications: local,
      inboxStore: NotificationInboxStore(preferences: SharedPreferencesAsync()),
      scheduleStore: NotificationScheduleStore(
        preferences: SharedPreferencesAsync(),
      ),
      canScheduleExactNotifications: exactAlarmsAvailable == null
          ? null
          : () async => exactAlarmsAvailable,
    ),
    local,
  );
}

class _ServiceFixture {
  const _ServiceFixture(this.service, this.local);

  final FirebaseNotificationService service;
  final _MockLocalNotifications local;
}

class _MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockLocalNotifications extends Mock
    implements FlutterLocalNotificationsPlugin {}

class _MockNotificationService extends Mock implements NotificationService {}
