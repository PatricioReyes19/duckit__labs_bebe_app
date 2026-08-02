import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeAgendaTemplateState { content, loading, empty, error, offline }

class BebeAgendaTemplate extends StatelessWidget {
  const BebeAgendaTemplate({
    required this.header,
    required this.weekPicker,
    required this.filters,
    required this.todaySection,
    required this.upcomingSection,
    required this.loadingState,
    required this.emptyState,
    required this.errorState,
    this.state = BebeAgendaTemplateState.content,
    this.offlineBanner,
    this.reminderBanner,
    this.monthlyOverview,
    this.healthNotice,
    this.additionalSections = const [],
    this.onRefresh,
    this.useSafeArea = true,
    this.contentPadding,
    this.bottomSpacing,
    this.semanticLabel = 'Agenda de salud',
    super.key,
  });

  /// Encabezado completo de la pantalla.
  ///
  /// Normalmente recibe [BebePageHeader], pero el template no depende
  /// directamente de ese componente.
  final Widget header;

  /// Selector semanal.
  ///
  /// Normalmente recibe [BebeAgendaWeekPicker].
  final Widget weekPicker;

  /// Filtros horizontales de Agenda.
  ///
  /// Normalmente recibe [BebeAgendaCategoryFilters].
  final Widget filters;

  /// Eventos correspondientes al día seleccionado.
  final Widget todaySection;

  /// Eventos futuros.
  final Widget upcomingSection;

  /// Estado visual que reemplaza el contenido durante la carga inicial.
  final Widget loadingState;

  /// Estado visual mostrado cuando no existe información.
  final Widget emptyState;

  /// Estado visual mostrado ante un error que impide presentar contenido.
  final Widget errorState;

  final BebeAgendaTemplateState state;

  /// En modo offline se muestra antes del contenido local.
  final Widget? offlineBanner;

  /// Aviso de recordatorios configurados.
  final Widget? reminderBanner;

  /// Calendario mensual y próximo evento.
  final Widget? monthlyOverview;

  /// Acceso contextual al módulo Salud.
  final Widget? healthNotice;

  /// Permite extender la composición sin modificar el template.
  ///
  /// No debe utilizarse para reemplazar slots ya definidos.
  final List<Widget> additionalSections;

  /// Cuando está presente, habilita pull-to-refresh.
  final Future<void> Function()? onRefresh;

  /// El template puede utilizarse directamente en el body del Scaffold.
  ///
  /// Desactívalo si el Shell ya administra SafeArea.
  final bool useSafeArea;

  /// Padding exterior opcional.
  ///
  /// Si es null, utiliza los tokens del Design System.
  final EdgeInsetsGeometry? contentPadding;

  /// Espacio inferior opcional para evitar que contenido flotante,
  /// navegación o FAB cubran la última sección.
  final double? bottomSpacing;

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    final effectivePadding =
        contentPadding ??
        EdgeInsets.only(
          left: spacing.spacingXl,
          top: spacing.spacingL,
          right: spacing.spacingXl,
        );

    final effectiveBottomSpacing = bottomSpacing ?? spacing.spacing4xl;

    final body = _AgendaTemplateBody(
      state: state,
      header: header,
      weekPicker: weekPicker,
      filters: filters,
      todaySection: todaySection,
      upcomingSection: upcomingSection,
      loadingState: loadingState,
      emptyState: emptyState,
      errorState: errorState,
      offlineBanner: offlineBanner,
      reminderBanner: reminderBanner,
      monthlyOverview: monthlyOverview,
      healthNotice: healthNotice,
      additionalSections: additionalSections,
      onRefresh: onRefresh,
      contentPadding: effectivePadding,
      bottomSpacing: effectiveBottomSpacing,
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: useSafeArea ? SafeArea(bottom: false, child: body) : body,
    );
  }
}

class _AgendaTemplateBody extends StatelessWidget {
  const _AgendaTemplateBody({
    required this.state,
    required this.header,
    required this.weekPicker,
    required this.filters,
    required this.todaySection,
    required this.upcomingSection,
    required this.loadingState,
    required this.emptyState,
    required this.errorState,
    required this.offlineBanner,
    required this.reminderBanner,
    required this.monthlyOverview,
    required this.healthNotice,
    required this.additionalSections,
    required this.onRefresh,
    required this.contentPadding,
    required this.bottomSpacing,
  });

  final BebeAgendaTemplateState state;

  final Widget header;
  final Widget weekPicker;
  final Widget filters;
  final Widget todaySection;
  final Widget upcomingSection;

  final Widget loadingState;
  final Widget emptyState;
  final Widget errorState;

  final Widget? offlineBanner;
  final Widget? reminderBanner;
  final Widget? monthlyOverview;
  final Widget? healthNotice;

  final List<Widget> additionalSections;

  final Future<void> Function()? onRefresh;

  final EdgeInsetsGeometry contentPadding;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      physics: onRefresh != null
          ? const AlwaysScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          _AgendaTemplateStateContent(
            state: state,
            weekPicker: weekPicker,
            filters: filters,
            todaySection: todaySection,
            upcomingSection: upcomingSection,
            loadingState: loadingState,
            emptyState: emptyState,
            errorState: errorState,
            offlineBanner: offlineBanner,
            reminderBanner: reminderBanner,
            monthlyOverview: monthlyOverview,
            healthNotice: healthNotice,
            additionalSections: additionalSections,
          ),
          SizedBox(height: bottomSpacing),
        ],
      ),
    );

    if (onRefresh == null) {
      return scrollView;
    }

    return RefreshIndicator(onRefresh: onRefresh!, child: scrollView);
  }
}

enum _AgendaTemplateLayout {
  compact,
  medium,
  expanded;

  static const double _mediumBreakpoint = 600;
  static const double _expandedBreakpoint = 960;

  static _AgendaTemplateLayout resolve(double width) {
    if (width >= _expandedBreakpoint) {
      return _AgendaTemplateLayout.expanded;
    }

    if (width >= _mediumBreakpoint) {
      return _AgendaTemplateLayout.medium;
    }

    return _AgendaTemplateLayout.compact;
  }
}

class _AgendaTemplateStateContent extends StatelessWidget {
  const _AgendaTemplateStateContent({
    required this.state,
    required this.weekPicker,
    required this.filters,
    required this.todaySection,
    required this.upcomingSection,
    required this.loadingState,
    required this.emptyState,
    required this.errorState,
    required this.offlineBanner,
    required this.reminderBanner,
    required this.monthlyOverview,
    required this.healthNotice,
    required this.additionalSections,
  });

  final BebeAgendaTemplateState state;

  final Widget weekPicker;
  final Widget filters;
  final Widget todaySection;
  final Widget upcomingSection;

  final Widget loadingState;
  final Widget emptyState;
  final Widget errorState;

  final Widget? offlineBanner;
  final Widget? reminderBanner;
  final Widget? monthlyOverview;
  final Widget? healthNotice;

  final List<Widget> additionalSections;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    final headerSpacing = SizedBox(height: spacing.spacingXl);

    return switch (state) {
      BebeAgendaTemplateState.loading => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [headerSpacing, loadingState],
      ),
      BebeAgendaTemplateState.empty => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [headerSpacing, emptyState],
      ),
      BebeAgendaTemplateState.error => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [headerSpacing, errorState],
      ),
      BebeAgendaTemplateState.content => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerSpacing,
          _AgendaTemplateContent(
            weekPicker: weekPicker,
            filters: filters,
            todaySection: todaySection,
            upcomingSection: upcomingSection,
            reminderBanner: reminderBanner,
            monthlyOverview: monthlyOverview,
            healthNotice: healthNotice,
            additionalSections: additionalSections,
          ),
        ],
      ),
      BebeAgendaTemplateState.offline => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerSpacing,
          if (offlineBanner != null) ...[
            offlineBanner!,
            SizedBox(height: spacing.spacingXl),
          ],
          _AgendaTemplateContent(
            weekPicker: weekPicker,
            filters: filters,
            todaySection: todaySection,
            upcomingSection: upcomingSection,
            reminderBanner: reminderBanner,
            monthlyOverview: monthlyOverview,
            healthNotice: healthNotice,
            additionalSections: additionalSections,
          ),
        ],
      ),
    };
  }
}

class _AgendaTemplateContent extends StatelessWidget {
  const _AgendaTemplateContent({
    required this.weekPicker,
    required this.filters,
    required this.todaySection,
    required this.upcomingSection,
    required this.reminderBanner,
    required this.monthlyOverview,
    required this.healthNotice,
    required this.additionalSections,
  });

  final Widget weekPicker;
  final Widget filters;
  final Widget todaySection;
  final Widget upcomingSection;

  final Widget? reminderBanner;
  final Widget? monthlyOverview;
  final Widget? healthNotice;

  final List<Widget> additionalSections;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    final sections = <_AgendaTemplateSection>[
      _AgendaTemplateSection(child: weekPicker, spacingAfter: spacing.spacingL),
      _AgendaTemplateSection(child: filters, spacingAfter: spacing.spacing2xl),
      _AgendaTemplateSection(
        child: todaySection,
        spacingAfter: spacing.spacing2xl,
      ),
      _AgendaTemplateSection(
        child: upcomingSection,
        spacingAfter: spacing.spacing2xl,
      ),
      if (reminderBanner != null)
        _AgendaTemplateSection(
          child: reminderBanner!,
          spacingAfter: spacing.spacing2xl,
        ),
      if (monthlyOverview != null)
        _AgendaTemplateSection(
          child: monthlyOverview!,
          spacingAfter: spacing.spacing2xl,
        ),
      if (healthNotice != null)
        _AgendaTemplateSection(
          child: healthNotice!,
          spacingAfter: spacing.spacing2xl,
        ),
      for (final section in additionalSections)
        _AgendaTemplateSection(
          child: section,
          spacingAfter: spacing.spacing2xl,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          sections[index].child,
          if (index != sections.length - 1)
            SizedBox(height: sections[index].spacingAfter),
        ],
      ],
    );
  }
}

class _AgendaTemplateSection {
  const _AgendaTemplateSection({
    required this.child,
    required this.spacingAfter,
  });

  final Widget child;
  final double spacingAfter;
}
