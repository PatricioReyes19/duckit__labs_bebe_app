import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class FamilySyncStatusSection extends StatelessWidget {
  const FamilySyncStatusSection({
    required this.state,
    this.onRetry,
    this.clock,
    super.key,
  });

  final SyncUxState state;
  final VoidCallback? onRetry;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      key: const Key('family-sync-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BebeTitleSection(title: 'Sincronización'),
        SizedBox(height: spacing.spacingL),
        _statusBanner(),
      ],
    );
  }

  Widget _statusBanner() => switch (state.status) {
    SyncUxStatus.synced => BebeStatusBanner(
      key: const Key('family-sync-synced'),
      compact: true,
      type: BebeStatusBannerType.success,
      title: 'Sincronizado',
      description: _lastUpdateLabel(),
      leading: const Icon(Icons.cloud_done_outlined),
    ),
    SyncUxStatus.syncing => BebeStatusBanner(
      key: const Key('family-sync-syncing'),
      compact: true,
      type: BebeStatusBannerType.syncing,
      title: 'Sincronizando',
      description: state.pendingOperations == 0
          ? 'Actualizando la información de la familia…'
          : _pendingLabel(state.pendingOperations),
      leading: const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
    SyncUxStatus.pending => BebeStatusBanner(
      key: const Key('family-sync-pending'),
      compact: true,
      type: BebeStatusBannerType.warning,
      title: 'Sincronización pendiente',
      description: state.pendingOperations == 0
          ? 'Los cambios se sincronizarán cuando sea posible.'
          : _pendingLabel(state.pendingOperations),
      leading: const Icon(Icons.schedule_rounded),
    ),
    SyncUxStatus.offline => BebeStatusBanner(
      key: const Key('family-sync-offline'),
      compact: true,
      type: BebeStatusBannerType.neutral,
      title: 'Sin conexión',
      description: state.hasLocallyPersistedChanges
          ? '${_pendingLabel(state.pendingOperations)} Se enviarán al recuperar la conexión.'
          : 'La información disponible sigue accesible en este dispositivo.',
      leading: const Icon(Icons.cloud_off_outlined),
    ),
    SyncUxStatus.error => BebeStatusBanner(
      key: const Key('family-sync-error'),
      compact: true,
      type: BebeStatusBannerType.error,
      title: 'Error de sincronización',
      description: state.hasLocallyPersistedChanges
          ? 'Tus cambios siguen guardados en este dispositivo.'
          : 'No pudimos actualizar algunos datos.',
      leading: const Icon(Icons.sync_problem_rounded),
      footer: onRetry == null
          ? null
          : Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ),
      onPressed: onRetry,
    ),
  };

  String _lastUpdateLabel() {
    final lastSync = state.lastSuccessfulSyncAt;
    if (lastSync == null) return 'Actualización completada';
    final difference = (clock?.call() ?? DateTime.now()).toUtc().difference(
      lastSync.toUtc(),
    );
    if (difference.inMinutes < 1) return 'Última actualización: ahora';
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return 'Última actualización: hace $minutes min';
    }
    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return 'Última actualización: hace $hours h';
    }
    final days = difference.inDays;
    return 'Última actualización: hace $days ${days == 1 ? 'día' : 'días'}';
  }

  static String _pendingLabel(int count) =>
      count == 1 ? '1 cambio pendiente.' : '$count cambios pendientes.';
}
