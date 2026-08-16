import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationScheduleReplacement {
  const NotificationScheduleReplacement({
    required this.previousPlatformIds,
    required this.platformIdsByReminder,
  });

  final List<int> previousPlatformIds;
  final Map<String, int> platformIdsByReminder;
}

class NotificationScheduleStore {
  NotificationScheduleStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'bebeapp.notifications.schedules.v1';

  final SharedPreferencesAsync _preferences;

  Future<NotificationScheduleReplacement> replace({
    required String ownerId,
    required String accountId,
    required String babyId,
    required Iterable<String> reminderIds,
  }) async {
    final schedules = await _load();
    final previous = schedules[ownerId];
    final previousIds = previous?['ids'];
    final occupied = <int>{};
    for (final entry in schedules.entries) {
      if (entry.key == ownerId) continue;
      final ids = entry.value['ids'];
      if (ids is Map) {
        occupied.addAll(ids.values.whereType<num>().map((id) => id.toInt()));
      }
    }

    final assignments = <String, int>{};
    for (final reminderId in reminderIds) {
      final stableKey = '$ownerId|$reminderId';
      var platformId = _stablePositiveId(stableKey);
      while (occupied.contains(platformId)) {
        platformId = platformId == 0x7fffffff ? 1 : platformId + 1;
      }
      occupied.add(platformId);
      assignments[reminderId] = platformId;
    }

    schedules[ownerId] = <String, Object?>{
      'accountId': accountId,
      'babyId': babyId,
      'ids': assignments,
    };
    await _save(schedules);
    return NotificationScheduleReplacement(
      previousPlatformIds: previousIds is Map
          ? previousIds.values
                .whereType<num>()
                .map((id) => id.toInt())
                .toList(growable: false)
          : const <int>[],
      platformIdsByReminder: assignments,
    );
  }

  Future<List<int>> removeOwner(String ownerId) async {
    final schedules = await _load();
    final removed = schedules.remove(ownerId);
    await _save(schedules);
    final ids = removed?['ids'];
    return ids is Map
        ? ids.values
              .whereType<num>()
              .map((id) => id.toInt())
              .toList(growable: false)
        : const <int>[];
  }

  Future<List<int>> removeAccount(String accountId) async {
    final schedules = await _load();
    final removedIds = <int>[];
    final owners = schedules.entries
        .where((entry) => entry.value['accountId'] == accountId)
        .map((entry) => entry.key)
        .toList(growable: false);
    for (final owner in owners) {
      final removed = schedules.remove(owner);
      final ids = removed?['ids'];
      if (ids is Map) {
        removedIds.addAll(ids.values.whereType<num>().map((id) => id.toInt()));
      }
    }
    await _save(schedules);
    return removedIds;
  }

  Future<Map<String, Map<String, Object?>>> _load() async {
    final encoded = await _preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) return {};
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(
          key.toString(),
          value is Map
              ? value.map((key, value) => MapEntry(key.toString(), value))
              : <String, Object?>{},
        ),
      );
    } on Object {
      return {};
    }
  }

  Future<void> _save(Map<String, Map<String, Object?>> schedules) =>
      _preferences.setString(_storageKey, jsonEncode(schedules));

  static int _stablePositiveId(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    final positive = hash & 0x7fffffff;
    return positive == 0 ? 1 : positive;
  }
}
