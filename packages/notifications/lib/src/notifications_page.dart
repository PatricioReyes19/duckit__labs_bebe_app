import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'notification_message.dart';
import 'notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    required this.notificationService,
    this.onBackPressed,
    this.onNotificationPressed,
    super.key,
  });

  final NotificationService notificationService;
  final VoidCallback? onBackPressed;
  final ValueChanged<AppNotification>? onNotificationPressed;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  StreamSubscription<List<AppNotification>>? _subscription;
  late List<AppNotification> _notifications;
  NotificationPermissionState? _permission;
  NotificationDiagnostics? _diagnostics;
  bool _requestingPermission = false;
  bool _updatingDiagnostics = false;

  @override
  void initState() {
    super.initState();
    _notifications = widget.notificationService.currentNotifications;
    _subscription = widget.notificationService.notifications.listen((items) {
      if (mounted) {
        setState(() => _notifications = items);
      }
    });
    unawaited(_refresh());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.notificationService.refreshInbox();
    final permission = await widget.notificationService.permissionState();
    if (mounted) {
      setState(() {
        _notifications = widget.notificationService.currentNotifications;
        _permission = permission;
      });
    }
    if (kDebugMode) await _refreshDiagnostics();
  }

  Future<void> _refreshDiagnostics() async {
    if (_updatingDiagnostics) return;
    if (mounted) setState(() => _updatingDiagnostics = true);
    try {
      final diagnostics = await widget.notificationService.diagnostics();
      if (mounted) setState(() => _diagnostics = diagnostics);
    } on Object {
      // The inspector is diagnostic-only and must never affect the inbox.
    } finally {
      if (mounted) setState(() => _updatingDiagnostics = false);
    }
  }

  Future<void> _runDiagnosticAction(Future<void> Function() action) async {
    if (_updatingDiagnostics) return;
    setState(() => _updatingDiagnostics = true);
    try {
      await action();
    } on Object {
      if (mounted) {
        BebeInAppSnackbar.show(
          context,
          message: 'La acción de diagnóstico no se pudo completar.',
          variant: BebeInAppSnackbarVariant.error,
        );
      }
    } finally {
      if (mounted) setState(() => _updatingDiagnostics = false);
    }
    await _refreshDiagnostics();
  }

  Future<void> _requestPermission() async {
    if (_requestingPermission) {
      return;
    }
    setState(() => _requestingPermission = true);
    try {
      final permission = await widget.notificationService.requestPermission();
      if (mounted) {
        setState(() => _permission = permission);
      }
    } on Object {
      if (mounted) {
        BebeInAppSnackbar.show(
          context,
          message: 'No pudimos activar las notificaciones.',
          variant: BebeInAppSnackbarVariant.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _requestingPermission = false);
      }
    }
  }

  Future<void> _openSettings() async {
    final opened = await widget.notificationService.openNotificationSettings();
    if (!opened && mounted) {
      BebeInAppSnackbar.show(
        context,
        message: 'No pudimos abrir la configuración del dispositivo.',
        variant: BebeInAppSnackbarVariant.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: widget.onBackPressed == null
            ? null
            : IconButton(
                tooltip: 'Volver',
                onPressed: widget.onBackPressed,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              tooltip: 'Limpiar notificaciones',
              onPressed: widget.notificationService.clearAll,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (_permission != null &&
                _permission != NotificationPermissionState.granted)
              SliverToBoxAdapter(
                child: _PermissionBanner(
                  permission: _permission!,
                  isLoading: _requestingPermission,
                  onPressed: _permission!.requiresSettings
                      ? _openSettings
                      : _requestPermission,
                ),
              ),
            if (kDebugMode)
              SliverToBoxAdapter(
                child: _NotificationInspector(
                  diagnostics: _diagnostics,
                  isLoading: _updatingDiagnostics,
                  onRefresh: _refreshDiagnostics,
                  onReconcile: () => _runDiagnosticAction(
                    widget.notificationService.reconcileReminders,
                  ),
                  onTest: () => _runDiagnosticAction(
                    widget.notificationService.scheduleTestReminder,
                  ),
                  onCancelAll: () => _runDiagnosticAction(
                    widget.notificationService.cancelAllScheduledReminders,
                  ),
                ),
              ),
            if (_notifications.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyNotifications(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _NotificationCard(
                    _notifications[index],
                    onPressed: (notification) =>
                        unawaited(_openNotification(notification)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNotification(AppNotification notification) async {
    await widget.notificationService.markOpened(notification);
    if (mounted) widget.onNotificationPressed?.call(notification);
  }
}

class _NotificationInspector extends StatelessWidget {
  const _NotificationInspector({
    required this.diagnostics,
    required this.isLoading,
    required this.onRefresh,
    required this.onReconcile,
    required this.onTest,
    required this.onCancelAll,
  });

  final NotificationDiagnostics? diagnostics;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onReconcile;
  final VoidCallback onTest;
  final VoidCallback onCancelAll;

  @override
  Widget build(BuildContext context) {
    final data = diagnostics;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: ExpansionTile(
        leading: const Icon(Icons.bug_report_outlined),
        title: const Text('Notification Inspector · DEBUG'),
        subtitle: Text(
          data == null
              ? (isLoading ? 'Leyendo estado…' : 'Estado no disponible')
              : '${data.pendingNativeCount} nativas · ${data.reminders.length} persistidas',
        ),
        trailing: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                tooltip: 'Actualizar diagnóstico',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (data != null) ...[
            _DiagnosticRow('Permiso', data.permission.name),
            _DiagnosticRow('Zona horaria', data.timeZone),
            _DiagnosticRow(
              'Alarmas exactas',
              switch (data.canScheduleExactAlarms) {
                true => 'Disponibles',
                false => 'Bloqueadas; se usará modo aproximado',
                null => 'No aplica / no disponible',
              },
            ),
            _DiagnosticRow(
              'Token FCM',
              data.hasRegisteredFcmToken ? 'Registrado' : 'No registrado',
            ),
            if (data.lastError != null)
              _DiagnosticRow('Último error', data.lastError!),
            for (final reminder in data.reminders.take(5))
              _DiagnosticRow(
                reminder.channelId,
                '${reminder.title} · ${_diagnosticDate(reminder.scheduledAt)}\n'
                    'payload: ${reminder.payload}',
              ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: isLoading ? null : onReconcile,
                child: const Text('Reconciliar'),
              ),
              OutlinedButton(
                onPressed: isLoading ? null : onTest,
                child: const Text('Probar +10 s'),
              ),
              TextButton(
                onPressed: isLoading ? null : onCancelAll,
                child: const Text('Cancelar programadas'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _diagnosticDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.permission,
    required this.isLoading,
    required this.onPressed,
  });

  final NotificationPermissionState permission;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.notifications_off_outlined),
            const SizedBox(width: 12),
            if (permission.requiresSettings)
              const Expanded(
                child: Text(
                  'Las notificaciones están bloqueadas. Actívalas desde la configuración del dispositivo.',
                ),
              )
            else
              const Expanded(
                child: Text(
                  'Activa los avisos para recibir recordatorios y novedades del círculo de cuidado.',
                ),
              ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: isLoading ? null : onPressed,
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      permission.requiresSettings
                          ? 'Abrir configuración'
                          : 'Activar',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Todo al día',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí aparecerán las alertas y recordatorios que reciba BebéApp.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard(this.notification, {this.onPressed});

  final AppNotification notification;
  final ValueChanged<AppNotification>? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: notification.route == null || onPressed == null
            ? null
            : () => onPressed!(notification),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child: Icon(
            notification.wasOpened
                ? Icons.notifications_outlined
                : Icons.notifications_active_outlined,
          ),
        ),
        title: Text(notification.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.body),
              const SizedBox(height: 6),
              Text(
                _formatReceivedAt(notification.receivedAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        trailing: notification.route == null
            ? null
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  String _formatReceivedAt(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} · $hour:$minute';
  }
}
