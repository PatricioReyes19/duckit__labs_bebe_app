import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const configuration = SupabaseConfiguration(
    url: 'https://project.supabase.co',
    publishableKey: 'sb_publishable_test',
  );

  test('adds publishable key and Firebase JWT to Data API requests', () async {
    final adapter = _RecordingAdapter((_, _) => _jsonResponse(200, const []));
    final dio = Dio(BaseOptions(baseUrl: configuration.url))
      ..httpClientAdapter = adapter;
    final provider = _TokenProvider('firebase-token');
    final client = SupabaseRestClient(configuration, provider, dio: dio);

    await client.select('register_events');

    expect(adapter.requests, hasLength(1));
    expect(
      adapter.requests.single.headers['apikey'],
      configuration.publishableKey,
    );
    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer firebase-token',
    );
    expect(provider.forceRefreshCalls, 0);
  });

  test('refreshes once and retries a request rejected with 401', () async {
    final adapter = _RecordingAdapter(
      (_, call) => call == 1
          ? _jsonResponse(401, const {'message': 'expired'})
          : _jsonResponse(200, const <Object?>[]),
    );
    final dio = Dio(BaseOptions(baseUrl: configuration.url))
      ..httpClientAdapter = adapter;
    final provider = _TokenProvider('stale', refreshedToken: 'fresh');
    final client = SupabaseRestClient(configuration, provider, dio: dio);

    await client.select('agenda_events');

    expect(adapter.requests, hasLength(2));
    expect(provider.forceRefreshCalls, 1);
    expect(adapter.requests.last.headers['Authorization'], 'Bearer fresh');
  });

  test('maps register entities to remote JSON and back', () {
    final now = DateTime.utc(2026, 8, 10, 12);
    final entity = RegisteredEvent(
      id: 'event-1',
      babyId: 'baby-1',
      type: RegisterEventType.feeding,
      occurredAt: now,
      createdAt: now,
      details: const {'amount_ml': 90},
      syncStatus: RegisterSyncStatus.pending,
    );

    final json = RegisterEventModel.fromEntity(entity).toRemoteJson();
    final restored = RegisterEventModel.fromRemoteJson(
      Map<String, dynamic>.from(json),
    ).toEntity();

    expect(restored.id, entity.id);
    expect(restored.babyId, entity.babyId);
    expect(restored.type, entity.type);
    expect(restored.details, entity.details);
    expect(restored.syncStatus, RegisterSyncStatus.synced);
  });

  test('active sleep keeps its recoverable remote contract', () {
    final startedAt = DateTime.utc(2026, 8, 16, 8);
    final entity = RegisteredEvent(
      id: 'sleep-active',
      babyId: 'baby-1',
      type: RegisterEventType.sleep,
      occurredAt: startedAt,
      createdAt: startedAt,
      updatedAt: startedAt,
      details: const {
        'sleep_status': 'ongoing',
        'duration_minutes': null,
        'end_at': null,
      },
      syncStatus: RegisterSyncStatus.pending,
    );

    final json = RegisterEventModel.fromEntity(entity).toRemoteJson();
    final details = Map<String, Object?>.from(json['details']! as Map);
    final restored = RegisterEventModel.fromRemoteJson(
      Map<String, dynamic>.from(json),
    ).toEntity();

    expect(details['sleep_status'], 'ongoing');
    expect(details['duration_minutes'], isNull);
    expect(details['end_at'], isNull);
    expect(restored.isActive, isTrue);
    expect(restored.id, 'sleep-active');
  });

  test(
    'uses POST representation for inserts and PATCH filters for updates',
    () async {
      final adapter = _RecordingAdapter((options, _) {
        if (options.method == 'POST') {
          return _jsonResponse(201, const [
            {'id': 'row-1'},
          ]);
        }
        return _jsonResponse(200, const [
          {'id': 'row-1', 'read_at': '2026-08-11T10:00:00.000Z'},
        ]);
      });
      final dio = Dio(BaseOptions(baseUrl: configuration.url))
        ..httpClientAdapter = adapter;
      final client = SupabaseRestClient(
        configuration,
        _TokenProvider('firebase-token'),
        dio: dio,
      );

      final inserted = await client.insert(
        'example_rows',
        data: const {'id': 'row-1'},
      );
      final patched = await client.patch(
        'example_rows',
        data: const {'read_at': '2026-08-11T10:00:00.000Z'},
        filters: const {'id': 'eq.row-1'},
      );

      expect(inserted.single['id'], 'row-1');
      expect(patched.single['read_at'], isNotNull);
      expect(adapter.requests[0].method, 'POST');
      expect(adapter.requests[0].path, '/rest/v1/example_rows');
      expect(adapter.requests[1].method, 'PATCH');
      expect(adapter.requests[1].queryParameters['id'], 'eq.row-1');
    },
  );

  test(
    'notification datasource loads unread rows and marks one read',
    () async {
      final adapter = _RecordingAdapter((options, _) {
        if (options.method == 'GET') {
          return _jsonResponse(200, const [
            {
              'id': 'notification-1',
              'title': 'Agenda actualizada',
              'body': 'Hay un nuevo evento.',
              'route': '/agenda',
              'payload': {'baby_id': 'baby-1'},
              'created_at': '2026-08-11T10:00:00.000Z',
              'read_at': null,
            },
          ]);
        }
        return _jsonResponse(200, const <Object?>[]);
      });
      final dio = Dio(BaseOptions(baseUrl: configuration.url))
        ..httpClientAdapter = adapter;
      final client = SupabaseRestClient(
        configuration,
        _TokenProvider('firebase-token'),
        dio: dio,
      );
      final datasource = SupabaseActivityNotificationRemoteDataSource(client);

      final unread = await datasource.listUnread();
      await datasource.markRead(unread.single.id);

      expect(unread.single.route, '/agenda');
      expect(unread.single.payload['baby_id'], 'baby-1');
      expect(adapter.requests[0].queryParameters['read_at'], 'is.null');
      expect(adapter.requests[1].method, 'PATCH');
      expect(adapter.requests[1].queryParameters['id'], 'eq.notification-1');
    },
  );

  test(
    'syncs the authenticated profile used to resolve pending invites',
    () async {
      final adapter = _RecordingAdapter(
        (_, _) => _jsonResponse(200, const {'id': 'user-invited'}),
      );
      final dio = Dio(BaseOptions(baseUrl: configuration.url))
        ..httpClientAdapter = adapter;
      final datasource = SupabaseProfileRemoteDataSource(
        SupabaseRestClient(
          configuration,
          _TokenProvider('invitee-token'),
          dio: dio,
        ),
      );

      await datasource.syncAuthenticatedUser(
        const AuthUser(
          id: 'user-invited',
          email: 'abuela@example.com',
          displayName: 'Ana Pérez',
          emailVerification: true,
        ),
      );

      expect(
        adapter.requests.single.path,
        '/rest/v1/rpc/upsert_current_profile',
      );
      expect(adapter.requests.single.data, const {
        'p_display_name': 'Ana Pérez',
        'p_email': 'abuela@example.com',
      });
    },
  );

  test(
    'covers inviter creation, invitee lookup/acceptance and both alerts',
    () async {
      final adapter = _RecordingAdapter((options, _) {
        if (options.path.endsWith('/create_care_invitation')) {
          return _jsonResponse(200, const {
            'id': 'invitation-1',
            'code': 'FAMILY42',
          });
        }
        if (options.path.endsWith('/lookup_care_invitation')) {
          return _jsonResponse(200, const {
            'found': true,
            'id': 'invitation-1',
            'family_id': 'family-1',
            'baby_id': 'baby-1',
            'baby_name': 'Mateo',
            'baby_birth_date': '2026-01-10',
          });
        }
        if (options.path.endsWith('/accept_care_invitation')) {
          return _jsonResponse(200, const {
            'id': 'invitation-1',
            'status': 'accepted',
          });
        }
        if (options.path == '/rest/v1/activity_notifications') {
          return _jsonResponse(200, const [
            {
              'id': 'alert-invitee',
              'title': 'Invitación a un círculo de cuidado',
              'body': 'María te invitó a cuidar a Mateo',
              'route': '/invitation?code=FAMILY42',
              'payload': {'invitation_code': 'FAMILY42'},
              'created_at': '2026-08-11T10:00:00.000Z',
              'read_at': null,
            },
            {
              'id': 'alert-owner',
              'title': 'Invitación aceptada',
              'body': 'Ana se unió al círculo de Mateo',
              'route': '/family/care-circle',
              'payload': {'status': 'accepted'},
              'created_at': '2026-08-11T10:01:00.000Z',
              'read_at': null,
            },
          ]);
        }
        return _jsonResponse(404, const {'message': 'unexpected request'});
      });
      final provider = _TokenProvider('owner-token');
      final dio = Dio(BaseOptions(baseUrl: configuration.url))
        ..httpClientAdapter = adapter;
      final client = SupabaseRestClient(configuration, provider, dio: dio);
      final family = SupabaseFamilyRemoteDataSource(client);

      await family.createInvitation(const {
        'p_baby_id': 'baby-1',
        'p_baby_name': 'Mateo',
        'p_invitee_name': 'Ana Pérez',
        'p_contact': 'ana-perez@example.com',
        'p_relationship': 'Abuela',
        'p_access_description': 'ver historial, registrar',
        'p_can_write': true,
        'p_code': 'FAMILY42',
      });
      provider.token = 'invitee-token';
      final lookup = await client.rpc(
        'lookup_care_invitation',
        parameters: const {'p_code': 'FAMILY42'},
      );
      final accepted = await client.rpc(
        'accept_care_invitation',
        parameters: const {'p_code': 'FAMILY42'},
      );
      final alerts = await SupabaseActivityNotificationRemoteDataSource(
        client,
      ).listUnread();

      expect((lookup as Map)['family_id'], 'family-1');
      expect((accepted as Map)['status'], 'accepted');
      expect(
        alerts.map((item) => item.route),
        containsAll(['/invitation?code=FAMILY42', '/family/care-circle']),
      );
      expect(
        adapter.requests.first.headers['Authorization'],
        'Bearer owner-token',
      );
      expect(
        (adapter.requests.first.data as Map)['p_contact'],
        'ana-perez@example.com',
      );
      expect(
        adapter.requests
            .skip(1)
            .every(
              (request) =>
                  request.headers['Authorization'] == 'Bearer invitee-token',
            ),
        isTrue,
      );
    },
  );
}

class _TokenProvider implements AccessTokenProvider {
  _TokenProvider(this.token, {this.refreshedToken});

  String token;
  final String? refreshedToken;
  int forceRefreshCalls = 0;

  @override
  Future<String?> getToken({bool forceRefresh = false}) async {
    if (!forceRefresh) return token;
    forceRefreshCalls += 1;
    return refreshedToken ?? token;
  }
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._response);

  final ResponseBody Function(RequestOptions options, int call) _response;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      options.copyWith(headers: Map<String, dynamic>.from(options.headers)),
    );
    return _response(options, requests.length);
  }

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
