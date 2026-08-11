import '../../../domain/entities/health/health.dart';
import '../../models/health_models.dart';
import '../../network/supabase_rest_client.dart';

abstract interface class HealthEventRemoteDataSource {
  bool get isConfigured;

  Future<bool> isAuthenticated();

  Future<HealthEventEntity> push(HealthEventEntity event);

  Future<List<HealthEventEntity>> pull({DateTime? updatedAfter});
}

class SupabaseHealthEventRemoteDataSource
    implements HealthEventRemoteDataSource {
  const SupabaseHealthEventRemoteDataSource(this._client);

  static const tableName = 'health_events';
  static const applyEventFunction = 'apply_health_event';

  final SupabaseRestClient _client;

  @override
  bool get isConfigured => _client.isConfigured;

  @override
  Future<bool> isAuthenticated() => _client.isAuthenticated();

  @override
  Future<HealthEventEntity> push(HealthEventEntity event) async {
    final response = await _client.rpc(
      applyEventFunction,
      parameters: {
        'payload': HealthEventModel.fromEntity(event).toRemoteJson(),
      },
    );
    final value = response is List && response.isNotEmpty
        ? response.first
        : response;
    if (value is! Map) {
      throw const FormatException('Invalid Supabase health response.');
    }
    return HealthEventModel.fromRemoteJson(
      Map<String, dynamic>.from(value),
    ).toEntity();
  }

  @override
  Future<List<HealthEventEntity>> pull({DateTime? updatedAfter}) async {
    final rows = await _client.select(
      tableName,
      filters: {
        if (updatedAfter != null)
          'updated_at': 'gte.${updatedAfter.toUtc().toIso8601String()}',
      },
      order: 'updated_at.asc,id.asc',
    );
    return rows
        .map(HealthEventModel.fromRemoteJson)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }
}
