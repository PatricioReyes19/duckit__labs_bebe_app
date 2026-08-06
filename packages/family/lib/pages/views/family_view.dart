import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:family/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FamilyView extends StatelessWidget {
  const FamilyView({
    this.onFamilyContextPressed,
    this.onAddBabyPressed,
    this.onManageCareCirclePressed,
    this.onInviteCaregiverPressed,
    this.onFamilySettingsPressed,
    this.onMemberPressed,
    super.key,
  });

  final VoidCallback? onFamilyContextPressed;
  final VoidCallback? onAddBabyPressed;
  final VoidCallback? onManageCareCirclePressed;
  final VoidCallback? onInviteCaregiverPressed;
  final VoidCallback? onFamilySettingsPressed;
  final ValueChanged<String>? onMemberPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyBloc, FamilyState>(
      builder: (context, state) {
        return switch (state) {
          FamilyInitial() || FamilyLoading() => const _FamilyLoading(),
          FamilyFailure(:final message) => _FamilyError(
            message: message,
            onRetry: () =>
                context.read<FamilyBloc>().add(const FamilyEvent.retried()),
          ),
          FamilyLoaded(:final overview) => _FamilyContent(
            overview: overview,
            onFamilyContextPressed: onFamilyContextPressed,
            onAddBabyPressed: onAddBabyPressed,
            onManageCareCirclePressed: onManageCareCirclePressed,
            onInviteCaregiverPressed: onInviteCaregiverPressed,
            onFamilySettingsPressed: onFamilySettingsPressed,
            onMemberPressed: onMemberPressed,
          ),
        };
      },
    );
  }
}

class _FamilyContent extends StatelessWidget {
  const _FamilyContent({
    required this.overview,
    this.onFamilyContextPressed,
    this.onAddBabyPressed,
    this.onManageCareCirclePressed,
    this.onInviteCaregiverPressed,
    this.onFamilySettingsPressed,
    this.onMemberPressed,
  });

  final FamilyOverviewVm overview;
  final VoidCallback? onFamilyContextPressed;
  final VoidCallback? onAddBabyPressed;
  final VoidCallback? onManageCareCirclePressed;
  final VoidCallback? onInviteCaregiverPressed;
  final VoidCallback? onFamilySettingsPressed;
  final ValueChanged<String>? onMemberPressed;

  @override
  Widget build(BuildContext context) {
    final activeBaby = overview.activeBaby;
    final bloc = context.read<FamilyBloc>();

    return BebeFamilyOverviewTemplate(
      familyContext: BebeFamilyContextHeader(
        familyName: overview.familyName,
        babyName: activeBaby.name,
        babyAge: activeBaby.ageLabel,
        supportingText: '${overview.babies.length} bebés en este núcleo',
        avatar: _FamilyAvatar(
          initials: activeBaby.initials,
          variant: activeBaby.avatarVariant,
        ),
        onContextPressed: onFamilyContextPressed ?? _emptyCallback,
      ),
      familySummary: _FamilySummary(overview: overview),
      babiesSection: BebeBabyProfilesSection(
        title: 'Bebés',
        trailing: BebeInlineAction(
          label: 'Agregar',
          onPressed: onAddBabyPressed ?? _emptyCallback,
          icon: const Icon(Icons.add_rounded),
        ),
        children: [
          for (final baby in overview.babies)
            BebeBabyProfileCard(
              name: baby.name,
              supportingText: [
                baby.ageLabel,
                if (baby.id == overview.activeBabyId) 'Bebé activo',
              ].join(' · '),
              avatar: _FamilyAvatar(
                initials: baby.initials,
                variant: baby.avatarVariant,
              ),
              isActive: baby.id == overview.activeBabyId,
              onPressed: () => bloc.add(FamilyEvent.babySelected(baby.id)),
            ),
        ],
      ),
      careCircleSection: BebeCareCircleSection(
        title: 'Círculo de cuidado',
        trailing: BebeInlineAction(
          label: 'Gestionar',
          onPressed: onManageCareCirclePressed ?? _emptyCallback,
          icon: const Icon(Icons.settings_outlined),
        ),
        children: [
          for (final member in overview.members)
            BebeCareCircleMemberRow(
              name: member.name,
              role: member.role,
              accessDescription: member.accessDescription,
              status: member.status == FamilyMemberStatus.pending
                  ? BebeCareCircleMemberStatus.pending
                  : BebeCareCircleMemberStatus.active,
              avatar: _FamilyAvatar(
                initials: member.initials,
                variant: member.avatarVariant,
              ),
              onPressed: () => onMemberPressed?.call(member.id),
            ),
        ],
      ),
      familyActions: _FamilyActions(
        onInviteCaregiverPressed: onInviteCaregiverPressed,
        onFamilySettingsPressed: onFamilySettingsPressed,
      ),
    );
  }
}

class _FamilySummary extends StatelessWidget {
  const _FamilySummary({required this.overview});

  final FamilyOverviewVm overview;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final activeMembers = overview.members.where(
      (member) => member.status == FamilyMemberStatus.active,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BebeTitleSection(title: 'Resumen familiar'),
        SizedBox(height: spacing.spacingL),
        BebeFamilySummary(
          minimumItemWidth: 140,
          maximumColumnCount: 3,
          children: [
            BebeFamilyMetricCard(
              value: '${overview.babies.length}',
              label: 'bebés',
              icon: const Icon(Icons.child_care_outlined),
              variant: BebeFamilyMetricCardVariant.brand,
              onPressed: _emptyCallback,
            ),
            BebeFamilyMetricCard(
              value: '${activeMembers.length}',
              label: 'cuidadores',
              icon: const Icon(Icons.groups_2_outlined),
              variant: BebeFamilyMetricCardVariant.accent,
              onPressed: _emptyCallback,
            ),
            BebeFamilyMetricCard(
              value: '${overview.pendingInvitations}',
              label: overview.pendingInvitations == 1
                  ? 'invitación pendiente'
                  : 'invitaciones pendientes',
              icon: const Icon(Icons.mail_outline_rounded),
              variant: BebeFamilyMetricCardVariant.warning,
              onPressed: _emptyCallback,
            ),
          ],
        ),
      ],
    );
  }
}

class _FamilyActions extends StatelessWidget {
  const _FamilyActions({
    this.onInviteCaregiverPressed,
    this.onFamilySettingsPressed,
  });

  final VoidCallback? onInviteCaregiverPressed;
  final VoidCallback? onFamilySettingsPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeDetailActionCard(
          title: 'Invitar cuidador',
          description: 'Agrega a alguien a tu círculo de cuidado',
          icon: const Icon(Icons.group_add_outlined),
          variant: BebeDetailActionCardVariant.brand,
          onPressed: onInviteCaregiverPressed ?? _emptyCallback,
        ),
        SizedBox(height: spacing.spacingM),
        BebeDetailActionCard(
          title: 'Configuración del núcleo',
          description: 'Miembros, permisos e invitaciones',
          icon: const Icon(Icons.settings_outlined),
          variant: BebeDetailActionCardVariant.neutral,
          onPressed: onFamilySettingsPressed ?? _emptyCallback,
        ),
      ],
    );
  }
}

class _FamilyAvatar extends StatelessWidget {
  const _FamilyAvatar({required this.initials, required this.variant});

  final String initials;
  final FamilyAvatarVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final palette = switch (variant) {
      FamilyAvatarVariant.brand => (
        background: theme.colors.background.brandSurface,
        foreground: theme.colors.text.brandDefault,
        border: theme.colors.border.brandAlternative,
      ),
      FamilyAvatarVariant.accent => (
        background: theme.colors.background.accentSurface,
        foreground: theme.colors.text.accentDefault,
        border: theme.colors.border.accentAlternative,
      ),
      FamilyAvatarVariant.information => (
        background: theme.colors.background.infoSurface,
        foreground: theme.colors.text.infoDefault,
        border: theme.colors.border.infoDefault,
      ),
      FamilyAvatarVariant.warning => (
        background: theme.colors.background.warningSurface,
        foreground: theme.colors.text.warningDefault,
        border: theme.colors.border.warningDefault,
      ),
    };

    return Semantics(
      image: true,
      label: 'Avatar $initials',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.background,
          shape: BoxShape.circle,
          border: Border.all(color: palette.border),
        ),
        child: Center(
          child: Text(
            initials,
            style: theme.typography.styles.title.sm.semibold.copyWith(
              color: palette.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _FamilyLoading extends StatelessWidget {
  const _FamilyLoading();

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return BebeFamilyOverviewTemplate(
      familyContext: const _FamilySkeleton(height: 112),
      familySummary: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FamilySkeleton(height: 28),
          SizedBox(height: spacing.spacingL),
          const _FamilySkeleton(height: 120),
        ],
      ),
      babiesSection: const _FamilySkeleton(height: 220),
      careCircleSection: const _FamilySkeleton(height: 320),
      familyActions: const _FamilySkeleton(height: 210),
    );
  }
}

class _FamilyError extends StatelessWidget {
  const _FamilyError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SizedBox(
      height: 420,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group_off_outlined,
                size: 44,
                color: theme.colors.icons.errorDefault,
              ),
              SizedBox(height: theme.spacing.spacingL),
              Text(
                'No pudimos cargar Familia',
                textAlign: TextAlign.center,
                style: theme.typography.styles.title.md.semibold.copyWith(
                  color: theme.colors.text.neutralTitle,
                ),
              ),
              SizedBox(height: theme.spacing.spacingS),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.typography.styles.body.md.regular.copyWith(
                  color: theme.colors.text.neutralBody,
                ),
              ),
              SizedBox(height: theme.spacing.spacingXl),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilySkeleton extends StatelessWidget {
  const _FamilySkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background.neutralsActive,
          borderRadius: BorderRadius.circular(theme.borderRadius.radius3xl),
          border: Border.all(color: theme.colors.border.neutralDefault),
        ),
      ),
    );
  }
}

void _emptyCallback() {}
