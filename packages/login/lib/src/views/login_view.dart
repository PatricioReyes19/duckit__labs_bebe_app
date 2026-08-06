import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/login_cubit.dart';
import '../bloc/login_state.dart';

class LoginView extends StatelessWidget {
  const LoginView({
    required this.onAuthenticated,
    required this.onBackPressed,
    required this.onSignUpPressed,
    required this.invitationPending,
    super.key,
  });

  final VoidCallback onAuthenticated;
  final VoidCallback onBackPressed;
  final VoidCallback onSignUpPressed;
  final bool invitationPending;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return PopScope<Object?>(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          onBackPressed();
        }
      },
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == LoginSubmissionStatus.success,
        listener: (_, __) => onAuthenticated(),
        child: Scaffold(
          backgroundColor: colors.background.neutralsPage,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: BackButton(onPressed: onBackPressed),
            title: const Text('Iniciar sesión'),
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      return AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              child: BebeBrandMark(size: 72),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              invitationPending
                                  ? 'Primero, identifica tu cuenta'
                                  : 'Qué bueno verte de nuevo',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: colors.text.neutralHeadline,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              invitationPending
                                  ? 'Inicia sesión con el correo que recibió la invitación.'
                                  : 'Ingresa para volver a tu círculo de cuidado.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: colors.text.neutralBody,
                                  ),
                            ),
                            const SizedBox(height: 32),
                            if (state.message != null) ...[
                              _MessageBanner(
                                message: state.message!,
                                icon: Icons.error_outline_rounded,
                                color: colors.text.errorDefault,
                                background: colors.background.errorSurface,
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (state.resetEmailSent) ...[
                              _MessageBanner(
                                message:
                                    'Revisa tu correo. Te enviamos instrucciones para recuperar el acceso.',
                                icon: Icons.mark_email_read_outlined,
                                color: colors.text.successDefault,
                                background: colors.background.successSurface,
                              ),
                              const SizedBox(height: 16),
                            ],
                            BebeTextField(
                              key: const Key('login_email'),
                              label: 'Usuario o correo electrónico',
                              hintText: 'bypass',
                              errorText: state.emailError,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              leading: const Icon(Icons.person_outline_rounded),
                              onChanged:
                                  context.read<LoginCubit>().emailChanged,
                            ),
                            const SizedBox(height: 16),
                            BebeTextField(
                              key: const Key('login_password'),
                              label: 'Contraseña',
                              errorText: state.passwordError,
                              obscureText: state.obscurePassword,
                              textInputAction: TextInputAction.done,
                              leading: const Icon(Icons.lock_outline_rounded),
                              trailing: IconButton(
                                tooltip: state.obscurePassword
                                    ? 'Mostrar contraseña'
                                    : 'Ocultar contraseña',
                                onPressed: context
                                    .read<LoginCubit>()
                                    .passwordVisibilityToggled,
                                icon: Icon(
                                  state.obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              onChanged:
                                  context.read<LoginCubit>().passwordChanged,
                              onSubmitted: (_) =>
                                  context.read<LoginCubit>().submitted(),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: state.isSubmitting
                                    ? null
                                    : context
                                        .read<LoginCubit>()
                                        .passwordResetRequested,
                                child: const Text('¿Olvidaste tu contraseña?'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            BebeButton(
                              key: const Key('login_submit'),
                              label: 'Iniciar sesión',
                              isLoading: state.isSubmitting,
                              leading: const Icon(Icons.login_rounded),
                              onPressed: state.isSubmitting
                                  ? null
                                  : context.read<LoginCubit>().submitted,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿Aún no tienes cuenta?',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: onSignUpPressed,
                                  child: const Text('Crear cuenta'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 18,
                                  color: colors.icons.brandDefault,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Tu información está protegida.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colors.text.neutralCaption,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String message;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
