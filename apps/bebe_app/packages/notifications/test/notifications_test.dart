import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications/notifications.dart';
import 'package:notifications/src/notification_inbox_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
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
      final service = FirebaseNotificationService(
        messaging: _MockFirebaseMessaging(),
        auth: _MockFirebaseAuth(),
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
}

class _MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockLocalNotifications extends Mock
    implements FlutterLocalNotificationsPlugin {}
