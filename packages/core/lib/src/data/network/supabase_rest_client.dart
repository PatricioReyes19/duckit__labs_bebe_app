import 'dart:io';

import 'package:dio/dio.dart';

import '../sync/supabase_configuration.dart';
import 'access_token_provider.dart';
import 'supabase_auth_interceptor.dart';
import 'supabase_remote_exception.dart';

/// Small, vendor-focused HTTP adapter for Supabase Data API and Storage.
///
/// Data sources depend on this adapter instead of Dio directly so transport,
/// authentication and error mapping have a single responsibility.
class SupabaseRestClient {
  SupabaseRestClient(this.configuration, this.tokenProvider, {Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: configuration.normalizedUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 30),
              responseType: ResponseType.json,
              headers: const {'Accept': 'application/json'},
            ),
          ) {
    this.dio.interceptors.add(
      SupabaseAuthInterceptor(
        dio: this.dio,
        configuration: configuration,
        tokenProvider: tokenProvider,
      ),
    );
  }

  final SupabaseConfiguration configuration;
  final AccessTokenProvider tokenProvider;
  final Dio dio;

  bool get isConfigured => configuration.isConfigured;

  Future<bool> isAuthenticated() async {
    if (!isConfigured) return false;
    final token = await tokenProvider.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Object?> rpc(
    String function, {
    Map<String, Object?> parameters = const {},
  }) => _guard(
    () async => (await dio.post<Object?>(
      '/rest/v1/rpc/$function',
      data: parameters,
      options: Options(headers: const {'Prefer': 'return=representation'}),
    )).data,
  );

  Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
    Map<String, String> filters = const {},
    String? order,
    int? limit,
  }) => _guard(() async {
    final response = await dio.get<Object?>(
      '/rest/v1/$table',
      queryParameters: <String, Object?>{
        'select': columns,
        ...filters,
        'order': ?order,
        'limit': ?limit,
      },
    );
    return _collection(response.data);
  });

  Future<List<Map<String, dynamic>>> insert(
    String table, {
    required Object data,
    String? onConflict,
  }) => _guard(() async {
    final response = await dio.post<Object?>(
      '/rest/v1/$table',
      data: data,
      queryParameters: {'on_conflict': ?onConflict},
      options: Options(
        headers: {
          'Prefer': onConflict == null
              ? 'return=representation'
              : 'resolution=merge-duplicates,return=representation',
        },
      ),
    );
    return _collection(response.data);
  });

  Future<List<Map<String, dynamic>>> patch(
    String table, {
    required Map<String, Object?> data,
    required Map<String, String> filters,
  }) => _guard(() async {
    final response = await dio.patch<Object?>(
      '/rest/v1/$table',
      data: data,
      queryParameters: filters,
      options: Options(headers: const {'Prefer': 'return=representation'}),
    );
    return _collection(response.data);
  });

  Future<void> delete(String table, {required Map<String, String> filters}) =>
      _guard(() async {
        await dio.delete<void>(
          '/rest/v1/$table',
          queryParameters: filters,
          options: Options(headers: const {'Prefer': 'return=minimal'}),
        );
      });

  Future<void> uploadObject({
    required String bucket,
    required String path,
    required File file,
    String contentType = 'application/octet-stream',
    bool upsert = true,
  }) => _guard(() async {
    final encodedPath = path
        .replaceAll('\\', '/')
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');
    await dio.post<void>(
      '/storage/v1/object/${Uri.encodeComponent(bucket)}/$encodedPath',
      data: await file.readAsBytes(),
      options: Options(
        contentType: contentType,
        headers: {'x-upsert': '$upsert'},
      ),
    );
  });

  Future<void> removeObjects({
    required String bucket,
    required List<String> paths,
  }) => _guard(() async {
    if (paths.isEmpty) return;
    await dio.delete<void>(
      '/storage/v1/object/${Uri.encodeComponent(bucket)}',
      data: {'prefixes': paths},
    );
  });

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (error) {
      throw SupabaseRemoteException.fromDio(error);
    }
  }

  static List<Map<String, dynamic>> _collection(Object? data) {
    if (data is! List) {
      throw const FormatException('Invalid Supabase collection response.');
    }
    return data
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}
