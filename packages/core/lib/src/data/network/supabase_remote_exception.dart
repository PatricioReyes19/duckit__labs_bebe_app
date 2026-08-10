import 'package:dio/dio.dart';

class SupabaseRemoteException implements Exception {
  const SupabaseRemoteException({
    required this.message,
    this.statusCode,
    this.code,
    this.cause,
  });

  factory SupabaseRemoteException.fromDio(DioException exception) {
    final data = exception.response?.data;
    final body = data is Map ? data : const <Object?, Object?>{};
    return SupabaseRemoteException(
      message:
          body['message']?.toString() ??
          body['msg']?.toString() ??
          exception.message ??
          'No fue posible comunicarse con Supabase.',
      statusCode: exception.response?.statusCode,
      code: body['code']?.toString(),
      cause: exception,
    );
  }

  final String message;
  final int? statusCode;
  final String? code;
  final Object? cause;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => [
    'SupabaseRemoteException',
    if (statusCode != null) 'HTTP $statusCode',
    if (code != null) code,
    message,
  ].join(': ');
}
