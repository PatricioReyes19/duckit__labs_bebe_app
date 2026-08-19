import 'dart:io';

import '../../../domain/entities/register/register.dart';
import '../../models/register_event_model.dart';
import '../../network/supabase_remote_exception.dart';
import '../../network/supabase_rest_client.dart';
import '../../sync/remote_sync_cursor.dart';

abstract interface class RegisterEventRemoteDataSource {
  bool get isConfigured;
  Future<bool> isAuthenticated();

  Future<RegisteredEvent> push(RegisteredEvent event);

  Future<List<RegisteredEvent>> pull({DateTime? updatedAfter});
}

abstract interface class PagedRegisterEventRemoteDataSource
    implements RegisterEventRemoteDataSource {
  Future<List<RegisteredEvent>> pullPage({
    RemoteSyncCursor? after,
    int limit = 200,
  });
}

class SupabaseRegisterEventRemoteDataSource
    implements PagedRegisterEventRemoteDataSource {
  const SupabaseRegisterEventRemoteDataSource(this._client);

  static const tableName = 'register_events';
  static const mediaBucket = 'register-event-media';
  static const applyEventFunction = 'apply_register_event';

  final SupabaseRestClient _client;

  @override
  bool get isConfigured => _client.isConfigured;

  @override
  Future<bool> isAuthenticated() => _client.isAuthenticated();

  @override
  Future<RegisteredEvent> push(RegisteredEvent event) async {
    final details = await _prepareDetails(event);
    final model = RegisterEventModel.fromEntity(event);
    final response = await _client.rpc(
      applyEventFunction,
      parameters: {
        'payload': {...model.toRemoteJson(), 'details': details},
      },
    );
    return _modelFromRpcResponse(response).toEntity();
  }

  @override
  Future<List<RegisteredEvent>> pull({DateTime? updatedAfter}) async {
    final rows = await _client.select(
      tableName,
      filters: {
        if (updatedAfter != null)
          // Inclusive cursor prevents losing rows that share a server
          // timestamp; local merge is idempotent.
          'updated_at': 'gte.${updatedAfter.toUtc().toIso8601String()}',
      },
      order: 'updated_at.asc,id.asc',
    );
    return rows
        .map(RegisterEventModel.fromRemoteJson)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  @override
  Future<List<RegisteredEvent>> pullPage({
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
        .map(RegisterEventModel.fromRemoteJson)
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  static String _afterFilter(RemoteSyncCursor cursor) {
    final timestamp = cursor.updatedAt.toUtc().toIso8601String();
    final id = cursor.id.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    return '(updated_at.gt.$timestamp,'
        'and(updated_at.eq.$timestamp,id.gt."$id"))';
  }

  Future<Map<String, Object?>> _prepareDetails(RegisteredEvent event) async {
    final details = Map<String, Object?>.from(event.details);
    final localPaths = _stringList(details.remove('photo_paths'));
    final storagePaths = <String>{
      ..._stringList(details['photo_storage_paths']),
    };

    if (event.isDeleted) {
      try {
        final rows = await _client.select(
          tableName,
          columns: 'details',
          filters: {'id': 'eq.${event.id}'},
          limit: 1,
        );
        if (rows case [final remote, ...]) {
          final remoteDetails = remote['details'];
          if (remoteDetails is Map) {
            storagePaths.addAll(
              _stringList(remoteDetails['photo_storage_paths']),
            );
          }
        }
      } on SupabaseRemoteException {
        // A missing remote row must not prevent the tombstone from syncing.
      }
      await _client.removeObjects(
        bucket: mediaBucket,
        paths: storagePaths.toList(growable: false),
      );
      details['photo_storage_paths'] = const <String>[];
      return details;
    }

    for (var index = 0; index < localPaths.length; index++) {
      final localPath = localPaths[index];
      final file = File(localPath);
      if (!await file.exists()) {
        if (_looksLikeStoragePath(localPath)) storagePaths.add(localPath);
        continue;
      }
      final originalName = localPath.replaceAll('\\', '/').split('/').last;
      final safeName = originalName.replaceAll(RegExp('[^a-zA-Z0-9._-]'), '_');
      final storagePath = '${event.babyId}/${event.id}/${index}_$safeName';
      await _client.uploadObject(
        bucket: mediaBucket,
        path: storagePath,
        file: file,
        contentType: _contentTypeFor(originalName),
      );
      storagePaths.add(storagePath);
    }
    if (storagePaths.isNotEmpty) {
      details['photo_storage_paths'] = storagePaths.toList(growable: false);
    }
    return details;
  }

  static RegisterEventModel _modelFromRpcResponse(Object? response) {
    final value = response is List && response.isNotEmpty
        ? response.first
        : response;
    if (value is! Map) {
      throw const FormatException('Invalid Supabase register response.');
    }
    return RegisterEventModel.fromRemoteJson(Map<String, dynamic>.from(value));
  }

  static List<String> _stringList(Object? value) => switch (value) {
    final List values => values.whereType<String>().toList(growable: false),
    _ => const <String>[],
  };

  static bool _looksLikeStoragePath(String value) =>
      !value.contains('\\') && !value.startsWith('/') && value.contains('/');

  static String _contentTypeFor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'heic' => 'image/heic',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }
}
