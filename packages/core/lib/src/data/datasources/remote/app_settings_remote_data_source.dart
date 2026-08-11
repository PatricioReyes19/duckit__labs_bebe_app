import '../../models/app_settings_model.dart';
import '../../network/supabase_rest_client.dart';

abstract interface class AppSettingsRemoteDataSource {
  bool get isConfigured;

  Future<bool> isAuthenticated();

  Future<AppSettingsSyncRecord> push(AppSettingsSyncRecord record);

  Future<AppSettingsSyncRecord?> pull();
}

class SupabaseAppSettingsRemoteDataSource
    implements AppSettingsRemoteDataSource {
  const SupabaseAppSettingsRemoteDataSource(this._client);

  static const tableName = 'user_preferences';
  static const applyFunction = 'apply_user_preferences';

  final SupabaseRestClient _client;

  @override
  bool get isConfigured => _client.isConfigured;

  @override
  Future<bool> isAuthenticated() => _client.isAuthenticated();

  @override
  Future<AppSettingsSyncRecord> push(AppSettingsSyncRecord record) async {
    final response = await _client.rpc(
      applyFunction,
      parameters: {'payload': record.toRemoteJson()},
    );
    return _fromResponse(response);
  }

  @override
  Future<AppSettingsSyncRecord?> pull() async {
    final rows = await _client.select(tableName, limit: 1);
    return rows.isEmpty
        ? null
        : AppSettingsSyncRecord.fromRemoteJson(rows.single);
  }

  static AppSettingsSyncRecord _fromResponse(Object? response) {
    final value = response is List && response.isNotEmpty
        ? response.first
        : response;
    if (value is! Map) {
      throw const FormatException('Invalid Supabase preferences response.');
    }
    return AppSettingsSyncRecord.fromRemoteJson(
      Map<String, dynamic>.from(value),
    );
  }
}
