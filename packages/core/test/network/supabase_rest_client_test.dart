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
}

class _TokenProvider implements AccessTokenProvider {
  _TokenProvider(this.token, {this.refreshedToken});

  final String token;
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
