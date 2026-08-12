import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'notification_message.dart';
import 'notification_service.dart';

/// Header action that keeps the unread inbox state visible across app routes.
class NotificationInboxButton extends StatelessWidget {
  const NotificationInboxButton({
    required this.notificationService,
    required this.onPressed,
    super.key,
  });

  final NotificationService notificationService;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: notificationService.notifications,
      initialData: notificationService.currentNotifications,
      builder: (context, snapshot) {
        final unreadCount = (snapshot.data ?? const <AppNotification>[])
            .where((notification) => !notification.wasOpened)
            .length;
        return Semantics(
          button: true,
          label: unreadCount == 0
              ? 'Notificaciones'
              : 'Notificaciones, $unreadCount sin leer',
          child: IconButton(
            tooltip: unreadCount == 0
                ? 'Notificaciones'
                : '$unreadCount notificaciones sin leer',
            onPressed: onPressed,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  unreadCount == 0
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_rounded,
                ),
                if (unreadCount > 0)
                  const Positioned(
                    top: -1,
                    right: -1,
                    child: BebeIndicatorDot(
                      variant: IndicatorDotVariant.warning,
                      size: IndicatorDotSize.medium,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
