import 'package:flutter_test/flutter_test.dart';
import 'package:notifications/notifications.dart';

void main() {
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
  });
}
