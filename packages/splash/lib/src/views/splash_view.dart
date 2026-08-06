import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/splash_bloc.dart';
import 'splash_auth_entry.dart';
import 'splash_brand_content.dart';
import 'splash_error_view.dart';

typedef SplashDestinationCallback = void Function(
  BuildContext context,
  EntryDestination destination,
);

class SplashView extends StatelessWidget {
  const SplashView({
    required this.onDestinationResolved,
    required this.onInvitationAccessRequested,
    super.key,
  });

  final SplashDestinationCallback onDestinationResolved;
  final VoidCallback onInvitationAccessRequested;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashBloc, SplashState>(
      listenWhen: (_, current) => current is SplashRouteRequested,
      listener: (context, state) {
        if (state case SplashRouteRequested(:final destination)) {
          onDestinationResolved(context, destination);
        }
      },
      builder: (context, state) {
        final child = switch (state) {
          SplashResolving() => const SplashBrandContent(showProgress: true),
          SplashAuthEntryState() => SplashAuthEntry(
              onLoginPressed: () {
                context.read<SplashBloc>().add(
                      const SplashEvent.loginRequested(),
                    );
              },
              onSignUpPressed: () {
                context.read<SplashBloc>().add(
                      const SplashEvent.signUpRequested(),
                    );
              },
              onInvitationPressed: onInvitationAccessRequested,
            ),
          SplashFailure(
            :final message,
            :final canRetry,
          ) =>
            SplashErrorView(
              message: message,
              canRetry: canRetry,
              onRetryPressed: () {
                context.read<SplashBloc>().add(
                      const SplashEvent.retried(),
                    );
              },
            ),
          SplashRouteRequested() =>
            const SplashBrandContent(showProgress: true),
        };

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(state.runtimeType),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
