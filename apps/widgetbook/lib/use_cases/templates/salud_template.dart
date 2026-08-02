import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Completo',
  type: BebeHealthOverviewTemplate,
)
Widget bebeHealthOverviewTemplateCompleteUseCase(
  BuildContext context,
) {
  return const _HealthTemplateFrame(
    child: _CompleteHealthTemplatePreview(),
  );
}

@widgetbook.UseCase(
  name: 'Contenido mínimo',
  type: BebeHealthOverviewTemplate,
)
Widget bebeHealthOverviewTemplateMinimumUseCase(
  BuildContext context,
) {
  return const _HealthTemplateFrame(
    child: _MinimumHealthTemplatePreview(),
  );
}

@widgetbook.UseCase(
  name: 'Sin eventos próximos',
  type: BebeHealthOverviewTemplate,
)
Widget bebeHealthOverviewTemplateEmptyUpcomingUseCase(
  BuildContext context,
) {
  return const _HealthTemplateFrame(
    child: _EmptyUpcomingHealthTemplatePreview(),
  );
}

@widgetbook.UseCase(
  name: 'Eventos próximos cargando',
  type: BebeHealthOverviewTemplate,
)
Widget bebeHealthOverviewTemplateLoadingUpcomingUseCase(
  BuildContext context,
) {
  return const _HealthTemplateFrame(
    child: _LoadingUpcomingHealthTemplatePreview(),
  );
}

@widgetbook.UseCase(
  name: 'Solo contenido principal',
  type: BebeHealthOverviewTemplate,
)
Widget bebeHealthOverviewTemplatePrimaryContentUseCase(
  BuildContext context,
) {
  return const _HealthTemplateFrame(
    child: _PrimaryHealthTemplatePreview(),
  );
}

@widgetbook.UseCase(
  name: 'Ancho reducido',
  type: BebeHealthOverviewTemplate,
)
Widget bebeHealthOverviewTemplateCompactUseCase(
  BuildContext context,
) {
  return const _HealthTemplateFrame(
    maximumWidth: 390,
    child: _CompleteHealthTemplatePreview(),
  );
}

// -----------------------------------------------------------------------------
// FRAME
// -----------------------------------------------------------------------------

class _HealthTemplateFrame extends StatelessWidget {
  const _HealthTemplateFrame({
    required this.child,
    this.maximumWidth = 720,
  });

  final Widget child;
  final double maximumWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: spacing.spacingL,
        bottom: spacing.spacing3xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maximumWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// COMPOSICIONES DEL TEMPLATE
// -----------------------------------------------------------------------------

class _CompleteHealthTemplatePreview extends StatelessWidget {
  const _CompleteHealthTemplatePreview();

  @override
  Widget build(BuildContext context) {
    return const BebeHealthOverviewTemplate(
      primaryActions: _PrimaryHealthActionsPreview(),
      supportAction: _PediatricCarePreview(),
      upcomingHeader: _UpcomingHealthHeaderPreview(),
      upcomingCarousel: _UpcomingHealthCarouselPreview(),
      quickSummary: _QuickHealthSummaryPreview(),
      historyAction: _ClinicalHistoryPreview(),
    );
  }
}

class _MinimumHealthTemplatePreview extends StatelessWidget {
  const _MinimumHealthTemplatePreview();

  @override
  Widget build(BuildContext context) {
    return const BebeHealthOverviewTemplate(
      primaryActions: _PrimaryHealthActionsPreview(),
      upcomingHeader: _UpcomingHealthHeaderPreview(),
      upcomingCarousel: _UpcomingHealthCarouselPreview(),
    );
  }
}

class _EmptyUpcomingHealthTemplatePreview extends StatelessWidget {
  const _EmptyUpcomingHealthTemplatePreview();

  @override
  Widget build(BuildContext context) {
    return const BebeHealthOverviewTemplate(
      primaryActions: _PrimaryHealthActionsPreview(),
      supportAction: _PediatricCarePreview(),
      upcomingHeader: _UpcomingHealthHeaderPreview(),
      upcomingCarousel: _EmptyUpcomingHealthPreview(),
      quickSummary: _QuickHealthSummaryPreview(),
      historyAction: _ClinicalHistoryPreview(),
    );
  }
}

class _LoadingUpcomingHealthTemplatePreview extends StatelessWidget {
  const _LoadingUpcomingHealthTemplatePreview();

  @override
  Widget build(BuildContext context) {
    return const BebeHealthOverviewTemplate(
      primaryActions: _PrimaryHealthActionsPreview(),
      supportAction: _PediatricCarePreview(),
      upcomingHeader: _UpcomingHealthHeaderPreview(
        showAction: false,
      ),
      upcomingCarousel: _LoadingUpcomingHealthPreview(),
      historyAction: _ClinicalHistoryPreview(),
    );
  }
}

class _PrimaryHealthTemplatePreview extends StatelessWidget {
  const _PrimaryHealthTemplatePreview();

  @override
  Widget build(BuildContext context) {
    return const BebeHealthOverviewTemplate(
      primaryActions: _PrimaryHealthActionsPreview(),
      upcomingHeader: _UpcomingHealthHeaderPreview(),
      upcomingCarousel: _UpcomingHealthCarouselPreview(),
    );
  }
}

// -----------------------------------------------------------------------------
// ACCESOS PRINCIPALES
// -----------------------------------------------------------------------------

class _PrimaryHealthActionsPreview extends StatelessWidget {
  const _PrimaryHealthActionsPreview();

  @override
  Widget build(BuildContext context) {
    return FeatureActionGrid(
      minimumItemWidth: 156,
      maximumColumnCount: 2,
      semanticLabel: 'Accesos principales de salud',
      children: [
        BebeFeatureActionCard(
          title: 'Vacunas',
          description: 'Consulta el calendario y vacunas aplicadas',
          icon: const Icon(
            Icons.vaccines_outlined,
          ),
          variant: BebeFeaturedActionCardVariant.brand,
          onPressed: _emptyCallback,
          semanticLabel: 'Vacunas. Consulta el calendario y vacunas aplicadas.',
        ),
        BebeFeatureActionCard(
          title: 'Controles',
          description: 'Seguimiento del desarrollo y la salud',
          icon: const Icon(
            LucideIcons.stethoscope,
          ),
          variant: BebeFeaturedActionCardVariant.accent,
          onPressed: _emptyCallback,
          semanticLabel: 'Controles. Seguimiento del desarrollo y la salud.',
        ),
        BebeFeatureActionCard(
          title: 'Crecimiento',
          description: 'Peso, talla y curvas de crecimiento',
          icon: const Icon(
            Icons.trending_up_rounded,
          ),
          variant: BebeFeaturedActionCardVariant.success,
          onPressed: _emptyCallback,
          semanticLabel: 'Crecimiento. Peso, talla y curvas de crecimiento.',
        ),
        BebeFeatureActionCard(
          title: 'Consultas',
          description: 'Historial médico y recomendaciones',
          icon: const Icon(
            Icons.medical_information_outlined,
          ),
          variant: BebeFeaturedActionCardVariant.warning,
          onPressed: _emptyCallback,
          semanticLabel: 'Consultas. Historial médico y recomendaciones.',
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// PEDIATRAS
// -----------------------------------------------------------------------------

class _PediatricCarePreview extends StatelessWidget {
  const _PediatricCarePreview();

  @override
  Widget build(BuildContext context) {
    return BebeDetailActionCard(
      title: 'Pediatras y atención',
      description: 'Encuentra pediatras, clínicas y atención cercana',
      icon: const Icon(
        Icons.medical_services_outlined,
      ),
      variant: BebeDetailActionCardVariant.information,
      onPressed: _emptyCallback,
      semanticLabel: 'Pediatras y atención. '
          'Encuentra pediatras, clínicas y atención cercana.',
    );
  }
}

// -----------------------------------------------------------------------------
// ENCABEZADO DE PRÓXIMOS EVENTOS
// -----------------------------------------------------------------------------

class _UpcomingHealthHeaderPreview extends StatelessWidget {
  const _UpcomingHealthHeaderPreview({
    this.showAction = true,
  });

  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return BebeTitleSection(
      title: 'Próximos en salud',
      trailing: showAction
          ? BebeInlineAction(
              label: 'Ver agenda',
              onPressed: _emptyCallback,
              icon: const Icon(LucideIcons.calendar),
            )
          : null,
    );
  }
}

// -----------------------------------------------------------------------------
// CARRUSEL
// -----------------------------------------------------------------------------

class _UpcomingHealthCarouselPreview extends StatelessWidget {
  const _UpcomingHealthCarouselPreview();

  @override
  Widget build(BuildContext context) {
    return BebeHorizontalCardCarousel(
      height: 148,
      viewportFraction: 0.88,
      padEnds: false,
      semanticLabel: 'Próximos eventos de salud',
      children: const [
        _HealthVaccineEventPreview(),
        _HealthControlEventPreview(),
        _HealthGrowthEventPreview(),
      ],
    );
  }
}

class _HealthVaccineEventPreview extends StatelessWidget {
  const _HealthVaccineEventPreview();

  @override
  Widget build(BuildContext context) {
    return BebeAgendaEventCard(
      layout: BebeAgendaEventCardLayout.carousel,
      time: const _HealthEventTimePreview(
        date: 'Lun, 26 may',
        time: '10:00 AM',
      ),
      icon: const Icon(
        Icons.vaccines_outlined,
      ),
      title: 'Vacuna Neumococo',
      description: 'Segunda dosis',
      caregiver: const _HealthCaregiverPreview(
        label: 'Mamá',
        variant: _HealthCaregiverVariant.mother,
      ),
      variant: BebeAgendaEventCardVariant.accent,
      onPressed: _emptyCallback,
      semanticLabel: 'Vacuna Neumococo. Segunda dosis. '
          'Lunes 26 de mayo a las diez de la mañana. '
          'Responsable: Mamá.',
    );
  }
}

class _HealthControlEventPreview extends StatelessWidget {
  const _HealthControlEventPreview();

  @override
  Widget build(BuildContext context) {
    return BebeAgendaEventCard(
      layout: BebeAgendaEventCardLayout.carousel,
      time: const _HealthEventTimePreview(
        date: 'Vie, 30 may',
        time: '09:00 AM',
      ),
      icon: const Icon(
        LucideIcons.stethoscope,
      ),
      title: 'Control pediátrico',
      description: 'Chequeo de rutina',
      caregiver: const _HealthCaregiverPreview(
        label: 'Papá',
        variant: _HealthCaregiverVariant.father,
      ),
      variant: BebeAgendaEventCardVariant.information,
      onPressed: _emptyCallback,
      semanticLabel: 'Control pediátrico. Chequeo de rutina. '
          'Viernes 30 de mayo a las nueve de la mañana. '
          'Responsable: Papá.',
    );
  }
}

class _HealthGrowthEventPreview extends StatelessWidget {
  const _HealthGrowthEventPreview();

  @override
  Widget build(BuildContext context) {
    return BebeAgendaEventCard(
      layout: BebeAgendaEventCardLayout.carousel,
      time: const _HealthEventTimePreview(
        date: 'Mar, 3 jun',
        time: '11:30 AM',
      ),
      icon: const Icon(
        Icons.monitor_weight_outlined,
      ),
      title: 'Control de crecimiento',
      description: 'Registro de peso y talla',
      caregiver: const _HealthCaregiverPreview(
        label: 'Mamá',
        variant: _HealthCaregiverVariant.mother,
      ),
      variant: BebeAgendaEventCardVariant.success,
      onPressed: _emptyCallback,
      semanticLabel: 'Control de crecimiento. Registro de peso y talla. '
          'Martes 3 de junio a las once treinta de la mañana. '
          'Responsable: Mamá.',
    );
  }
}

// -----------------------------------------------------------------------------
// ESTADO VACÍO
// -----------------------------------------------------------------------------

class _EmptyUpcomingHealthPreview extends StatelessWidget {
  const _EmptyUpcomingHealthPreview();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;
    final radius = theme.borderRadius;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.spacingL,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background.neutralsSurface,
          borderRadius: BorderRadius.circular(
            radius.radius3xl,
          ),
          border: Border.all(
            color: colors.border.neutralDefault,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 32,
                color: colors.icons.neutralAlternative,
              ),
              SizedBox(height: spacing.spacingM),
              Text(
                'No hay eventos próximos',
                textAlign: TextAlign.center,
                style: typography.styles.title.sm.semibold.copyWith(
                  color: colors.text.neutralTitle,
                ),
              ),
              SizedBox(height: spacing.spacingXs),
              Text(
                'Las próximas vacunas y controles aparecerán aquí.',
                textAlign: TextAlign.center,
                style: typography.styles.body.sm.regular.copyWith(
                  color: colors.text.neutralBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ESTADO LOADING
// -----------------------------------------------------------------------------

class _LoadingUpcomingHealthPreview extends StatelessWidget {
  const _LoadingUpcomingHealthPreview();

  static const double _height = 148;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            width: 0,
          ),
          Expanded(
            flex: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background.neutralsActive,
                borderRadius: BorderRadius.circular(
                  radius.radius3xl,
                ),
                border: Border.all(
                  color: colors.border.neutralDefault,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing.spacingM),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background.neutralsActive,
                borderRadius: BorderRadius.circular(
                  radius.radius3xl,
                ),
                border: Border.all(
                  color: colors.border.neutralDefault,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RESUMEN RÁPIDO
// -----------------------------------------------------------------------------

class _QuickHealthSummaryPreview extends StatelessWidget {
  const _QuickHealthSummaryPreview();

  static const double _summaryCardHeight = 136;
  static const double _minimumCardWidth = 160;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BebeTitleSection(
          title: 'Resumen rápido',
        ),
        SizedBox(height: spacing.spacingL),
        LayoutBuilder(
          builder: (context, constraints) {
            final minimumTwoColumnWidth =
                (_minimumCardWidth * 2) + spacing.spacingM;

            final useSingleColumn =
                constraints.maxWidth < minimumTwoColumnWidth;

            if (useSingleColumn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: _summaryCardHeight,
                    child: _VaccinesSummaryPreview(),
                  ),
                  SizedBox(height: spacing.spacingM),
                  const SizedBox(
                    height: _summaryCardHeight,
                    child: _GrowthSummaryPreview(),
                  ),
                ],
              );
            }

            return SizedBox(
              height: _summaryCardHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    child: _VaccinesSummaryPreview(),
                  ),
                  SizedBox(width: spacing.spacingM),
                  const Expanded(
                    child: _GrowthSummaryPreview(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VaccinesSummaryPreview extends StatelessWidget {
  const _VaccinesSummaryPreview();

  @override
  Widget build(BuildContext context) {
    return BebeDetailActionCard(
      title: 'Vacunas',
      description: '4 al día · 1 pendiente',
      metadata: 'Próxima: Lun, 26 may',
      icon: const Icon(
        Icons.health_and_safety_outlined,
      ),
      variant: BebeDetailActionCardVariant.brand,
      onPressed: _emptyCallback,
      semanticLabel: 'Vacunas. Cuatro al día. Una pendiente. '
          'Próxima: lunes 26 de mayo.',
    );
  }
}

class _GrowthSummaryPreview extends StatelessWidget {
  const _GrowthSummaryPreview();

  @override
  Widget build(BuildContext context) {
    return BebeDetailActionCard(
      title: 'Crecimiento',
      description: '7,25 kg',
      metadata: 'Percentil 41',
      icon: const Icon(
        Icons.monitor_weight_outlined,
      ),
      variant: BebeDetailActionCardVariant.success,
      onPressed: _emptyCallback,
      semanticLabel: 'Crecimiento. Siete coma veinticinco kilogramos. '
          'Percentil cuarenta y uno.',
    );
  }
}

// -----------------------------------------------------------------------------
// HISTORIAL CLÍNICO
// -----------------------------------------------------------------------------

class _ClinicalHistoryPreview extends StatelessWidget {
  const _ClinicalHistoryPreview();

  @override
  Widget build(BuildContext context) {
    return BebeDetailActionCard(
      title: 'Ver historial clínico',
      description: 'Consultas, vacunas y medicamentos en un solo lugar',
      icon: const Icon(
        Icons.folder_outlined,
      ),
      variant: BebeDetailActionCardVariant.information,
      onPressed: _emptyCallback,
      semanticLabel: 'Ver historial clínico. '
          'Consultas, vacunas y medicamentos en un solo lugar.',
    );
  }
}

// -----------------------------------------------------------------------------
// COMPONENTES VISUALES AUXILIARES DEL CATÁLOGO
// -----------------------------------------------------------------------------

class _HealthEventTimePreview extends StatelessWidget {
  const _HealthEventTimePreview({
    required this.date,
    required this.time,
  });

  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return Wrap(
      spacing: spacing.spacingM,
      runSpacing: spacing.spacingS,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: colors.icons.neutralAlternative,
            ),
            SizedBox(width: spacing.spacingXs),
            Text(
              date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.styles.label.sm.semibold.copyWith(
                color: colors.text.neutralTitle,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 16,
              color: colors.icons.neutralAlternative,
            ),
            SizedBox(width: spacing.spacingXs),
            Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.styles.body.sm.regular.copyWith(
                color: colors.text.neutralBody,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _HealthCaregiverVariant {
  mother,
  father,
}

class _HealthCaregiverPreview extends StatelessWidget {
  const _HealthCaregiverPreview({
    required this.label,
    required this.variant,
  });

  final String label;
  final _HealthCaregiverVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    final background = switch (variant) {
      _HealthCaregiverVariant.mother => colors.background.warningSurface,
      _HealthCaregiverVariant.father => colors.background.successSurface,
    };

    final foreground = switch (variant) {
      _HealthCaregiverVariant.mother => colors.text.warningDefault,
      _HealthCaregiverVariant.father => colors.text.successDefault,
    };

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.spacingM,
          vertical: spacing.spacingS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: foreground,
            ),
            SizedBox(width: spacing.spacingXs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.styles.label.sm.semibold.copyWith(
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _emptyCallback() {}
