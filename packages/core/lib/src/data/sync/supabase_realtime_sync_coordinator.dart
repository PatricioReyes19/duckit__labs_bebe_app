import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/session/auth_session.dart';
import '../../domain/repositories/session_repository/session_repository.dart';
import 'agenda_event_sync_service.dart';
import 'app_settings_sync_service.dart';
import 'health_event_sync_service.dart';
import 'family_sync_service.dart';
import 'register_event_sync_service.dart';
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
    this._registerSyncService,
    this._agendaSyncService, {
    required HealthEventSyncService healthSyncService,
    required AppSettingsSyncService appSettingsSyncService,
    required FamilySyncService familySyncService,
    SupabaseClient? client,
  }) : _healthSyncService = healthSyncService,
       _appSettingsSyncService = appSettingsSyncService,
       _familySyncService = familySyncService,
       _clientOverride = client;

  final SupabaseConfiguration _configuration;
  final SessionRepository _sessionRepository;
  final RegisterEventSyncService _registerSyncService;
  final AgendaEventSyncService _agendaSyncService;
  final HealthEventSyncService _healthSyncService;
  final AppSettingsSyncService _appSettingsSyncService;
  final FamilySyncService _familySyncService;
  final SupabaseClient? _clientOverride;

  StreamSubscription<AuthSession?>? _sessionSubscription;
  RealtimeChannel? _channel;
  String? _activeUserId;

  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  Future<void> start() async {
    if (!_configuration.isConfigured || _sessionSubscription != null) return;
    _sessionSubscription = _sessionRepository.sessionChanges().listen(
      (session) => unawaited(_replaceSubscription(session)),
    );
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
          callback: (_) => unawaited(_registerSyncService.synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'agenda_events',
          callback: (_) => unawaited(_agendaSyncService.synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'health_events',
          callback: (_) => unawaited(_healthSyncService.synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_preferences',
          callback: (_) => unawaited(_appSettingsSyncService.synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'families',
          callback: (_) => unawaited(_familySyncService.synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'babies',
          callback: (_) => unawaited(_familySyncService.synchronize()),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'baby_caregivers',
          callback: (_) => unawaited(_familySyncService.synchronize()),
        )
        .subscribe();
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
