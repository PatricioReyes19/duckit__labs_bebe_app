import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:health/models/health_overview_vm.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HealthView extends StatelessWidget {
  const HealthView({
    this.onVaccinesPressed,
    this.onControlsPressed,
    this.onGrowthPressed,
    this.onConsultationsPressed,
    this.onPediatricCarePressed,
    this.onAgendaPressed,
    this.onClinicalHistoryPressed,
    this.onReportsPressed,
    super.key,
  });

  final VoidCallback? onVaccinesPressed;
  final VoidCallback? onControlsPressed;
  final VoidCallback? onGrowthPressed;
  final VoidCallback? onConsultationsPressed;
  final VoidCallback? onPediatricCarePressed;
  final VoidCallback? onAgendaPressed;
  final VoidCallback? onClinicalHistoryPressed;
  final VoidCallback? onReportsPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (context, state) {
        return switch (state) {
          HealthInitial() || HealthLoading() => const _HealthOverviewLoading(),
          HealthFailure(:final message) => _HealthOverviewError(
            message: message,
            onRetry: () =>
                context.read<HealthBloc>().add(const HealthEvent.retried()),
          ),
          HealthLoaded(:final overview) => _HealthOverviewContent(
            overview: overview,
            isUpcomingLoading: false,
            onVaccinesPressed: onVaccinesPressed,
            onControlsPressed: onControlsPressed,
            onGrowthPressed: onGrowthPressed,
            onConsultationsPressed: onConsultationsPressed,
            onPediatricCarePressed: onPediatricCarePressed,
            onAgendaPressed: onAgendaPressed,
            onClinicalHistoryPressed: onClinicalHistoryPressed,
            onReportsPressed: onReportsPressed,
          ),
        };
      },
    );
  }
}

class _HealthOverviewContent extends StatelessWidget {
  const _HealthOverviewContent({
    required this.overview,
    required this.isUpcomingLoading,
    this.onVaccinesPressed,
    this.onControlsPressed,
    this.onGrowthPressed,
    this.onConsultationsPressed,
    this.onPediatricCarePressed,
    this.onAgendaPressed,
    this.onClinicalHistoryPressed,
    this.onReportsPressed,
  });

  final HealthOverviewVm overview;
  final bool isUpcomingLoading;
  final VoidCallback? onVaccinesPressed;
  final VoidCallback? onControlsPressed;
  final VoidCallback? onGrowthPressed;
  final VoidCallback? onConsultationsPressed;
  final VoidCallback? onPediatricCarePressed;
  final VoidCallback? onAgendaPressed;
  final VoidCallback? onClinicalHistoryPressed;
  final VoidCallback? onReportsPressed;

  @override
  Widget build(BuildContext context) {
    return BebeHealthOverviewTemplate(
      onRefresh: () async {
        final bloc = context.read<HealthBloc>();
        final completed = bloc.stream.firstWhere(
          (state) => state is HealthLoaded || state is HealthFailure,
        );
        bloc.add(const HealthEvent.retried());
        await completed;
      },
      primaryActions: FeatureActionGrid(
        minimumItemWidth: 156,
        maximumColumnCount: 2,
        semanticLabel: 'Accesos principales de salud',
        children: [
          BebeFeatureActionCard(
            title: 'Vacunas',
            description: 'Consulta el calendario y vacunas aplicadas',
            icon: const Icon(Icons.vaccines_outlined),
            variant: BebeFeaturedActionCardVariant.brand,
            onPressed: onVaccinesPressed ?? _emptyCallback,
          ),
          BebeFeatureActionCard(
            title: 'Controles',
            description: 'Seguimiento del desarrollo y la salud',
            icon: const Icon(LucideIcons.stethoscope),
            variant: BebeFeaturedActionCardVariant.accent,
            onPressed: onControlsPressed ?? _emptyCallback,
          ),
          BebeFeatureActionCard(
            title: 'Crecimiento',
            description: 'Peso, talla y curvas de crecimiento',
            icon: const Icon(Icons.trending_up_rounded),
            variant: BebeFeaturedActionCardVariant.success,
            onPressed: onGrowthPressed ?? _emptyCallback,
          ),
          BebeFeatureActionCard(
            title: 'Consultas',
            description: 'Historial médico y recomendaciones',
            icon: const Icon(Icons.medical_information_outlined),
            variant: BebeFeaturedActionCardVariant.warning,
            onPressed: onConsultationsPressed ?? _emptyCallback,
          ),
        ],
      ),
      supportAction: BebeDetailActionCard(
        title: 'Pediatras y atención',
        description: 'Pediatras, clínicas y lugares de atención',
        icon: const Icon(Icons.medical_services_outlined),
        variant: BebeDetailActionCardVariant.information,
        onPressed: onPediatricCarePressed ?? _emptyCallback,
      ),
      upcomingHeader: BebeTitleSection(
        title: 'Próximos en salud',
        trailing: BebeInlineAction(
          label: 'Ver agenda',
          onPressed: onAgendaPressed ?? _emptyCallback,
          icon: const Icon(LucideIcons.calendar),
        ),
      ),
      upcomingCarousel: isUpcomingLoading
          ? const _UpcomingLoading()
          : overview.upcomingEvents.isEmpty
          ? const _UpcomingEmpty()
          : _UpcomingCarousel(events: overview.upcomingEvents),
      quickSummary: _QuickSummary(
        vaccines: overview.vaccinesSummary,
        growth: overview.growthSummary,
        onVaccinesPressed: onVaccinesPressed,
        onGrowthPressed: onGrowthPressed,
      ),
      historyAction: Column(
        children: [
          BebeDetailActionCard(
            title: 'Ver historial clínico',
            description: 'Consultas, vacunas y medicamentos en un solo lugar',
            icon: const Icon(Icons.folder_outlined),
            variant: BebeDetailActionCardVariant.information,
            onPressed: onClinicalHistoryPressed ?? _emptyCallback,
          ),
          const SizedBox(height: 12),
          BebeDetailActionCard(
            title: 'Reportes de salud',
            description: 'Tendencias, observaciones y exportación PDF o CSV',
            icon: const Icon(Icons.insights_rounded),
            variant: BebeDetailActionCardVariant.information,
            onPressed: onReportsPressed ?? _emptyCallback,
          ),
        ],
      ),
    );
  }
}

class _UpcomingCarousel extends StatelessWidget {
  const _UpcomingCarousel({required this.events});

  final List<HealthUpcomingEventVm> events;

  @override
  Widget build(BuildContext context) {
    return BebeHorizontalCardCarousel(
      height: 148,
      viewportFraction: 0.88,
      padEnds: false,
      semanticLabel: 'Próximos eventos de salud',
      children: events
          .map((event) => _UpcomingEventCard(event: event))
          .toList(growable: false),
    );
  }
}

class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard({required this.event});

  final HealthUpcomingEventVm event;

  @override
  Widget build(BuildContext context) {
    final (icon, variant) = switch (event.type) {
      HealthEventType.vaccine => (
        const Icon(Icons.vaccines_outlined),
        BebeAgendaEventCardVariant.accent,
      ),
      HealthEventType.immunization => (
        const Icon(Icons.health_and_safety_outlined),
        BebeAgendaEventCardVariant.accent,
      ),
      HealthEventType.pediatricControl => (
        const Icon(LucideIcons.stethoscope),
        BebeAgendaEventCardVariant.information,
      ),
      HealthEventType.growthControl => (
        const Icon(Icons.monitor_weight_outlined),
        BebeAgendaEventCardVariant.success,
      ),
      HealthEventType.consultation => (
        const Icon(Icons.medical_information_outlined),
        BebeAgendaEventCardVariant.information,
      ),
    };

    return BebeAgendaEventCard(
      layout: BebeAgendaEventCardLayout.carousel,
      time: _EventTime(date: event.dateLabel, time: event.timeLabel),
      icon: icon,
      title: event.title,
      description: event.description,
      caregiver: _CaregiverChip(caregiver: event.caregiver),
      variant: variant,
      onPressed: _emptyCallback,
    );
  }
}

class _EventTime extends StatelessWidget {
  const _EventTime({required this.date, required this.time});

  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Wrap(
      spacing: theme.spacing.spacingM,
      runSpacing: theme.spacing.spacingS,
      children: [
        _Metadata(icon: Icons.calendar_today_outlined, label: date),
        _Metadata(icon: Icons.schedule_outlined, label: time),
      ],
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colors.icons.neutralAlternative),
        SizedBox(width: theme.spacing.spacingXs),
        Text(
          label,
          style: theme.typography.styles.label.sm.semibold.copyWith(
            color: theme.colors.text.neutralTitle,
          ),
        ),
      ],
    );
  }
}

class _CaregiverChip extends StatelessWidget {
  const _CaregiverChip({required this.caregiver});

  final HealthCaregiverVm caregiver;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final (background, foreground) = switch (caregiver.role) {
      HealthCaregiverRole.mother => (
        theme.colors.background.warningSurface,
        theme.colors.text.warningDefault,
      ),
      HealthCaregiverRole.father => (
        theme.colors.background.successSurface,
        theme.colors.text.successDefault,
      ),
      HealthCaregiverRole.other => (
        theme.colors.background.neutralsActive,
        theme.colors.text.neutralBody,
      ),
    };

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.spacingM,
          vertical: theme.spacing.spacingS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline_rounded, size: 18, color: foreground),
            SizedBox(width: theme.spacing.spacingXs),
            Text(
              caregiver.label,
              style: theme.typography.styles.label.sm.semibold.copyWith(
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSummary extends StatelessWidget {
  const _QuickSummary({
    required this.vaccines,
    required this.growth,
    this.onVaccinesPressed,
    this.onGrowthPressed,
  });

  final HealthVaccinesSummaryVm vaccines;
  final HealthGrowthSummaryVm growth;
  final VoidCallback? onVaccinesPressed;
  final VoidCallback? onGrowthPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const BebeTitleSection(title: 'Resumen rápido'),
        SizedBox(height: spacing.spacingL),
        BebeMetricsOverview(
          minimumItemWidth: 136,
          maximumColumnCount: 2,
          semanticLabel: 'Resumen rápido de salud',
          children: [
            BebeCompactMetricCard(
              label: 'Vacunas',
              value: vaccines.completed == 0 && vaccines.pending == 0
                  ? '—'
                  : '${vaccines.completed}',
              unit: vaccines.completed == 0 && vaccines.pending == 0
                  ? null
                  : 'al día',
              supportingText: vaccines.completed == 0 && vaccines.pending == 0
                  ? 'Sin registros'
                  : '${vaccines.pending} pendientes',
              icon: const Icon(Icons.health_and_safety_outlined),
              variant: BebeMetricCardVariant.brand,
              onPressed: onVaccinesPressed ?? _emptyCallback,
            ),
            BebeCompactMetricCard(
              label: 'Crecimiento',
              value: growth.weightKg == null
                  ? '—'
                  : growth.weightKg!.toStringAsFixed(2),
              unit: growth.weightKg == null ? null : 'kg',
              supportingText: growth.recordedAtLabel ?? 'Sin mediciones',
              icon: const Icon(Icons.monitor_weight_outlined),
              variant: BebeMetricCardVariant.success,
              onPressed: onGrowthPressed ?? _emptyCallback,
            ),
          ],
        ),
      ],
    );
  }
}

class _UpcomingEmpty extends StatelessWidget {
  const _UpcomingEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.spacingL),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background.neutralsSurface,
          borderRadius: BorderRadius.circular(theme.borderRadius.radius3xl),
          border: Border.all(color: theme.colors.border.neutralDefault),
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                BebeIllustrationAssets.emptyHealth,
                package: BebeIllustrationAssets.packageName,
                height: 150,
                fit: BoxFit.contain,
                semanticLabel: 'Balanza infantil lista para una medición',
              ),
              const SizedBox(height: 12),
              const Text('Aún no hay información de salud'),
              const SizedBox(height: 4),
              const Text(
                'Las mediciones, vacunas y controles que registres aparecerán aquí.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingLoading extends StatelessWidget {
  const _UpcomingLoading();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      height: 148,
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.background.neutralsActive,
                borderRadius: BorderRadius.circular(
                  theme.borderRadius.radius3xl,
                ),
              ),
            ),
          ),
          SizedBox(width: theme.spacing.spacingM),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.background.neutralsActive,
                borderRadius: BorderRadius.circular(
                  theme.borderRadius.radius3xl,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthOverviewLoading extends StatelessWidget {
  const _HealthOverviewLoading();

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Cargando resumen de salud',
      child: ExcludeSemantics(
        child: BebeHealthOverviewTemplate(
          primaryActions: const BebeSkeleton(height: 196),
          supportAction: const BebeSkeleton(height: 92),
          upcomingHeader: const BebeSkeleton.line(width: 190, height: 20),
          upcomingCarousel: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.spacingL),
            child: const BebeSkeleton(height: 148),
          ),
          quickSummary: const BebeSkeleton(height: 132),
          historyAction: const BebeSkeleton(height: 72),
        ),
      ),
    );
  }
}

class _HealthOverviewError extends StatelessWidget {
  const _HealthOverviewError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

void _emptyCallback() {}
