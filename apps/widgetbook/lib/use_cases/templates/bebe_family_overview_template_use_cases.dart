import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Completo', type: BebeFamilyOverviewTemplate)
Widget bebeFamilyOverviewTemplateCompleteUseCase(BuildContext context) =>
    const _FamilyTemplateFrame(child: _CompleteFamilyTemplatePreview());

@widgetbook.UseCase(name: 'Contenido mínimo', type: BebeFamilyOverviewTemplate)
Widget bebeFamilyOverviewTemplateMinimumUseCase(BuildContext context) =>
    const _FamilyTemplateFrame(child: _MinimumFamilyTemplatePreview());

@widgetbook.UseCase(name: 'Miembro pendiente', type: BebeFamilyOverviewTemplate)
Widget bebeFamilyOverviewTemplatePendingInvitationUseCase(
        BuildContext context) =>
    const _FamilyTemplateFrame(
        child: _PendingInvitationFamilyTemplatePreview());

@widgetbook.UseCase(name: 'Ancho reducido', type: BebeFamilyOverviewTemplate)
Widget bebeFamilyOverviewTemplateCompactUseCase(BuildContext context) =>
    const _FamilyTemplateFrame(
        maximumWidth: 390, child: _CompleteFamilyTemplatePreview());

class _FamilyTemplateFrame extends StatelessWidget {
  const _FamilyTemplateFrame({required this.child, this.maximumWidth = 720});
  final Widget child;
  final double maximumWidth;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    return SingleChildScrollView(
      padding:
          EdgeInsets.only(top: spacing.spacingL, bottom: spacing.spacing3xl),
      child: Center(
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maximumWidth),
              child: child)),
    );
  }
}

class _CompleteFamilyTemplatePreview extends StatelessWidget {
  const _CompleteFamilyTemplatePreview();
  @override
  Widget build(BuildContext context) => const BebeFamilyOverviewTemplate(
        familyContext: _FamilyContextPreview(),
        familySummary: _FamilySummaryPreview(),
        babiesSection: _BabyProfilesPreview(),
        careCircleSection: _CareCirclePreview(),
        familyActions: _FamilyActionsPreview(),
      );
}

class _MinimumFamilyTemplatePreview extends StatelessWidget {
  const _MinimumFamilyTemplatePreview();
  @override
  Widget build(BuildContext context) => const BebeFamilyOverviewTemplate(
        familyContext: _FamilyContextPreview(),
        familySummary: _FamilySummaryPreview(),
        babiesSection: _SingleBabyProfilesPreview(),
        careCircleSection: _SingleMemberCareCirclePreview(),
      );
}

class _PendingInvitationFamilyTemplatePreview extends StatelessWidget {
  const _PendingInvitationFamilyTemplatePreview();
  @override
  Widget build(BuildContext context) => const BebeFamilyOverviewTemplate(
        familyContext: _FamilyContextPreview(),
        familySummary: _FamilySummaryPreview(),
        babiesSection: _BabyProfilesPreview(),
        careCircleSection: _PendingCareCirclePreview(),
        familyActions: _FamilyActionsPreview(),
      );
}

class _FamilyContextPreview extends StatelessWidget {
  const _FamilyContextPreview();
  @override
  Widget build(BuildContext context) => BebeFamilyContextHeader(
        familyName: 'Familia Reyes González',
        babyName: 'Mateo Reyes',
        babyAge: '2 meses',
        supportingText: '2 bebés en este núcleo',
        avatar: const _AvatarPreview(
            initials: 'MR', variant: _AvatarPreviewVariant.brand),
        onContextPressed: _emptyCallback,
      );
}

class _FamilySummaryPreview extends StatelessWidget {
  const _FamilySummaryPreview();
  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const BebeTitleSection(title: 'Resumen familiar'),
      SizedBox(height: spacing.spacingL),
      BebeFamilySummary(
          minimumItemWidth: 140,
          maximumColumnCount: 3,
          children: [
            BebeFamilyMetricCard(
                value: '2',
                label: 'bebés',
                icon: const Icon(Icons.child_care_outlined),
                variant: BebeFamilyMetricCardVariant.brand,
                onPressed: _emptyCallback),
            BebeFamilyMetricCard(
                value: '3',
                label: 'cuidadores',
                icon: const Icon(Icons.groups_2_outlined),
                variant: BebeFamilyMetricCardVariant.accent,
                onPressed: _emptyCallback),
            BebeFamilyMetricCard(
                value: '1',
                label: 'invitación pendiente',
                icon: const Icon(Icons.mail_outline_rounded),
                variant: BebeFamilyMetricCardVariant.warning,
                onPressed: _emptyCallback),
          ]),
    ]);
  }
}

class _BabyProfilesPreview extends StatelessWidget {
  const _BabyProfilesPreview();
  @override
  Widget build(BuildContext context) => BebeBabyProfilesSection(
        title: 'Bebés',
        trailing: BebeInlineAction(
          label: 'Agregar',
          onPressed: _emptyCallback,
          icon: const Icon(LucideIcons.plus),
        ),
        children: [
          BebeBabyProfileCard(
              name: 'Mateo Reyes',
              supportingText: '2 meses · Bebé activo',
              avatar: const _AvatarPreview(
                  initials: 'MR', variant: _AvatarPreviewVariant.brand),
              isActive: true,
              onPressed: _emptyCallback),
          BebeBabyProfileCard(
              name: 'Sofía Reyes',
              supportingText: '8 meses',
              avatar: const _AvatarPreview(
                  initials: 'SR', variant: _AvatarPreviewVariant.accent),
              onPressed: _emptyCallback),
        ],
      );
}

class _SingleBabyProfilesPreview extends StatelessWidget {
  const _SingleBabyProfilesPreview();
  @override
  Widget build(BuildContext context) => BebeBabyProfilesSection(
        title: 'Bebés',
        children: [
          BebeBabyProfileCard(
              name: 'Mateo Reyes',
              supportingText: '2 meses · Bebé activo',
              avatar: const _AvatarPreview(
                  initials: 'MR', variant: _AvatarPreviewVariant.brand),
              isActive: true,
              onPressed: _emptyCallback),
        ],
      );
}

class _CareCirclePreview extends StatelessWidget {
  const _CareCirclePreview();
  @override
  Widget build(BuildContext context) => BebeCareCircleSection(
        title: 'Círculo de cuidado',
        trailing: BebeInlineAction(
          label: 'Gestionar',
          onPressed: _emptyCallback,
          icon: Icon(LucideIcons.settings),
        ),
        children: [
          BebeCareCircleMemberRow(
              name: 'María López',
              role: 'Mamá',
              accessDescription: 'Puede registrar y ver salud',
              avatar: const _AvatarPreview(
                  initials: 'ML', variant: _AvatarPreviewVariant.brand),
              onPressed: _emptyCallback),
          BebeCareCircleMemberRow(
              name: 'Patricio Reyes',
              role: 'Papá',
              accessDescription: 'Puede registrar y ver salud',
              avatar: const _AvatarPreview(
                  initials: 'PR', variant: _AvatarPreviewVariant.information),
              onPressed: _emptyCallback),
          BebeCareCircleMemberRow(
              name: 'Ana Gómez',
              role: 'Abuela',
              accessDescription: 'Acceso de colaboración',
              avatar: const _AvatarPreview(
                  initials: 'AG', variant: _AvatarPreviewVariant.accent),
              onPressed: _emptyCallback),
        ],
      );
}

class _SingleMemberCareCirclePreview extends StatelessWidget {
  const _SingleMemberCareCirclePreview();
  @override
  Widget build(BuildContext context) => BebeCareCircleSection(
        title: 'Círculo de cuidado',
        children: [
          BebeCareCircleMemberRow(
              name: 'María López',
              role: 'Mamá',
              accessDescription: 'Administradora del núcleo',
              avatar: const _AvatarPreview(
                  initials: 'ML', variant: _AvatarPreviewVariant.brand),
              onPressed: _emptyCallback),
        ],
      );
}

class _PendingCareCirclePreview extends StatelessWidget {
  const _PendingCareCirclePreview();
  @override
  Widget build(BuildContext context) => BebeCareCircleSection(
        title: 'Círculo de cuidado',
        children: [
          BebeCareCircleMemberRow(
              name: 'María López',
              role: 'Mamá',
              accessDescription: 'Puede registrar y ver salud',
              avatar: const _AvatarPreview(
                  initials: 'ML', variant: _AvatarPreviewVariant.brand),
              onPressed: _emptyCallback),
          BebeCareCircleMemberRow(
              name: 'Carolina Soto',
              role: 'Tía',
              accessDescription: 'Invitación pendiente',
              status: BebeCareCircleMemberStatus.pending,
              avatar: const _AvatarPreview(
                  initials: 'CS', variant: _AvatarPreviewVariant.warning),
              onPressed: _emptyCallback),
        ],
      );
}

class _FamilyActionsPreview extends StatelessWidget {
  const _FamilyActionsPreview();
  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      BebeDetailActionCard(
          title: 'Invitar cuidador',
          description: 'Agrega a alguien a tu círculo de cuidado',
          icon: const Icon(Icons.group_add_outlined),
          variant: BebeDetailActionCardVariant.brand,
          onPressed: _emptyCallback),
      SizedBox(height: spacing.spacingM),
      BebeDetailActionCard(
          title: 'Configuración del núcleo',
          description: 'Miembros, permisos e invitaciones',
          icon: const Icon(Icons.settings_outlined),
          variant: BebeDetailActionCardVariant.neutral,
          onPressed: _emptyCallback),
    ]);
  }
}

enum _AvatarPreviewVariant { brand, accent, information, warning }

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.initials, required this.variant});
  final String initials;
  final _AvatarPreviewVariant variant;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography;
    final background = switch (variant) {
      _AvatarPreviewVariant.brand => colors.background.brandSurface,
      _AvatarPreviewVariant.accent => colors.background.accentSurface,
      _AvatarPreviewVariant.information => colors.background.infoSurface,
      _AvatarPreviewVariant.warning => colors.background.warningSurface,
    };
    final foreground = switch (variant) {
      _AvatarPreviewVariant.brand => colors.text.brandDefault,
      _AvatarPreviewVariant.accent => colors.text.accentDefault,
      _AvatarPreviewVariant.information => colors.text.infoDefault,
      _AvatarPreviewVariant.warning => colors.text.warningDefault,
    };
    final border = switch (variant) {
      _AvatarPreviewVariant.brand => colors.border.brandAlternative,
      _AvatarPreviewVariant.accent => colors.border.accentAlternative,
      _AvatarPreviewVariant.information => colors.border.infoDefault,
      _AvatarPreviewVariant.warning => colors.border.warningDefault,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: border)),
      child: Center(
          child: Text(initials,
              style: typography.styles.title.sm.semibold
                  .copyWith(color: foreground))),
    );
  }
}

void _emptyCallback() {}
