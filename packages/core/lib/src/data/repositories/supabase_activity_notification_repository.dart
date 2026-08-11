import '../../domain/entities/notifications/activity_notification.dart';
import '../../domain/repositories/notifications/activity_notification_repository.dart';
import '../datasources/remote/activity_notification_remote_data_source.dart';

class SupabaseActivityNotificationRepository
    implements ActivityNotificationRepository {
  const SupabaseActivityNotificationRepository(this._remote);

  final ActivityNotificationRemoteDataSource _remote;

  @override
  Future<List<ActivityNotificationEntity>> listUnread({int limit = 100}) async {
    if (!_remote.isConfigured || !await _remote.isAuthenticated()) {
      return const [];
    }
    return (await _remote.listUnread(
      limit: limit,
    )).map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<void> markRead(String id) async {
    if (!_remote.isConfigured || !await _remote.isAuthenticated()) return;
    await _remote.markRead(id);
  }

  @override
  Future<void> markAllRead() async {
    if (!_remote.isConfigured || !await _remote.isAuthenticated()) return;
    await _remote.markAllRead();
  }
}
