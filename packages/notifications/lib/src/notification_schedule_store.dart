import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationScheduleReplacement {
  const NotificationScheduleReplacement({
    required this.previousPlatformIds,
    required this.platformIdsByReminder,
    required this.reminderIdsToSchedule,
  });

  /// Native ids that must be cancelled because their reminder disappeared or
  /// its persisted schedule changed.
  final List<int> previousPlatformIds;

  /// Stable native id for every reminder in the desired owner snapshot.
  final Map<String, int> platformIdsByReminder;

  /// Desired reminders that are new or changed. An empty set means the
  /// replacement was an idempotent no-op at platform level.
  final Set<String> reminderIdsToSchedule;
}

class NotificationScheduleData {
  const NotificationScheduleData({
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.route,
    required this.type,
    required this.timeZone,
  });

  final String title;
  final String body;
  final DateTime scheduledAt;
  final String route;
  final String type;
  final String timeZone;

  Map<String, Object?> toJson({required int platformId}) => <String, Object?>{
    'platformId': platformId,
    'title': title,
    'body': body,
    'scheduledAtUtc': scheduledAt.toUtc().toIso8601String(),
    'route': route,
    'type': type,
    'timeZone': timeZone,
  };
}

class StoredNotificationSchedule {
  const StoredNotificationSchedule({
    required this.ownerId,
    required this.accountId,
    required this.babyId,
    required this.reminderId,
    required this.platformId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.route,
    required this.type,
    required this.timeZone,
  });

  final String ownerId;
  final String accountId;
  final String babyId;
  final String reminderId;
  final int platformId;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String route;
  final String type;
  final String timeZone;
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
    Map<String, NotificationScheduleData> reminderData = const {},
  }) async {
    final schedules = await _load();
    final previous = schedules[ownerId];
    final previousIds = previous?['ids'];
    final previousRecords = previous?['records'];
    final occupied = <int>{};
    for (final entry in schedules.entries) {
      if (entry.key == ownerId) continue;
      final ids = entry.value['ids'];
      if (ids is Map) {
        occupied.addAll(ids.values.whereType<num>().map((id) => id.toInt()));
      }
    }

    final desiredReminderIds = reminderIds.toSet();
    final assignments = <String, int>{};
    for (final reminderId in desiredReminderIds) {
      final storedId = previousIds is Map
          ? (previousIds[reminderId] as num?)?.toInt()
          : null;
      final stableKey = '$ownerId|$reminderId';
      var platformId = storedId ?? _stablePositiveId(stableKey);
      while (occupied.contains(platformId)) {
        platformId = platformId == 0x7fffffff ? 1 : platformId + 1;
      }
      occupied.add(platformId);
      assignments[reminderId] = platformId;
    }

    final records = <String, Object?>{};
    for (final entry in assignments.entries) {
      final data = reminderData[entry.key];
      if (data != null) {
        records[entry.key] = data.toJson(platformId: entry.value);
      }
    }
    final desiredOwner = <String, Object?>{
      'accountId': accountId,
      'babyId': babyId,
      'ids': assignments,
      'records': records,
    };
    final reminderIdsToSchedule = <String>{};
    for (final reminderId in assignments.keys) {
      final previousRecord = previousRecords is Map
          ? previousRecords[reminderId]
          : null;
      final currentRecord = records[reminderId];
      final sameOwnerScope =
          previous?['accountId'] == accountId && previous?['babyId'] == babyId;
      if (!sameOwnerScope || !_jsonEquivalent(previousRecord, currentRecord)) {
        reminderIdsToSchedule.add(reminderId);
      }
    }
    final previousPlatformIds = <int>[];
    if (previousIds is Map) {
      for (final entry in previousIds.entries) {
        final previousId = (entry.value as num?)?.toInt();
        if (previousId == null) continue;
        final reminderId = entry.key.toString();
        if (!assignments.containsKey(reminderId) ||
            assignments[reminderId] != previousId) {
          previousPlatformIds.add(previousId);
        }
      }
    }

    final ownerChanged = !_jsonEquivalent(previous, desiredOwner);
    if (assignments.isEmpty) {
      if (previous != null) {
        schedules.remove(ownerId);
        await _save(schedules);
      }
    } else if (ownerChanged) {
      schedules[ownerId] = desiredOwner;
      await _save(schedules);
    }
    return NotificationScheduleReplacement(
      previousPlatformIds: previousPlatformIds,
      platformIdsByReminder: assignments,
      reminderIdsToSchedule: reminderIdsToSchedule,
    );
  }

  Future<List<StoredNotificationSchedule>> listForAccount(
    String accountId,
  ) async {
    final schedules = await _load();
    final result = <StoredNotificationSchedule>[];
    for (final owner in schedules.entries) {
      if (owner.value['accountId'] != accountId) continue;
      final babyId = owner.value['babyId']?.toString() ?? '';
      final records = owner.value['records'];
      if (records is! Map) continue;
      for (final entry in records.entries) {
        final raw = entry.value;
        if (raw is! Map) continue;
        final platformId = (raw['platformId'] as num?)?.toInt();
        final scheduledAt = DateTime.tryParse(
          raw['scheduledAtUtc']?.toString() ?? '',
        );
        if (platformId == null || scheduledAt == null) continue;
        result.add(
          StoredNotificationSchedule(
            ownerId: owner.key,
            accountId: accountId,
            babyId: babyId,
            reminderId: entry.key.toString(),
            platformId: platformId,
            title: raw['title']?.toString() ?? '',
            body: raw['body']?.toString() ?? '',
            scheduledAt: scheduledAt,
            route: raw['route']?.toString() ?? '/agenda',
            type: raw['type']?.toString() ?? 'custom',
            timeZone: raw['timeZone']?.toString() ?? 'UTC',
          ),
        );
      }
    }
    result.sort(
      (first, second) => first.scheduledAt.compareTo(second.scheduledAt),
    );
    return result;
  }

  Future<List<int>> pruneExpired({
    required String accountId,
    required DateTime now,
  }) async {
    final schedules = await _load();
    final expiredPlatformIds = <int>[];
    final emptyOwners = <String>[];
    for (final owner in schedules.entries) {
      if (owner.value['accountId'] != accountId) continue;
      final ids = owner.value['ids'];
      final records = owner.value['records'];
      if (ids is! Map || records is! Map) continue;
      final expiredReminderIds = <String>[];
      for (final entry in records.entries) {
        final raw = entry.value;
        if (raw is! Map) continue;
        final scheduledAt = DateTime.tryParse(
          raw['scheduledAtUtc']?.toString() ?? '',
        );
        if (scheduledAt == null || !scheduledAt.isAfter(now)) {
          expiredReminderIds.add(entry.key.toString());
          final platformId = (raw['platformId'] as num?)?.toInt();
          if (platformId != null) expiredPlatformIds.add(platformId);
        }
      }
      for (final reminderId in expiredReminderIds) {
        records.remove(reminderId);
        ids.remove(reminderId);
      }
      if (ids.isEmpty) emptyOwners.add(owner.key);
    }
    for (final ownerId in emptyOwners) {
      schedules.remove(ownerId);
    }
    await _save(schedules);
    return expiredPlatformIds;
  }

  Future<List<int>> removeOwner(String ownerId) async {
    final schedules = await _load();
    final removed = schedules.remove(ownerId);
    if (removed != null) await _save(schedules);
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

  Future<List<int>> removeOwnersExcept({
    required String accountId,
    required String babyId,
    required Set<String> retainedOwnerIds,
  }) async {
    final schedules = await _load();
    final removedIds = <int>[];
    final owners = schedules.entries
        .where((entry) {
          if (entry.value['accountId'] != accountId) return false;
          // Older versions persisted one Agenda owner per generated
          // medication occurrence. Those owners use an internal namespace
          // and are superseded by the single Register-series owner.
          if (entry.key.startsWith('account:$accountId|agenda:dose-')) {
            return true;
          }
          return entry.value['babyId'] == babyId &&
              !retainedOwnerIds.contains(entry.key);
        })
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

  static bool _jsonEquivalent(Object? first, Object? second) =>
      jsonEncode(first) == jsonEncode(second);
}
