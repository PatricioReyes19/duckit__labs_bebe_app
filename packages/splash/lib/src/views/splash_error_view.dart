import 'package:flutter/material.dart';

import '../widgets/splash_background_decoration.dart';

class SplashErrorView extends StatelessWidget {
  const SplashErrorView({
    required this.message,
    required this.canRetry,
    required this.onRetryPressed,
    super.key,
  });

  final String message;
  final bool canRetry;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SplashBackgroundDecoration(
      introProgress: 1,
      ambientProgress: 0,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 52,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No pudimos iniciar',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (canRetry) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onRetryPressed,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
