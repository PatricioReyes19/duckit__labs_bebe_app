import 'dart:async';

import 'package:app_base/src/dependencies/dependencies.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notifications/notifications.dart';

import '../notifications/notification_reminder_coordinator.dart';

class AppLifecycleObserver extends StatefulWidget {
  const AppLifecycleObserver({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AppLifecycleObserver> createState() {
    return _AppLifecycleObserverState();
  }
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _wasBackgrounded = true;

      case AppLifecycleState.resumed:
        if (_wasBackgrounded) {
          _wasBackgrounded = false;

          context.read<SessionBloc>().add(
                const SessionResumed(),
              );
          unawaited(_refreshSynchronizedData());
        }

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return widget.child;
  }
}

Future<void> _refreshSynchronizedData() async {
  try {
    await getIt<InitialDataSyncCoordinator>().synchronize(
      startRealtime: getIt<SupabaseRealtimeSyncCoordinator>().start,
    );
  } on Object catch (error, stackTrace) {
    debugPrint('Lifecycle data synchronization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
  try {
    final notifications = getIt<NotificationService>();
    // A transient platform/Firebase failure during cold start must not disable
    // local alarms for the whole process lifetime. initialize() is idempotent
    // and now retries safely when the app returns to foreground.
    await notifications.initialize();
    await notifications.refreshInbox();
    await NotificationReminderCoordinator(
      notificationService: notifications,
      getCurrentSession: getIt<GetCurrentSession>(),
    ).reconcileDomainReminders(
      activeContextRepository: getIt<ActiveContextRepository>(),
      getAgendaOverview: getIt<GetAgendaOverview>(),
      getHealthOverview: getIt<GetHealthOverview>(),
    );
  } on Object catch (error, stackTrace) {
    debugPrint('Lifecycle notification refresh failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
