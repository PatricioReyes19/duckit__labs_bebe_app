import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'notification_message.dart';

class NotificationInboxStore {
  NotificationInboxStore({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'bebeapp.notifications.inbox.v1';
  static const _maximumItems = 100;

  final SharedPreferencesAsync _preferences;

  Future<List<AppNotification>> load() async {
    final encoded = await _preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) {
      return <AppNotification>[];
    }

    try {
      final raw = jsonDecode(encoded);
      if (raw is! List) {
        return <AppNotification>[];
      }

      return raw
          .whereType<Map>()
          .map(
            (item) => AppNotification.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    } on Object {
      return <AppNotification>[];
    }
  }

  Future<List<AppNotification>> add(AppNotification notification) async {
    final current = await load();
    final updated = <AppNotification>[
      notification,
      ...current.where((item) => item.id != notification.id),
    ].take(_maximumItems).toList(growable: false);
    await save(updated);
    return updated;
  }

  Future<void> save(List<AppNotification> notifications) {
    return _preferences.setString(
      _storageKey,
      jsonEncode(
        notifications
            .take(_maximumItems)
            .map((notification) => notification.toJson())
            .toList(growable: false),
      ),
    );
  }

  Future<void> clear() => _preferences.remove(_storageKey);
}
