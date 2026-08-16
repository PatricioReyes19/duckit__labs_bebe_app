import 'register_event_sync_service.dart';

/// Estado consolidado que puede mostrarse sin exponer detalles del motor de
/// sincronización ni del proveedor remoto.
enum SyncUxStatus { synced, syncing, pending, offline, error }

enum SyncUxScope { family, register, agenda, health, preferences }

class SyncUxState {
  const SyncUxState({
    required this.status,
    this.lastSuccessfulSyncAt,
    this.pendingOperations = 0,
    this.errorScopes = const <SyncUxScope>{},
    this.errorKey,
  });

  const SyncUxState.pending() : this(status: SyncUxStatus.pending);

  final SyncUxStatus status;
  final DateTime? lastSuccessfulSyncAt;
  final int pendingOperations;
  final Set<SyncUxScope> errorScopes;

  /// Identificador interno para deduplicar un mismo incidente. Nunca debe
  /// mostrarse directamente en UI porque puede contener texto técnico.
  final String? errorKey;

  bool get canRetry => status == SyncUxStatus.error;
  bool get hasLocallyPersistedChanges => pendingOperations > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncUxState &&
          status == other.status &&
          lastSuccessfulSyncAt == other.lastSuccessfulSyncAt &&
          pendingOperations == other.pendingOperations &&
          _sameScopes(errorScopes, other.errorScopes) &&
          errorKey == other.errorKey;

  @override
  int get hashCode => Object.hash(
    status,
    lastSuccessfulSyncAt,
    pendingOperations,
    Object.hashAllUnordered(errorScopes),
    errorKey,
  );
}

/// Reduce los estados de los servicios existentes a un único vocabulario de
/// UX. No ejecuta sincronizaciones ni mantiene una cola adicional.
SyncUxState resolveSyncUxState(
  Map<SyncUxScope, RegisterSyncState> states, {
  SyncUxState previous = const SyncUxState.pending(),
  bool forceSyncing = false,
}) {
  final values = states.values;
  final pendingOperations = values.fold<int>(
    0,
    (total, state) => total + state.pendingCount,
  );
  final lastSuccessfulSyncAt = values
      .map((state) => state.lastSyncedAt)
      .whereType<DateTime>()
      .fold<DateTime?>(previous.lastSuccessfulSyncAt, _latest);

  if (forceSyncing ||
      values.any((state) => state.phase == RegisterSyncPhase.syncing)) {
    return SyncUxState(
      status: SyncUxStatus.syncing,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt,
      pendingOperations: pendingOperations,
    );
  }

  final failures = states.entries
      .where((entry) => entry.value.phase == RegisterSyncPhase.failed)
      .toList(growable: false);
  if (failures.isNotEmpty) {
    final allOffline = failures.every(
      (entry) => _looksLikeConnectivityFailure(entry.value.message),
    );
    final scopes = failures.map((entry) => entry.key).toSet();
    return SyncUxState(
      status: allOffline ? SyncUxStatus.offline : SyncUxStatus.error,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt,
      pendingOperations: pendingOperations,
      errorScopes: scopes,
      errorKey: allOffline ? null : _errorKey(failures),
    );
  }

  if (values.any((state) => state.phase == RegisterSyncPhase.disabled)) {
    return SyncUxState(
      status: SyncUxStatus.offline,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt,
      pendingOperations: pendingOperations,
    );
  }

  if (pendingOperations > 0 ||
      values.any(
        (state) =>
            state.phase == RegisterSyncPhase.idle ||
            state.phase == RegisterSyncPhase.waitingForAuthentication,
      )) {
    return SyncUxState(
      status: SyncUxStatus.pending,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt,
      pendingOperations: pendingOperations,
    );
  }

  return SyncUxState(
    status: SyncUxStatus.synced,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt,
  );
}

/// Política transitoria: los éxitos nunca alertan y un mismo error persistente
/// se anuncia una sola vez, incluso si hay varios reintentos intermedios.
class SyncErrorAlertDeduplicator {
  String? _lastAlertedErrorKey;

  bool shouldAlert(SyncUxState state) {
    if (state.status == SyncUxStatus.synced) {
      _lastAlertedErrorKey = null;
      return false;
    }
    if (state.status != SyncUxStatus.error) return false;

    final key = state.errorKey ?? _fallbackErrorKey(state);
    if (key == _lastAlertedErrorKey) return false;
    _lastAlertedErrorKey = key;
    return true;
  }
}

DateTime? _latest(DateTime? current, DateTime candidate) =>
    current == null || candidate.isAfter(current) ? candidate : current;

bool _looksLikeConnectivityFailure(String? message) {
  final normalized = message?.toLowerCase() ?? '';
  return normalized.contains('socketexception') ||
      normalized.contains('failed host lookup') ||
      normalized.contains('network is unreachable') ||
      normalized.contains('network request failed') ||
      normalized.contains('connection refused') ||
      normalized.contains('connection reset') ||
      normalized.contains('clientexception') ||
      normalized.contains('offline') ||
      normalized.contains('sin conexión');
}

String _errorKey(
  List<MapEntry<SyncUxScope, RegisterSyncState>> failures,
) => (failures.toList()..sort((a, b) => a.key.index.compareTo(b.key.index)))
    .map(
      (entry) =>
          '${entry.key.name}:${entry.value.message?.trim().toLowerCase() ?? 'unknown'}',
    )
    .join('|');

String _fallbackErrorKey(SyncUxState state) =>
    '${state.errorScopes.map((scope) => scope.name).join(',')}:'
    '${state.pendingOperations}';

bool _sameScopes(Set<SyncUxScope> left, Set<SyncUxScope> right) =>
    left.length == right.length && left.containsAll(right);
