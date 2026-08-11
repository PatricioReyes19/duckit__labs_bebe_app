import '../../models/activity_notification_model.dart';
import '../../network/supabase_rest_client.dart';

abstract interface class ActivityNotificationRemoteDataSource {
  bool get isConfigured;

  Future<bool> isAuthenticated();

  Future<List<ActivityNotificationModel>> listUnread({int limit = 100});

  Future<void> markRead(String id);

  Future<void> markAllRead();
}

class SupabaseActivityNotificationRemoteDataSource
    implements ActivityNotificationRemoteDataSource {
  const SupabaseActivityNotificationRemoteDataSource(this._client);

  static const tableName = 'activity_notifications';

  final SupabaseRestClient _client;

  @override
  bool get isConfigured => _client.isConfigured;

  @override
  Future<bool> isAuthenticated() => _client.isAuthenticated();

  @override
  Future<List<ActivityNotificationModel>> listUnread({int limit = 100}) async {
    final rows = await _client.select(
      tableName,
      filters: const {'read_at': 'is.null'},
      order: 'created_at.desc',
      limit: limit,
    );
    return rows
        .map(ActivityNotificationModel.fromRemoteJson)
        .toList(growable: false);
  }

  @override
  Future<void> markRead(String id) async {
    await _client.patch(
      tableName,
      data: {'read_at': DateTime.now().toUtc().toIso8601String()},
      filters: {'id': 'eq.$id'},
    );
  }

  @override
  Future<void> markAllRead() async {
    await _client.patch(
      tableName,
      data: {'read_at': DateTime.now().toUtc().toIso8601String()},
      filters: const {'read_at': 'is.null'},
    );
  }
}
