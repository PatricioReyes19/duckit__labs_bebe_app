import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const configuration = SupabaseConfiguration(
    url: 'https://local.supabase.test',
    publishableKey: 'local-test-key',
  );

  test(
    'an event from caregiver B alerts caregiver A once and can be opened',
    () async {
      final backend = _TwoUserCareCircleBackend();
      final userA = _client(configuration, backend, token: 'token-user-a');
      final userB = _client(configuration, backend, token: 'token-user-b');
      final event = RegisteredEvent(
        id: 'feeding-1',
        babyId: 'baby-1',
        type: RegisterEventType.feeding,
        occurredAt: DateTime.utc(2026, 8, 12, 12),
        createdAt: DateTime.utc(2026, 8, 12, 12),
        updatedAt: DateTime.utc(2026, 8, 12, 12),
        caregiverId: 'user-b',
        details: const {'amount_ml': 90, 'feeding_type': 'formula'},
        syncStatus: RegisterSyncStatus.pending,
      );

      final saved = await SupabaseRegisterEventRemoteDataSource(
        userB,
      ).push(event);
      // Retry the same mutation to exercise the notification unique key.
      await SupabaseRegisterEventRemoteDataSource(userB).push(event);

      final notificationsA = SupabaseActivityNotificationRemoteDataSource(
        userA,
      );
      final notificationsB = SupabaseActivityNotificationRemoteDataSource(
        userB,
      );
      final alertsA = await notificationsA.listUnread();
      final alertsB = await notificationsB.listUnread();

      expect(saved.syncStatus, RegisterSyncStatus.synced);
      expect(alertsA, hasLength(1));
      expect(alertsA.single.title, 'Nueva alimentación registrada');
      expect(alertsA.single.body, 'Otro cuidador registró una toma de 90 ml.');
      expect(alertsA.single.route, '/home/history');
      expect(alertsA.single.payload, containsPair('actor_id', 'user-b'));
      expect(alertsA.single.payload, containsPair('event_type', 'feeding'));
      expect(
        alertsB,
        isEmpty,
        reason: 'B must not be alerted by its own event',
      );

      await notificationsA.markRead(alertsA.single.id);

      expect(await notificationsA.listUnread(), isEmpty);
      expect(
        backend.readNotifications,
        contains('notification-user-a-feeding-1'),
      );
    },
  );
}

SupabaseRestClient _client(
  SupabaseConfiguration configuration,
  HttpClientAdapter backend, {
  required String token,
}) {
  final dio = Dio(BaseOptions(baseUrl: configuration.url))
    ..httpClientAdapter = backend;
  return SupabaseRestClient(
    configuration,
    _StaticTokenProvider(token),
    dio: dio,
  );
}

class _StaticTokenProvider implements AccessTokenProvider {
  const _StaticTokenProvider(this.token);

  final String token;

  @override
  Future<String?> getToken({bool forceRefresh = false}) async => token;
}

class _TwoUserCareCircleBackend implements HttpClientAdapter {
  final Map<String, List<Map<String, Object?>>> _notifications = {
    'user-a': <Map<String, Object?>>[],
    'user-b': <Map<String, Object?>>[],
  };
  final Set<String> _uniqueNotifications = <String>{};
  final Set<String> readNotifications = <String>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final actor = _userFor(options.headers['Authorization']?.toString());
    if (options.path.endsWith('/rpc/apply_register_event')) {
      return _applyRegisterEvent(options, actor);
    }
    if (options.path == '/rest/v1/activity_notifications' &&
        options.method == 'GET') {
      final unread = _notifications[actor]!
          .where((item) => item['read_at'] == null)
          .toList(growable: false);
      return _jsonResponse(200, unread);
    }
    if (options.path == '/rest/v1/activity_notifications' &&
        options.method == 'PATCH') {
      final filter = options.queryParameters['id']?.toString() ?? '';
      final id = filter.replaceFirst('eq.', '');
      for (final item in _notifications[actor]!) {
        if (item['id'] == id) {
          item['read_at'] = (options.data as Map)['read_at'];
          readNotifications.add(id);
        }
      }
      return _jsonResponse(200, const <Object?>[]);
    }
    return _jsonResponse(404, const {'message': 'Unexpected local request'});
  }

  ResponseBody _applyRegisterEvent(RequestOptions options, String actor) {
    final payload = Map<String, Object?>.from(
      (options.data as Map)['payload'] as Map,
    );
    final eventId = payload['id']! as String;
    final updatedAt = payload['updated_at']! as String;
    final recipient = actor == 'user-a' ? 'user-b' : 'user-a';
    final uniqueKey = '$recipient-register_events-$eventId-$updatedAt';
    if (_uniqueNotifications.add(uniqueKey)) {
      final details = Map<String, Object?>.from(payload['details']! as Map);
      final amount = details['amount_ml'];
      _notifications[recipient]!.add({
        'id': 'notification-$recipient-$eventId',
        'title': 'Nueva alimentación registrada',
        'body': 'Otro cuidador registró una toma de $amount ml.',
        'route': '/home/history',
        'payload': {
          'actor_id': actor,
          'baby_id': payload['baby_id'],
          'source_table': 'register_events',
          'source_id': eventId,
          'kind': 'created',
          'event_type': payload['event_type'],
        },
        'created_at': updatedAt,
        'read_at': null,
      });
    }
    return _jsonResponse(200, {
      ...payload,
      'owner_id': actor,
      'updated_by': actor,
    });
  }

  static String _userFor(String? authorization) => switch (authorization) {
    'Bearer token-user-a' => 'user-a',
    'Bearer token-user-b' => 'user-b',
    _ => throw StateError('Unknown local identity: $authorization'),
  };

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(int statusCode, Object? body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
