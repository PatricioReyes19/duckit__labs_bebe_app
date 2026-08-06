import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/splash_bloc.dart';
import '../views/splash_view.dart';

typedef SplashBlocFactory = SplashBloc Function(BuildContext context);

class SplashPage extends GoRoute {
  SplashPage({
    required SplashBlocFactory splashBloc,
    required SplashDestinationCallback onDestinationResolved,
    required VoidCallbackFactory onInvitationAccessRequested,
    super.name,
  }) : super(
          path: fullPath,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: const ValueKey('splash'),
              name: name ?? nameRoute,
              child: BlocProvider(
                create: splashBloc,
                child: SplashView(
                  onDestinationResolved: onDestinationResolved,
                  onInvitationAccessRequested:
                      onInvitationAccessRequested(context),
                ),
              ),
            );
          },
        );

  static const nameRoute = 'Splash';
  static const fullPath = '/';

  static void open(BuildContext context) {
    context.go(fullPath);
  }
}

typedef VoidCallbackFactory = VoidCallback Function(BuildContext context);
