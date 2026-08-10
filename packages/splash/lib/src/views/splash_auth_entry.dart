import 'package:flutter/material.dart';

import '../widgets/splash_brand_content.dart';

class SplashAuthEntry extends StatelessWidget {
  const SplashAuthEntry({
    required this.onLoginPressed,
    required this.onSignUpPressed,
    required this.onInvitationPressed,
    super.key,
  });

  final VoidCallback onLoginPressed;
  final VoidCallback onSignUpPressed;
  final VoidCallback onInvitationPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        const SplashBrandContent(),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 42),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Comencemos',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresa a tu núcleo de cuidado o crea una cuenta nueva.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onSignUpPressed,
                            child: const Text('Crear cuenta'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: onLoginPressed,
                            child: const Text('Iniciar sesión'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onInvitationPressed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFC94A4A),
                              side: const BorderSide(color: Color(0xFFE78A8A)),
                            ),
                            icon: const Icon(Icons.mail_outline_rounded),
                            label: const Text('Tengo una invitación'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
