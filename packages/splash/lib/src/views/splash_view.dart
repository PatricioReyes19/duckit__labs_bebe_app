import 'package:core/startup.dart';
import 'package:design_system/tokens/bebe_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/splash_bloc.dart';
import 'splash_auth_entry.dart';
import 'splash_brand_intro.dart';
import 'splash_error_view.dart';

typedef SplashDestinationCallback = void Function(
  BuildContext context,
  EntryDestination destination,
);

class SplashView extends StatefulWidget {
  const SplashView({
    required this.onDestinationResolved,
    required this.onInvitationAccessRequested,
    super.key,
  });

  final SplashDestinationCallback onDestinationResolved;
  final VoidCallback onInvitationAccessRequested;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  EntryDestination? _pendingDestination;
  bool _introCompleted = false;
  bool _isExiting = false;
  bool _didNavigate = false;

  void _handleState(BuildContext context, SplashState state) {
    if (state case SplashRouteRequested(:final destination)) {
      _pendingDestination = destination;
      _beginExitIfReady();
    }
  }

  void _handleIntroCompleted() {
    _introCompleted = true;
    _beginExitIfReady();
  }

  void _beginExitIfReady() {
    if (!mounted ||
        !_introCompleted ||
        _pendingDestination == null ||
        _isExiting ||
        _didNavigate) {
      return;
    }

    setState(() => _isExiting = true);
  }

  void _handleExitCompleted() {
    final destination = _pendingDestination;
    if (!_isExiting || _didNavigate || destination == null) {
      return;
    }

    _didNavigate = true;
    widget.onDestinationResolved(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final transitionDuration = Duration(
      milliseconds: reduceMotion ? 120 : 210,
    );

    return BlocConsumer<SplashBloc, SplashState>(
      listenWhen: (_, current) => current is SplashRouteRequested,
      listener: _handleState,
      builder: (context, state) {
        final child = switch (state) {
          SplashResolving() || SplashRouteRequested() => AnimatedOpacity(
              key: const ValueKey('splash-brand-intro'),
              opacity: _isExiting ? 0 : 1,
              duration: transitionDuration,
              curve: Curves.easeInOut,
              onEnd: _handleExitCompleted,
              child: SplashBrandIntro(
                onIntroCompleted: _handleIntroCompleted,
              ),
            ),
          SplashAuthEntryState() => SplashAuthEntry(
              key: const ValueKey('splash-auth-entry'),
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
              onInvitationPressed: widget.onInvitationAccessRequested,
            ),
          SplashFailure(
            :final message,
            :final canRetry,
          ) =>
            SplashErrorView(
              key: ValueKey('splash-error-$message-$canRetry'),
              message: message,
              canRetry: canRetry,
              onRetryPressed: () {
                context.read<SplashBloc>().add(
                      const SplashEvent.retried(),
                    );
              },
            ),
        };

        return Scaffold(
          backgroundColor:
              Theme.of(context).extension<BebeColor>()!.background.splash,
          body: AnimatedSwitcher(
            duration: transitionDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: child,
          ),
        );
      },
    );
  }
}
