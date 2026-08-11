import 'dart:async';

import 'package:design_system/design_system.dart';
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
  bool _requestingPermission = false;

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
            if (_permission == NotificationPermissionState.denied ||
                _permission == NotificationPermissionState.notDetermined)
              SliverToBoxAdapter(
                child: _PermissionBanner(
                  isLoading: _requestingPermission,
                  onPressed: _requestPermission,
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
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _NotificationCard(
                    _notifications[index],
                    onPressed: widget.onNotificationPressed,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.isLoading, required this.onPressed});

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
                  : const Text('Activar'),
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
