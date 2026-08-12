import 'dart:async';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/session/auth_session.dart';
import '../../domain/repositories/session_repository/session_repository.dart';
import 'initial_data_sync_coordinator.dart';
import 'supabase_configuration.dart';

/// Converts authorized remote database changes into local pull operations.
///
/// Realtime never writes directly to SQLite. It only wakes the existing sync
/// services, keeping conflict resolution and the local source of truth in one
/// place.
class SupabaseRealtimeSyncCoordinator {
  SupabaseRealtimeSyncCoordinator(
    this._configuration,
    this._sessionRepository,
    this._initialDataSyncCoordinator, {
    SupabaseClient? client,
  }) : _clientOverride = client;

  final SupabaseConfiguration _configuration;
  final SessionRepository _sessionRepository;
  final InitialDataSyncCoordinator _initialDataSyncCoordinator;
  final SupabaseClient? _clientOverride;

  StreamSubscription<AuthSession?>? _sessionSubscription;
  RealtimeChannel? _channel;
  String? _activeUserId;

  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  Future<void> start() async {
    if (!_configuration.isConfigured) return;
    _sessionSubscription ??= _sessionRepository.sessionChanges().listen(
      _handleSessionChange,
    );
    // Authenticated sessions are subscribed only through this explicit call,
    // made by InitialDataSyncCoordinator after parent/child hydration.
    await _replaceSubscription(await _sessionRepository.currentSession());
  }

  Future<void> _replaceSubscription(AuthSession? session) async {
    final userId = session?.user.id;
    if (_activeUserId == userId && _channel != null) return;
    final currentChannel = _channel;
    _channel = null;
    _activeUserId = userId;
    if (currentChannel != null) {
      await _client.removeChannel(currentChannel);
    }
    if (userId == null) return;

    _channel = _client
        .channel('bebeapp-core-sync:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'register_events',
          callback: (_) => _scheduleSync(RealtimeSyncTarget.register),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'agenda_events',
          callback: (_) => _scheduleSync(RealtimeSyncTarget.agenda),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'health_events',
          callback: (_) => _scheduleSync(RealtimeSyncTarget.health),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_preferences',
          callback: (_) => _scheduleSync(RealtimeSyncTarget.preferences),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'families',
          callback: (_) => _scheduleSync(RealtimeSyncTarget.family),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'babies',
          callback: (_) => _scheduleSync(RealtimeSyncTarget.family),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'baby_caregivers',
          callback: (_) => _scheduleSync(RealtimeSyncTarget.family),
        )
        .subscribe();
  }

  void _handleSessionChange(AuthSession? session) {
    // Logout stops delivery immediately. A later login intentionally waits
    // until InitialDataSyncCoordinator invokes start() after Family sync.
    if (session != null) return;
    unawaited(
      _replaceSubscription(session).then<void>((_) {}, onError: _reportError),
    );
  }

  void _scheduleSync(RealtimeSyncTarget target) {
    unawaited(
      _initialDataSyncCoordinator
          .synchronizeFromRealtime(target)
          .then<void>((_) {}, onError: _reportError),
    );
  }

  static void _reportError(Object error, StackTrace stackTrace) {
    developer.log(
      'Realtime synchronization callback failed',
      name: 'bebeapp.sync',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> close() async {
    await _sessionSubscription?.cancel();
    _sessionSubscription = null;
    final currentChannel = _channel;
    _channel = null;
    _activeUserId = null;
    if (currentChannel != null) await _client.removeChannel(currentChannel);
  }
}
