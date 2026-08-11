import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:notifications/notifications.dart';

import '../dependencies/dependencies.dart';
import '../router/startup_route_mapper.dart';

final appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppListeners extends StatefulWidget {
  const AppListeners({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AppListeners> createState() => _AppListenersState();
}

class _AppListenersState extends State<AppListeners> {
  StreamSubscription<AppNotification>? _openedNotificationSubscription;
  StreamSubscription<List<AppNotification>>? _notificationSubscription;
  int _knownNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    final service = getIt<NotificationService>();
    _knownNotificationCount = service.currentNotifications.length;
    _openedNotificationSubscription = service.openedNotifications.listen(
      _openNotification,
    );
    _notificationSubscription = service.notifications.listen((items) {
      if (items.length > _knownNotificationCount && items.isNotEmpty) {
        final notification = items.first;
        final messenger = appScaffoldMessengerKey.currentState;
        if (messenger != null) {
          BebeInAppSnackbar.showOn(
            messenger,
            title: notification.title,
            message: notification.body,
            variant: _snackbarVariant(notification),
            actionLabel: 'Ver',
            onActionPressed: () => _openNotification(notification),
          );
        }
      }
      _knownNotificationCount = items.length;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = service.takePendingOpenedNotification();
      if (pending != null) {
        _openNotification(pending);
      }
    });
  }

  void _openNotification(AppNotification notification) {
    getIt<GoRouter>().go(notification.route ?? '/notifications');
  }

  @override
  void dispose() {
    unawaited(_openedNotificationSubscription?.cancel());
    unawaited(_notificationSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (previous, current) =>
          previous is SessionAuthenticated && current is SessionUnauthenticated,
      listener: (_, __) => getIt<GoRouter>().go(StartupPaths.login),
      child: widget.child,
    );
  }
}

BebeInAppSnackbarVariant _snackbarVariant(AppNotification notification) =>
    switch (notification.data['status']) {
      'accepted' => BebeInAppSnackbarVariant.success,
      'rejected' || 'revoked' => BebeInAppSnackbarVariant.warning,
      _ => BebeInAppSnackbarVariant.information,
    };
