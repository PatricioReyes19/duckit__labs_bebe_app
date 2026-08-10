import 'package:dio/dio.dart';

import '../sync/supabase_configuration.dart';
import 'access_token_provider.dart';

class SupabaseAuthInterceptor extends Interceptor {
  SupabaseAuthInterceptor({
    required Dio dio,
    required SupabaseConfiguration configuration,
    required AccessTokenProvider tokenProvider,
  }) : _dio = dio,
       _configuration = configuration,
       _tokenProvider = tokenProvider;

  static const _retriedKey = 'supabase.auth.retried';

  final Dio _dio;
  final SupabaseConfiguration _configuration;
  final AccessTokenProvider _tokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[_retriedKey] == true &&
        options.headers['Authorization'] != null) {
      handler.next(options);
      return;
    }
    if (!_configuration.isConfigured) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: StateError('Supabase is not configured.'),
        ),
      );
      return;
    }

    final token = await _tokenProvider.getToken();
    if (token == null || token.isEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response<void>(requestOptions: options, statusCode: 401),
          type: DioExceptionType.badResponse,
          error: StateError('An authenticated session is required.'),
        ),
      );
      return;
    }

    options.headers
      ..['apikey'] = _configuration.publishableKey
      ..['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        options.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    try {
      final refreshedToken = await _tokenProvider.getToken(forceRefresh: true);
      if (refreshedToken == null || refreshedToken.isEmpty) {
        handler.next(err);
        return;
      }
      options.extra[_retriedKey] = true;
      options.headers
        ..['apikey'] = _configuration.publishableKey
        ..['Authorization'] = 'Bearer $refreshedToken';
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    } on Object {
      handler.next(err);
    }
  }
}
