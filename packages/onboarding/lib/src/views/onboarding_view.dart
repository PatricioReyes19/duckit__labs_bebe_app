import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';
import '../models/models.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({
    required this.entry,
    required this.onCompleted,
    required this.onExitRequested,
    required this.onUseAnotherAccount,
    super.key,
  });

  final OnboardingEntry entry;
  final VoidCallback onCompleted;
  final VoidCallback onExitRequested;
  final VoidCallback onUseAnotherAccount;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        void onBack() => _handleBack(context, state);
        final child = switch (state.step) {
          OnboardingStep.choice => const _ChoiceView(),
          OnboardingStep.invitationCode => _InvitationCodeView(onBack: onBack),
          OnboardingStep.invitationReview =>
            _InvitationReviewView(onBack: onBack),
          OnboardingStep.invitationInvalid => _InvitationInvalidView(
              onBack: onBack,
              onCompleted: onCompleted,
              onUseAnotherAccount: onUseAnotherAccount,
            ),
          OnboardingStep.babyProfile => _BabyProfileView(onBack: onBack),
          OnboardingStep.babyCreated => _CompletionView(
              babyName: state.createdBaby?.name ?? state.babyName,
              title: '¡Perfil creado con éxito!',
              description:
                  'El perfil de tu bebé ya está listo. Ahora puedes comenzar a registrar sus momentos.',
              icon: Icons.child_care_rounded,
              onCompleted: onCompleted,
            ),
          OnboardingStep.invitationAccepted => _CompletionView(
              babyName: state.invitation?.babyName ?? 'tu familia',
              title: '¡Ya eres parte del círculo!',
              description:
                  'La invitación fue aceptada. Ya puedes acompañar y registrar los cuidados compartidos.',
              icon: Icons.family_restroom_rounded,
              onCompleted: onCompleted,
            ),
          OnboardingStep.invitationDeclined => _InvitationDeclinedView(
              babyName: state.invitation?.babyName ?? 'este bebé',
              onContinue: context.read<OnboardingCubit>().backToChoice,
            ),
        };

        return PopScope<Object?>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              onBack();
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(key: ValueKey(state.step), child: child),
          ),
        );
      },
    );
  }

  void _handleBack(BuildContext context, OnboardingState state) {
    final cubit = context.read<OnboardingCubit>();
    switch (state.step) {
      case OnboardingStep.choice:
        onExitRequested();
      case OnboardingStep.invitationCode:
        if (entry == OnboardingEntry.invitation) {
          onExitRequested();
        } else {
          cubit.backToChoice();
        }
      case OnboardingStep.invitationReview:
      case OnboardingStep.invitationInvalid:
        cubit.retryInvitation();
      case OnboardingStep.babyProfile:
        if (entry == OnboardingEntry.babyProfile) {
          onExitRequested();
        } else {
          cubit.backToChoice();
        }
      case OnboardingStep.babyCreated:
      case OnboardingStep.invitationAccepted:
        onCompleted();
      case OnboardingStep.invitationDeclined:
        cubit.backToChoice();
    }
  }
}

class _ChoiceView extends StatelessWidget {
  const _ChoiceView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return _FlowScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandHeader(),
          const SizedBox(height: 34),
          const _HeroIcon(
            icon: Icons.favorite_rounded,
            palette: _HeroPalette.brand,
          ),
          const SizedBox(height: 24),
          Text(
            '¿Cómo quieres comenzar?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.theme.colors.text.neutralHeadline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige la opción que mejor se adapte a tu situación actual.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.theme.colors.text.neutralBody,
                ),
          ),
          const SizedBox(height: 34),
          _ChoiceCard(
            key: const Key('onboarding_create_baby'),
            title: 'Crear perfil de un bebé',
            description: 'Crea un perfil nuevo y tu círculo de cuidado.',
            icon: Icons.child_care_rounded,
            accent: context.theme.colors.icons.brandDefault,
            surface: context.theme.colors.background.brandSurface,
            onTap: cubit.createBabySelected,
          ),
          const SizedBox(height: 18),
          _ChoiceCard(
            key: const Key('onboarding_join_invitation'),
            title: 'Unirme mediante una invitación',
            description:
                'Ingresa el código o abre la invitación que recibiste.',
            icon: Icons.mark_email_unread_outlined,
            accent: context.theme.colors.icons.accentDefault,
            surface: context.theme.colors.background.accentSurface,
            onTap: cubit.invitationSelected,
          ),
          const SizedBox(height: 24),
          _InfoStrip(
            icon: Icons.shield_outlined,
            text:
                'Tu información está segura. Solo pediremos lo esencial para comenzar.',
            color: context.theme.colors.text.infoDefault,
            background: context.theme.colors.background.infoSurface,
          ),
        ],
      ),
    );
  }
}

class _InvitationCodeView extends StatelessWidget {
  const _InvitationCodeView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingCubit>().state;
    final cubit = context.read<OnboardingCubit>();
    return _FlowScaffold(
      appBar: _FlowAppBar(
        title: 'Usar invitación',
        onBack: onBack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const _HeroIcon(
            icon: Icons.mail_outline_rounded,
            palette: _HeroPalette.accent,
          ),
          const SizedBox(height: 24),
          Text(
            'Ingresa tu invitación',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.theme.colors.text.neutralHeadline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Encontrarás el código en el mensaje que te envió la persona cuidadora.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.theme.colors.text.neutralBody,
                ),
          ),
          const SizedBox(height: 32),
          if (state.message != null) ...[
            _InfoStrip(
              icon: Icons.error_outline_rounded,
              text: state.message!,
              color: context.theme.colors.text.errorDefault,
              background: context.theme.colors.background.errorSurface,
            ),
            const SizedBox(height: 16),
          ],
          BebeTextField(
            key: const Key('invitation_code'),
            label: 'Código de invitación',
            hintText: 'Ej. MATEO2026',
            errorText: state.invitationCodeError,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            leading: const Icon(Icons.vpn_key_outlined),
            onChanged: cubit.invitationCodeChanged,
            onSubmitted: (_) => cubit.invitationSubmitted(),
          ),
          const SizedBox(height: 12),
          Text(
            'El código no distingue entre mayúsculas y minúsculas.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.theme.colors.text.neutralCaption,
                ),
          ),
          const SizedBox(height: 28),
          BebeButton(
            key: const Key('invitation_submit'),
            label: 'Revisar invitación',
            isLoading: state.isLoading,
            leading: const Icon(Icons.search_rounded),
            onPressed: state.isLoading ? null : cubit.invitationSubmitted,
          ),
          const SizedBox(height: 20),
          _InfoStrip(
            icon: Icons.info_outline_rounded,
            text:
                'Antes de aceptar podrás ver quién te invita, a qué bebé y el alcance de tu acceso.',
            color: context.theme.colors.text.infoDefault,
            background: context.theme.colors.background.infoSurface,
          ),
        ],
      ),
    );
  }
}

class _InvitationReviewView extends StatelessWidget {
  const _InvitationReviewView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingCubit>().state;
    final invitation = state.invitation!;
    final cubit = context.read<OnboardingCubit>();
    final colors = context.theme.colors;

    return _FlowScaffold(
      appBar: _FlowAppBar(
        title: 'Invitación recibida',
        onBack: onBack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const _HeroIcon(
            icon: Icons.mark_email_unread_rounded,
            palette: _HeroPalette.accent,
            badge: true,
          ),
          const SizedBox(height: 20),
          Text(
            '¡Tienes una invitación a un círculo de cuidado!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.text.neutralHeadline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revisa los detalles antes de decidir.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.text.neutralBody,
                ),
          ),
          const SizedBox(height: 24),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background.neutralsSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border.neutralDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _PersonRow(
                    icon: Icons.person_rounded,
                    eyebrow: 'Te invita',
                    title: invitation.inviterName,
                    trailing: invitation.inviterRelationship,
                  ),
                  const Divider(height: 32),
                  _PersonRow(
                    icon: Icons.child_care_rounded,
                    eyebrow: 'Bebé al que te unirás',
                    title: invitation.babyName,
                    trailing: invitation.babyAgeLabel,
                  ),
                  const Divider(height: 32),
                  _PermissionsList(invitation: invitation),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _InfoStrip(
            icon: Icons.workspace_premium_outlined,
            text:
                'Esta invitación tiene prioridad sobre crear otro perfil. Puedes rechazarla antes de continuar.',
            color: colors.text.accentDefault,
            background: colors.background.accentSurface,
          ),
          if (state.message != null) ...[
            const SizedBox(height: 14),
            _InfoStrip(
              icon: Icons.error_outline_rounded,
              text: state.message!,
              color: colors.text.errorDefault,
              background: colors.background.errorSurface,
            ),
          ],
          const SizedBox(height: 22),
          BebeButton(
            key: const Key('invitation_accept'),
            label: 'Aceptar invitación',
            leading: const Icon(Icons.check_circle_outline_rounded),
            isLoading: state.isLoading,
            onPressed: state.isLoading ? null : cubit.invitationAccepted,
          ),
          const SizedBox(height: 10),
          BebeButton(
            key: const Key('invitation_decline'),
            label: 'Rechazar invitación',
            variant: BebeButtonVariant.text,
            leading: const Icon(Icons.cancel_outlined),
            onPressed: state.isLoading
                ? null
                : () => _confirmInvitationDecline(context, cubit),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmInvitationDecline(
  BuildContext context,
  OnboardingCubit cubit,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('¿Rechazar invitación?'),
      content: const Text(
        'No te unirás al círculo de cuidado. Si cambias de opinión, necesitarás una invitación vigente.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Sí, rechazar'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await cubit.invitationDeclined();
  }
}

class _InvitationDeclinedView extends StatelessWidget {
  const _InvitationDeclinedView({
    required this.babyName,
    required this.onContinue,
  });

  final String babyName;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => _FlowScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BrandHeader(),
            const SizedBox(height: 40),
            const _HeroIcon(
              icon: Icons.mark_email_read_outlined,
              palette: _HeroPalette.warning,
            ),
            const SizedBox(height: 24),
            Text(
              'Invitación rechazada',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'No te uniste al círculo de $babyName. Puedes crear un perfil o usar otra invitación.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            BebeButton(
              label: 'Elegir otra opción',
              leading: const Icon(Icons.arrow_forward_rounded),
              onPressed: onContinue,
            ),
          ],
        ),
      );
}

class _InvitationInvalidView extends StatelessWidget {
  const _InvitationInvalidView({
    required this.onBack,
    required this.onCompleted,
    required this.onUseAnotherAccount,
  });

  final VoidCallback onBack;
  final VoidCallback onCompleted;
  final VoidCallback onUseAnotherAccount;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final reason = context.watch<OnboardingCubit>().state.invitationFailure ??
        InvitationFailureReason.notFound;
    final content = _invalidContent(reason);
    final colors = context.theme.colors;

    return _FlowScaffold(
      appBar: _FlowAppBar(
        title: 'Revisar invitación',
        onBack: onBack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          _HeroIcon(icon: content.icon, palette: content.palette),
          const SizedBox(height: 28),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.text.neutralHeadline,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.text.neutralBody,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 30),
          _InfoStrip(
            icon: Icons.lightbulb_outline_rounded,
            text: content.hint,
            color: content.palette == _HeroPalette.warning
                ? colors.text.warningDefault
                : colors.text.infoDefault,
            background: content.palette == _HeroPalette.warning
                ? colors.background.warningSurface
                : colors.background.infoSurface,
          ),
          const SizedBox(height: 28),
          BebeButton(
            label: content.actionLabel,
            leading: Icon(content.actionIcon),
            onPressed: switch (reason) {
              InvitationFailureReason.wrongAccount => onUseAnotherAccount,
              InvitationFailureReason.alreadyMember => onCompleted,
              _ => cubit.retryInvitation,
            },
          ),
          const SizedBox(height: 12),
          BebeButton(
            label: 'Volver a elegir cómo comenzar',
            variant: BebeButtonVariant.text,
            onPressed: cubit.backToChoice,
          ),
        ],
      ),
    );
  }

  _InvalidContent _invalidContent(InvitationFailureReason reason) {
    return switch (reason) {
      InvitationFailureReason.expired => const _InvalidContent(
          title: 'Invitación expirada',
          description: 'Esta invitación ya venció y no se puede usar.',
          hint:
              'Las invitaciones caducan para proteger la seguridad de tu familia.',
          actionLabel: 'Ingresar otro código',
          actionIcon: Icons.refresh_rounded,
          icon: Icons.hourglass_bottom_rounded,
          palette: _HeroPalette.accent,
        ),
      InvitationFailureReason.revoked => const _InvalidContent(
          title: 'Invitación revocada',
          description: 'La persona que envió la invitación la canceló.',
          hint:
              'Puedes pedirle una nueva invitación si crees que fue un error.',
          actionLabel: 'Ingresar otro código',
          actionIcon: Icons.refresh_rounded,
          icon: Icons.block_rounded,
          palette: _HeroPalette.error,
        ),
      InvitationFailureReason.wrongAccount => const _InvalidContent(
          title: 'Cuenta incorrecta',
          description:
              'Esta invitación no corresponde a la cuenta con la que iniciaste sesión.',
          hint: 'Usa el mismo correo al que fue enviada la invitación.',
          actionLabel: 'Intentar con otra cuenta',
          actionIcon: Icons.switch_account_outlined,
          icon: Icons.person_off_outlined,
          palette: _HeroPalette.warning,
        ),
      InvitationFailureReason.alreadyMember => const _InvalidContent(
          title: 'Acceso ya existente',
          description: 'Ya formas parte de este círculo de cuidado.',
          hint: 'Puedes continuar directamente desde tu cuenta.',
          actionLabel: 'Ir al Inicio',
          actionIcon: Icons.home_outlined,
          icon: Icons.verified_rounded,
          palette: _HeroPalette.brand,
        ),
      InvitationFailureReason.notFound => const _InvalidContent(
          title: 'No encontramos la invitación',
          description:
              'Revisa que el código esté completo y vuelve a intentarlo.',
          hint:
              'Si abriste un enlace antiguo, pide a la persona cuidadora uno nuevo.',
          actionLabel: 'Revisar el código',
          actionIcon: Icons.edit_outlined,
          icon: Icons.search_off_rounded,
          palette: _HeroPalette.warning,
        ),
    };
  }
}

class _InvalidContent {
  const _InvalidContent({
    required this.title,
    required this.description,
    required this.hint,
    required this.actionLabel,
    required this.actionIcon,
    required this.icon,
    required this.palette,
  });

  final String title;
  final String description;
  final String hint;
  final String actionLabel;
  final IconData actionIcon;
  final IconData icon;
  final _HeroPalette palette;
}

class _BabyProfileView extends StatelessWidget {
  const _BabyProfileView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final state = context.watch<OnboardingCubit>().state;
    final colors = context.theme.colors;

    return _FlowScaffold(
      appBar: _FlowAppBar(
        title: 'Crear perfil del bebé',
        onBack: onBack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: 1,
              color: colors.background.brandDefault,
              backgroundColor: colors.background.neutralsDisabled,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Información esencial',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.text.neutralCaption,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cuéntanos sobre tu bebé',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.text.neutralHeadline,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Solo pedimos lo necesario para personalizar el cuidado.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.text.neutralBody,
                ),
          ),
          const SizedBox(height: 24),
          if (state.message != null) ...[
            _InfoStrip(
              icon: Icons.error_outline_rounded,
              text: state.message!,
              color: colors.text.errorDefault,
              background: colors.background.errorSurface,
            ),
            const SizedBox(height: 16),
          ],
          BebeTextField(
            key: const Key('baby_name'),
            label: 'Nombre',
            hintText: 'Ej. Mateo',
            errorText: state.babyNameError,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            leading: const Icon(Icons.child_care_rounded),
            onChanged: cubit.babyNameChanged,
          ),
          const SizedBox(height: 18),
          Text(
            'Fecha de nacimiento',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.text.neutralLabel,
                ),
          ),
          const SizedBox(height: 8),
          _DateField(
            value: state.birthDate,
            errorText: state.birthDateError,
            onChanged: cubit.birthDateChanged,
          ),
          const SizedBox(height: 22),
          Text(
            'Foto (opcional)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.text.neutralLabel,
                ),
          ),
          const SizedBox(height: 8),
          Material(
            color: colors.background.accentSurface,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const Key('baby_photo_picker'),
              onTap:
                  state.isLoading ? null : () => _pickBabyPhoto(context, cubit),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border.accentAlternative),
                ),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 64,
                      child: ClipOval(
                        child: state.babyPhotoPath == null
                            ? ColoredBox(
                                color: colors.background.neutralsSurface,
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: colors.icons.accentDefault,
                                ),
                              )
                            : Image.file(
                                File(state.babyPhotoPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => ColoredBox(
                                  color: colors.background.neutralsSurface,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: colors.icons.errorDefault,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.babyPhotoPath == null
                                ? 'Agregar foto'
                                : 'Cambiar foto',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            state.babyPhotoPath == null
                                ? 'Elige una imagen de tu galería.'
                                : 'La foto se guardará de forma privada en este dispositivo.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colors.text.neutralCaption),
                          ),
                        ],
                      ),
                    ),
                    if (state.babyPhotoPath != null)
                      IconButton(
                        tooltip: 'Quitar foto',
                        onPressed: () => cubit.babyPhotoChanged(null),
                        icon: const Icon(Icons.close_rounded),
                      )
                    else
                      const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sexo de referencia para crecimiento',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.text.neutralLabel,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ReferenceOption(
                  label: 'Masculino',
                  icon: Icons.male_rounded,
                  selected: state.sexReference == SexReference.male,
                  onTap: () => cubit.sexReferenceChanged(SexReference.male),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReferenceOption(
                  label: 'Femenino',
                  icon: Icons.female_rounded,
                  selected: state.sexReference == SexReference.female,
                  onTap: () => cubit.sexReferenceChanged(SexReference.female),
                ),
              ),
            ],
          ),
          if (state.sexReferenceError != null) ...[
            const SizedBox(height: 8),
            Text(
              state.sexReferenceError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.text.errorDefault,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          _InfoStrip(
            icon: Icons.info_outline_rounded,
            text:
                'Se usa únicamente como referencia para mostrar curvas de crecimiento adecuadas. No define la identidad de tu bebé.',
            color: colors.text.infoDefault,
            background: colors.background.infoSurface,
          ),
          const SizedBox(height: 26),
          BebeButton(
            key: const Key('baby_submit'),
            label: 'Guardar y continuar',
            isLoading: state.isLoading,
            leading: const Icon(Icons.check_rounded),
            onPressed: state.isLoading ? null : cubit.babySubmitted,
          ),
        ],
      ),
    );
  }
}

Future<void> _pickBabyPhoto(
  BuildContext context,
  OnboardingCubit cubit,
) async {
  try {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (photo != null) cubit.babyPhotoChanged(photo.path);
  } on Object {
    if (!context.mounted) return;
    BebeInAppSnackbar.show(
      context,
      message: 'No pudimos abrir la galería. Revisa los permisos.',
      variant: BebeInAppSnackbarVariant.error,
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({
    required this.babyName,
    required this.title,
    required this.description,
    required this.icon,
    required this.onCompleted,
  });

  final String babyName;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return _FlowScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandHeader(),
          const SizedBox(height: 36),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colors.background.brandSurface,
                      colors.background.accentSurface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, size: 102, color: colors.icons.brandDefault),
              ),
              Positioned(
                right: 46,
                top: 10,
                child: CircleAvatar(
                  radius: 29,
                  backgroundColor: colors.background.successDefault,
                  child: const Icon(Icons.check_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.text.brandDefault,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.text.neutralBody,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 26),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background.neutralsSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border.neutralDefault),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: colors.background.brandSurface,
                    child: Icon(icon, color: colors.icons.brandDefault),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          babyName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.text.neutralTitle,
                                  ),
                        ),
                        Text(
                          'Círculo de cuidado activo',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.text.neutralCaption,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_rounded,
                      color: colors.icons.successDefault),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          BebeButton(
            key: const Key('onboarding_complete'),
            label: 'Ir al Inicio',
            leading: const Icon(Icons.home_rounded),
            onPressed: onCompleted,
          ),
          const SizedBox(height: 12),
          BebeButton(
            label: 'Invitar cuidador más tarde',
            variant: BebeButtonVariant.text,
            leading: const Icon(Icons.group_add_outlined),
            onPressed: onCompleted,
          ),
          const SizedBox(height: 18),
          _InfoStrip(
            icon: Icons.info_outline_rounded,
            text:
                'Podrás invitar a otras personas en cualquier momento desde la sección Familia.',
            color: colors.text.infoDefault,
            background: colors.background.infoSurface,
          ),
        ],
      ),
    );
  }
}

class _FlowScaffold extends StatelessWidget {
  const _FlowScaffold({required this.child, this.appBar});

  final Widget child;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Scaffold(
      backgroundColor: colors.background.neutralsPage,
      appBar: appBar,
      body: Stack(
        children: [
          Positioned(
            right: -64,
            top: 80,
            child: _SoftCircle(
              color: colors.background.brandSurface,
              size: 180,
            ),
          ),
          Positioned(
            left: -80,
            bottom: 40,
            child: _SoftCircle(
              color: colors.background.accentSurface,
              size: 200,
            ),
          ),
          SafeArea(
            top: appBar == null,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _FlowAppBar extends AppBar {
  _FlowAppBar({required String title, required VoidCallback onBack})
      : super(
          title: Text(title),
          centerTitle: true,
          leading: IconButton(
            tooltip: 'Volver',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const BebeBrandMark(size: 46),
        const SizedBox(width: 10),
        Text(
          'BebéApp',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.text.brandDefault,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

enum _HeroPalette { brand, accent, warning, error }

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({
    required this.icon,
    required this.palette,
    this.badge = false,
  });

  final IconData icon;
  final _HeroPalette palette;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final foreground = switch (palette) {
      _HeroPalette.brand => colors.icons.brandDefault,
      _HeroPalette.accent => colors.icons.accentDefault,
      _HeroPalette.warning => colors.icons.warningDefault,
      _HeroPalette.error => colors.icons.errorDefault,
    };
    final background = switch (palette) {
      _HeroPalette.brand => colors.background.brandSurface,
      _HeroPalette.accent => colors.background.accentSurface,
      _HeroPalette.warning => colors.background.warningSurface,
      _HeroPalette.error => colors.background.errorSurface,
    };

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(color: foreground.withValues(alpha: 0.16)),
            ),
            child: Icon(icon, size: 52, color: foreground),
          ),
          if (badge)
            Positioned(
              right: -2,
              top: -4,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: colors.background.errorDefault,
                child: const Text(
                  '1',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.surface,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Semantics(
      button: true,
      label: '$title. $description',
      child: Material(
        color: colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(minHeight: 136),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent.withValues(alpha: 0.24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 42, color: accent),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.text.neutralBody,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String text;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: colors.background.brandSurface,
          child: Icon(icon, color: colors.icons.brandDefault),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.text.neutralCaption,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.background.accentSurface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            trailing,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.text.accentDefault,
                ),
          ),
        ),
      ],
    );
  }
}

class _PermissionsList extends StatelessWidget {
  const _PermissionsList({required this.invitation});

  final CareInvitation invitation;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invitation.canWrite ? 'Lo que podrás hacer' : 'Tu acceso',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.text.brandDefault,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        for (final label in [
          'Ver historial y línea de tiempo',
          if (invitation.canWrite)
            'Registrar alimentación, sueño, pañal y medicación',
          'Recibir avisos importantes',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 19,
                  color: colors.icons.successDefault,
                ),
                const SizedBox(width: 9),
                Expanded(child: Text(label)),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Text(
          invitation.canWrite
              ? '${invitation.accessDescription}. No podrás gestionar miembros ni eliminar información.'
              : '${invitation.accessDescription}. No podrás registrar ni modificar información.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.text.warningDefault,
              ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  final DateTime? value;
  final String? errorText;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final formatted = value == null
        ? 'DD / MM / AAAA'
        : '${value!.day.toString().padLeft(2, '0')} / '
            '${value!.month.toString().padLeft(2, '0')} / ${value!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: colors.background.neutralsSurface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            key: const Key('baby_birth_date'),
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final now = DateTime.now();
              final date = await showDatePicker(
                context: context,
                initialDate:
                    value ?? DateTime(now.year - 1, now.month, now.day),
                firstDate: DateTime(now.year - 15),
                lastDate: now,
                helpText: 'Fecha de nacimiento',
                cancelText: 'Cancelar',
                confirmText: 'Seleccionar',
              );
              if (date != null) {
                onChanged(date);
              }
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 58),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: errorText == null
                      ? colors.border.neutralDefault
                      : colors.border.errorDefault,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: colors.icons.brandDefault,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatted,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: value == null
                                ? colors.text.neutralDisabled
                                : colors.text.neutralBody,
                          ),
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.text.errorDefault,
                ),
          ),
        ],
      ],
    );
  }
}

class _ReferenceOption extends StatelessWidget {
  const _ReferenceOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final accent = colors.icons.brandDefault;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? colors.background.brandSurface
            : colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: selected ? 2 : 1,
                color: selected ? accent : colors.border.neutralDefault,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: accent),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? accent : colors.text.neutralBody,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
