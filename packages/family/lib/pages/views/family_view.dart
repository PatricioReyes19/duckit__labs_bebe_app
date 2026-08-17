import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
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
    this.onPersonalSettingsPressed,
    this.onBabyPressed,
    this.onMemberPressed,
    this.initialSyncState = const SyncUxState.pending(),
    this.syncStates,
    this.onRetrySync,
    super.key,
  });

  final VoidCallback? onFamilyContextPressed;
  final VoidCallback? onAddBabyPressed;
  final VoidCallback? onManageCareCirclePressed;
  final VoidCallback? onInviteCaregiverPressed;
  final VoidCallback? onFamilySettingsPressed;
  final VoidCallback? onPersonalSettingsPressed;
  final ValueChanged<String>? onBabyPressed;
  final ValueChanged<String>? onMemberPressed;
  final SyncUxState initialSyncState;
  final Stream<SyncUxState>? syncStates;
  final Future<void> Function()? onRetrySync;

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
            onPersonalSettingsPressed: onPersonalSettingsPressed,
            onBabyPressed: onBabyPressed,
            onMemberPressed: onMemberPressed,
            initialSyncState: initialSyncState,
            syncStates: syncStates,
            onRetrySync: onRetrySync,
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
    this.onPersonalSettingsPressed,
    this.onBabyPressed,
    this.onMemberPressed,
    required this.initialSyncState,
    this.syncStates,
    this.onRetrySync,
  });

  final FamilyOverviewVm overview;
  final VoidCallback? onFamilyContextPressed;
  final VoidCallback? onAddBabyPressed;
  final VoidCallback? onManageCareCirclePressed;
  final VoidCallback? onInviteCaregiverPressed;
  final VoidCallback? onFamilySettingsPressed;
  final VoidCallback? onPersonalSettingsPressed;
  final ValueChanged<String>? onBabyPressed;
  final ValueChanged<String>? onMemberPressed;
  final SyncUxState initialSyncState;
  final Stream<SyncUxState>? syncStates;
  final Future<void> Function()? onRetrySync;

  @override
  Widget build(BuildContext context) {
    final activeBaby = overview.activeBaby;
    final secondaryBabies = overview.babies
        .where((baby) => baby.id != overview.activeBabyId)
        .toList(growable: false);
    final bloc = context.read<FamilyBloc>();

    return BebeFamilyOverviewTemplate(
      onRefresh: () async {
        final completed = bloc.stream.firstWhere(
          (state) => state is FamilyLoaded || state is FamilyFailure,
        );
        bloc.add(const FamilyEvent.retried());
        await completed;
      },
      familyContext: BebeFamilyContextHeader(
        familyName: overview.familyName,
        babyName: activeBaby.name,
        babyAge: activeBaby.ageLabel,
        supportingText: '${overview.babies.length} bebés en la familia',
        showFamilyName: false,
        avatar: _FamilyAvatar(
          initials: activeBaby.initials,
          variant: activeBaby.avatarVariant,
          imagePath: activeBaby.avatarPath,
        ),
        onContextPressed: onFamilyContextPressed ?? _emptyCallback,
        secondaryContext: secondaryBabies.isEmpty
            ? null
            : BebeBabySelector(
                name: secondaryBabies.first.name,
                ageLabel: secondaryBabies.first.ageLabel,
                avatar: SizedBox.square(
                  dimension: 32,
                  child: _FamilyAvatar(
                    initials: secondaryBabies.first.initials,
                    variant: secondaryBabies.first.avatarVariant,
                    imagePath: secondaryBabies.first.avatarPath,
                  ),
                ),
                isSelected: false,
                compact: true,
                showTrailing: false,
                onPressed: () => bloc.add(
                  FamilyEvent.babySelected(secondaryBabies.first.id),
                ),
              ),
      ),
      familySummary: _FamilySummary(overview: overview),
      babiesSection: BebeBabyProfilesSection(
        title: 'Bebés',
        minimumItemWidth: 136,
        maximumColumnCount: 2,
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
                imagePath: baby.avatarPath,
              ),
              isActive: baby.id == overview.activeBabyId,
              onPressed: () => onBabyPressed?.call(baby.id),
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
      familyActions: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder<SyncUxState>(
            initialData: initialSyncState,
            stream: syncStates,
            builder: (context, snapshot) => FamilySyncStatusSection(
              state: snapshot.data ?? initialSyncState,
              onRetry: onRetrySync == null
                  ? null
                  : () => unawaited(onRetrySync!()),
            ),
          ),
          SizedBox(height: context.theme.spacing.spacing2xl),
          _FamilyActions(
            onInviteCaregiverPressed: onInviteCaregiverPressed,
            onFamilySettingsPressed: onFamilySettingsPressed,
            onPersonalSettingsPressed: onPersonalSettingsPressed,
          ),
        ],
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
        const BebeTitleSection(title: 'Mi familia'),
        SizedBox(height: spacing.spacingL),
        BebeFamilySummary(
          minimumItemWidth: 88,
          maximumColumnCount: 3,
          children: [
            BebeFamilyMetricCard(
              value: '${overview.babies.length}',
              label: 'bebés',
              icon: const Icon(Icons.child_care_outlined),
              variant: BebeFamilyMetricCardVariant.brand,
            ),
            BebeFamilyMetricCard(
              value: '${activeMembers.length}',
              label: 'cuidadores',
              icon: const Icon(Icons.groups_2_outlined),
              variant: BebeFamilyMetricCardVariant.accent,
            ),
            BebeFamilyMetricCard(
              value: '${overview.pendingInvitations}',
              label: overview.pendingInvitations == 1
                  ? 'invitación'
                  : 'invitaciones',
              semanticLabel:
                  '${overview.pendingInvitations} invitaciones pendientes',
              icon: const Icon(Icons.mail_outline_rounded),
              variant: BebeFamilyMetricCardVariant.warning,
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
    this.onPersonalSettingsPressed,
  });

  final VoidCallback? onInviteCaregiverPressed;
  final VoidCallback? onFamilySettingsPressed;
  final VoidCallback? onPersonalSettingsPressed;

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
          title: 'Configuración familiar',
          description: 'Reglas, permisos e invitaciones del núcleo',
          icon: const Icon(Icons.settings_outlined),
          variant: BebeDetailActionCardVariant.neutral,
          onPressed: onFamilySettingsPressed ?? _emptyCallback,
        ),
        SizedBox(height: spacing.spacingM),
        BebeDetailActionCard(
          title: 'Mi cuenta y preferencias',
          description: 'Perfil personal, tema, privacidad y sesión',
          icon: const Icon(Icons.manage_accounts_outlined),
          variant: BebeDetailActionCardVariant.accent,
          onPressed: onPersonalSettingsPressed ?? _emptyCallback,
        ),
      ],
    );
  }
}

class _FamilyAvatar extends StatelessWidget {
  const _FamilyAvatar({
    required this.initials,
    required this.variant,
    this.imagePath,
  });

  final String initials;
  final FamilyAvatarVariant variant;
  final String? imagePath;

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
        child: imagePath != null && File(imagePath!).existsSync()
            ? ClipOval(child: Image.file(File(imagePath!), fit: BoxFit.cover))
            : Center(
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
    return BebeSkeleton(height: height);
  }
}

void _emptyCallback() {}
