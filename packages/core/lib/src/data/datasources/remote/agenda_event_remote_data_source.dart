import '../../../domain/entities/agenda/agenda.dart';
import '../../models/agenda_event_model.dart';
import '../../network/supabase_rest_client.dart';

abstract interface class AgendaEventRemoteDataSource {
  bool get isConfigured;
  Future<bool> isAuthenticated();
  Future<AgendaEventEntity> push(AgendaEventEntity event);
  Future<List<AgendaEventEntity>> pull({DateTime? updatedAfter});
}

class SupabaseAgendaEventRemoteDataSource
    implements AgendaEventRemoteDataSource {
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
