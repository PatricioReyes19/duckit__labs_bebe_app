import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:notifications/notifications.dart';

import '../dependencies/dependencies.dart';
import '../notifications/notification_navigation_guard.dart';
import '../router/startup_route_mapper.dart';
import '../startup/startup.dart';

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
    unawaited(openNotificationSafely(notification));
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
      listener: (_, __) => unawaited(_closeAccountStorageAndOpenLogin()),
      child: widget.child,
    );
  }
}

Future<void> openNotificationSafely(AppNotification notification) async {
  final guard = NotificationNavigationGuard(
    getCurrentSession: getIt<GetCurrentSession>().call,
    restoreAuthenticatedContext: (user) =>
        getIt<AuthenticatedStartupCoordinator>().resolve(user: user),
    readAvailableFamilies: getIt<SqliteFamilyRepository>().listAvailable,
    activateBaby: (babyId) async {
      await getIt<SqliteFamilyRepository>().setActiveBaby(babyId);
    },
    activeContextRepository: getIt<ActiveContextRepository>(),
  );
  final route = await guard.resolve(notification);
  getIt<GoRouter>().go(route);
}

Future<void> _closeAccountStorageAndOpenLogin() async {
  try {
    await getIt<BebeDatabase>().close();
  } on Object {
    // La sesión ya no es válida; la navegación pública no debe bloquearse.
  }
  getIt<GoRouter>().go(StartupPaths.login);
}

BebeInAppSnackbarVariant _snackbarVariant(AppNotification notification) =>
    switch (notification.data['status']) {
      'accepted' => BebeInAppSnackbarVariant.success,
      'rejected' || 'revoked' => BebeInAppSnackbarVariant.warning,
      _ => BebeInAppSnackbarVariant.information,
    };
