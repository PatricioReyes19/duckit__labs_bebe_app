import '../../../domain/entities/health/health.dart';
import '../../models/health_models.dart';
import '../../network/supabase_rest_client.dart';
import '../../sync/remote_sync_cursor.dart';

abstract interface class HealthEventRemoteDataSource {
  bool get isConfigured;

  Future<bool> isAuthenticated();

  Future<HealthEventEntity> push(HealthEventEntity event);

  Future<List<HealthEventEntity>> pull({DateTime? updatedAfter});
}

/// Optional keyset pagination for health history. The base interface remains
/// compatible with existing remotes while production Supabase clients avoid
/// downloading an unbounded account history into memory.
abstract interface class PagedHealthEventRemoteDataSource
    implements HealthEventRemoteDataSource {
  Future<List<HealthEventEntity>> pullPage({
    RemoteSyncCursor? after,
    int limit = 200,
  });
}

class SupabaseHealthEventRemoteDataSource
    implements PagedHealthEventRemoteDataSource {
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

  @override
  Future<List<HealthEventEntity>> pullPage({
    RemoteSyncCursor? after,
    int limit = 200,
  }) async {
    final rows = await _client.select(
      tableName,
      filters: {if (after != null) 'or': _afterFilter(after)},
      order: 'updated_at.asc,id.asc',
      limit: limit,
    );
    return rows
        .map(HealthEventModel.fromRemoteJson)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  static String _afterFilter(RemoteSyncCursor cursor) {
    final timestamp = cursor.updatedAt.toUtc().toIso8601String();
    final id = cursor.id.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    return '(updated_at.gt.$timestamp,'
        'and(updated_at.eq.$timestamp,id.gt."$id"))';
  }
}
