import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/splash_auth_entry.dart';

typedef SplashAuthEntryAction = void Function(BuildContext context);

/// Selector de acceso independiente de la animación de arranque.
class SplashAuthEntryPage extends GoRoute {
  SplashAuthEntryPage({
    required super.path,
    required SplashAuthEntryAction onLoginPressed,
    required SplashAuthEntryAction onSignUpPressed,
    required SplashAuthEntryAction onInvitationPressed,
    super.name,
    super.parentNavigatorKey,
  }) : super(
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: const ValueKey('splash-auth-entry'),
            name: name ?? nameRoute,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SplashAuthEntry(
                onLoginPressed: () => onLoginPressed(context),
                onSignUpPressed: () => onSignUpPressed(context),
                onInvitationPressed: () => onInvitationPressed(context),
              ),
            ),
          ),
        );

  static const nameRoute = 'Welcome';
}
