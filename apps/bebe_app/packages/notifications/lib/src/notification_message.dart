import 'package:firebase_messaging/firebase_messaging.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.data = const <String, String>{},
    this.wasOpened = false,
  });

  factory AppNotification.fromRemoteMessage(
    RemoteMessage message, {
    bool wasOpened = false,
  }) {
    final data = message.data.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final notification = message.notification;
    final receivedAt = message.sentTime ?? DateTime.now();

    return AppNotification(
      id:
          message.messageId ??
          '${receivedAt.microsecondsSinceEpoch}-${data.hashCode}',
      title: notification?.title ?? data['title'] ?? 'BebéApp',
      body: notification?.body ?? data['body'] ?? 'Tienes una novedad.',
      receivedAt: receivedAt,
      data: data,
      wasOpened: wasOpened,
    );
  }

  factory AppNotification.fromJson(Map<String, Object?> json) {
    final rawData = json['data'];
    final data = <String, String>{};
    if (rawData is Map) {
      for (final entry in rawData.entries) {
        data[entry.key.toString()] = entry.value.toString();
      }
    }

    return AppNotification(
      id: json['id']! as String,
      title: json['title']! as String,
      body: json['body']! as String,
      receivedAt: DateTime.parse(json['receivedAt']! as String),
      data: data,
      wasOpened: json['wasOpened'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, String> data;
  final bool wasOpened;

  String? get route {
    final candidate = data['route']?.trim();
    if (candidate == null || !candidate.startsWith('/')) {
      return null;
    }
    final uri = Uri.tryParse(candidate);
    if (uri == null || uri.hasAuthority || uri.hasFragment) return null;

    const allowedPrefixes = <String>{
      '/home',
      '/agenda',
      '/health',
      '/family',
      '/register',
      '/notifications',
      '/invitation',
    };

    return allowedPrefixes.any(
          (prefix) => uri.path == prefix || uri.path.startsWith('$prefix/'),
        )
        ? candidate
        : null;
  }

  AppNotification copyWith({bool? wasOpened}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      receivedAt: receivedAt,
      data: data,
      wasOpened: wasOpened ?? this.wasOpened,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'body': body,
    'receivedAt': receivedAt.toIso8601String(),
    'data': data,
    'wasOpened': wasOpened,
  };
}
