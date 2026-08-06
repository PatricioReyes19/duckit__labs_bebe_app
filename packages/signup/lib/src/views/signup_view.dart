import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/signup_cubit.dart';
import '../bloc/signup_state.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({
    required this.onAccountCreated,
    required this.onBackPressed,
    required this.onLoginPressed,
    required this.invitationPending,
    super.key,
  });

  final VoidCallback onAccountCreated;
  final VoidCallback onBackPressed;
  final VoidCallback onLoginPressed;
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
      child: BlocListener<SignUpCubit, SignUpState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == SignUpSubmissionStatus.success,
        listener: (_, __) => onAccountCreated(),
        child: Scaffold(
          backgroundColor: colors.background.neutralsPage,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: BackButton(onPressed: onBackPressed),
            title: const Text('Crear cuenta'),
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: BlocBuilder<SignUpCubit, SignUpState>(
                    builder: (context, state) {
                      return AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(child: BebeBrandMark(size: 68)),
                            const SizedBox(height: 20),
                            Text(
                              invitationPending
                                  ? 'Crea tu cuenta para continuar'
                                  : 'Bienvenido a BebéApp',
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
                                  ? 'Usa el mismo correo al que enviaron la invitación.'
                                  : 'Unos pasos simples para comenzar a cuidar lo que más importa.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: colors.text.neutralBody,
                                  ),
                            ),
                            const SizedBox(height: 28),
                            if (state.message != null) ...[
                              _ErrorBanner(message: state.message!),
                              const SizedBox(height: 16),
                            ],
                            BebeTextField(
                              key: const Key('signup_name'),
                              label: 'Nombre',
                              hintText: 'Ej. María Fernández',
                              errorText: state.displayNameError,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              leading: const Icon(Icons.person_outline_rounded),
                              onChanged: context
                                  .read<SignUpCubit>()
                                  .displayNameChanged,
                            ),
                            const SizedBox(height: 16),
                            BebeTextField(
                              key: const Key('signup_email'),
                              label: 'Correo electrónico',
                              hintText: 'nombre@correo.com',
                              errorText: state.emailError,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              leading: const Icon(Icons.mail_outline_rounded),
                              onChanged:
                                  context.read<SignUpCubit>().emailChanged,
                            ),
                            const SizedBox(height: 16),
                            BebeTextField(
                              key: const Key('signup_password'),
                              label: 'Contraseña',
                              helperText: 'Mínimo 8 caracteres.',
                              errorText: state.passwordError,
                              obscureText: state.obscurePassword,
                              textInputAction: TextInputAction.done,
                              leading: const Icon(Icons.lock_outline_rounded),
                              trailing: IconButton(
                                tooltip: state.obscurePassword
                                    ? 'Mostrar contraseña'
                                    : 'Ocultar contraseña',
                                onPressed: context
                                    .read<SignUpCubit>()
                                    .passwordVisibilityToggled,
                                icon: Icon(
                                  state.obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              onChanged:
                                  context.read<SignUpCubit>().passwordChanged,
                              onSubmitted: (_) =>
                                  context.read<SignUpCubit>().submitted(),
                            ),
                            const SizedBox(height: 16),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: state.termsError == null
                                    ? Colors.transparent
                                    : colors.background.errorSurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CheckboxListTile(
                                key: const Key('signup_terms'),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: state.acceptedTerms,
                                onChanged: state.isSubmitting
                                    ? null
                                    : (value) => context
                                        .read<SignUpCubit>()
                                        .termsChanged(value ?? false),
                                title: const Text(
                                  'Acepto los Términos y condiciones y la Política de privacidad.',
                                ),
                                subtitle: state.termsError == null
                                    ? null
                                    : Text(
                                        state.termsError!,
                                        style: TextStyle(
                                          color: colors.text.errorDefault,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            BebeButton(
                              key: const Key('signup_submit'),
                              label: 'Crear cuenta',
                              isLoading: state.isSubmitting,
                              leading:
                                  const Icon(Icons.person_add_alt_1_rounded),
                              onPressed: state.isSubmitting
                                  ? null
                                  : context.read<SignUpCubit>().submitted,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿Ya tienes cuenta?',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: onLoginPressed,
                                  child: const Text('Inicia sesión'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                    'Usamos cifrado y buenas prácticas para cuidar tus datos.',
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.errorSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.icons.errorDefault),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.text.errorDefault),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
