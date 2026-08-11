import 'dart:async';

import 'package:app_base/src/dependencies/dependencies.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notifications/notifications.dart';

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
          unawaited(getIt<RegisterEventSyncService>().synchronize());
          unawaited(getIt<AgendaEventSyncService>().synchronize());
          unawaited(getIt<HealthEventSyncService>().synchronize());
          unawaited(getIt<AppSettingsSyncService>().synchronize());
          unawaited(getIt<FamilySyncService>().synchronize());
          unawaited(_refreshProfileAndInbox());
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

Future<void> _refreshProfileAndInbox() async {
  try {
    final session = await getIt<GetCurrentSession>()();
    if (session != null) {
      await getIt<ProfileRemoteDataSource>().syncAuthenticatedUser(
        session.user,
      );
    }
  } on Object {
    // Profile sync is retried on the next authentication or app resume.
  }
  await getIt<NotificationService>().refreshInbox();
}
