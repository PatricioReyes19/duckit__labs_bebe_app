import '../../../domain/entities/agenda/agenda.dart';
import '../../models/agenda_event_model.dart';
import '../../network/supabase_rest_client.dart';
import '../../sync/remote_sync_cursor.dart';

abstract interface class AgendaEventRemoteDataSource {
  bool get isConfigured;
  Future<bool> isAuthenticated();
  Future<AgendaEventEntity> push(AgendaEventEntity event);
  Future<List<AgendaEventEntity>> pull({DateTime? updatedAfter});
}

abstract interface class PagedAgendaEventRemoteDataSource
    implements AgendaEventRemoteDataSource {
  Future<List<AgendaEventEntity>> pullPage({
    RemoteSyncCursor? after,
    int limit = 200,
  });
}

class SupabaseAgendaEventRemoteDataSource
    implements PagedAgendaEventRemoteDataSource {
  const SupabaseAgendaEventRemoteDataSource(this._client);

  static const tableName = 'agenda_events';
  static const applyEventFunction = 'apply_agenda_event';

  final SupabaseRestClient _client;

  @override
  bool get isConfigured => _client.isConfigured;

  @override
  Future<bool> isAuthenticated() => _client.isAuthenticated();

  @override
  Future<AgendaEventEntity> push(AgendaEventEntity event) async {
    final response = await _client.rpc(
      applyEventFunction,
      parameters: {
        'payload': AgendaEventModel.fromEntity(event).toRemoteJson(),
      },
    );
    return _modelFromRpcResponse(response).toEntity();
  }

  @override
  Future<List<AgendaEventEntity>> pull({DateTime? updatedAfter}) async {
    final rows = await _client.select(
      tableName,
      filters: {
        if (updatedAfter != null)
          'updated_at': 'gte.${updatedAfter.toUtc().toIso8601String()}',
      },
      order: 'updated_at.asc,id.asc',
    );
    return rows
        .map(AgendaEventModel.fromRemoteJson)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  @override
  Future<List<AgendaEventEntity>> pullPage({
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
        .map(AgendaEventModel.fromRemoteJson)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  static String _afterFilter(RemoteSyncCursor cursor) {
    final timestamp = cursor.updatedAt.toUtc().toIso8601String();
    final id = cursor.id.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    return '(updated_at.gt.$timestamp,'
        'and(updated_at.eq.$timestamp,id.gt."$id"))';
  }

  static AgendaEventModel _modelFromRpcResponse(Object? response) {
    final value = response is List && response.isNotEmpty
        ? response.first
        : response;
    if (value is! Map) {
      throw const FormatException('Invalid Supabase agenda response.');
    }
    return AgendaEventModel.fromRemoteJson(Map<String, dynamic>.from(value));
  }
}
