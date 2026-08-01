import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// ---------------------------------------------------------------------------
/// USE CASES
/// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Contenido completo',
  type: BebeAgendaTemplate,
  path: '[Templates]/Agenda',
)
Widget bebeAgendaTemplateContentUseCase(
  BuildContext context,
) {
  return const _AgendaTemplateExample(
    state: BebeAgendaTemplateState.content,
  );
}

@widgetbook.UseCase(
  name: 'Offline con contenido local',
  type: BebeAgendaTemplate,
  path: '[Templates]/Agenda',
)
Widget bebeAgendaTemplateOfflineUseCase(
  BuildContext context,
) {
  return const _AgendaTemplateExample(
    state: BebeAgendaTemplateState.offline,
  );
}

@widgetbook.UseCase(
  name: 'Cargando',
  type: BebeAgendaTemplate,
  path: '[Templates]/Agenda',
)
Widget bebeAgendaTemplateLoadingUseCase(
  BuildContext context,
) {
  return const _AgendaTemplateExample(
    state: BebeAgendaTemplateState.loading,
  );
}

@widgetbook.UseCase(
  name: 'Agenda vacía',
  type: BebeAgendaTemplate,
  path: '[Templates]/Agenda',
)
Widget bebeAgendaTemplateEmptyUseCase(
  BuildContext context,
) {
  return const _AgendaTemplateExample(
    state: BebeAgendaTemplateState.empty,
  );
}

@widgetbook.UseCase(
  name: 'Error',
  type: BebeAgendaTemplate,
  path: '[Templates]/Agenda',
)
Widget bebeAgendaTemplateErrorUseCase(
  BuildContext context,
) {
  return const _AgendaTemplateExample(
    state: BebeAgendaTemplateState.error,
  );
}

/// ---------------------------------------------------------------------------
/// FIXTURE PRINCIPAL
/// ---------------------------------------------------------------------------

class _AgendaTemplateExample extends StatefulWidget {
  const _AgendaTemplateExample({
    required this.state,
  });

  final BebeAgendaTemplateState state;

  @override
  State<_AgendaTemplateExample> createState() {
    return _AgendaTemplateExampleState();
  }
}

class _AgendaTemplateExampleState extends State<_AgendaTemplateExample> {
  static final DateTime _firstDay = DateTime(2025);
  static final DateTime _lastDay = DateTime(2027, 12, 31);

  DateTime _focusedWeekDay = DateTime(2026, 5, 20);
  DateTime? _selectedWeekDay = DateTime(2026, 5, 20);

  DateTime _focusedMonthDay = DateTime(2026, 5, 20);
  DateTime? _selectedMonthDay = DateTime(2026, 5, 20);

  String _selectedFilterId = 'all';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BebeAgendaTemplate(
        state: widget.state,
        semanticLabel: 'Agenda de salud',
        header: _buildHeader(),
        weekPicker: _buildWeekPicker(),
        filters: _buildFilters(),
        todaySection: _buildTodaySection(),
        upcomingSection: _buildUpcomingSection(),
        reminderBanner: BebeAgendaReminderBanner(
          title: 'Recordatorios activos',
          description:
              'Te avisaremos antes de cada vacuna, control o medicamento programado.',
          actionLabel: 'Configurar',
          onActionPressed: _showInteraction,
        ),
        monthlyOverview: _buildMonthlyOverview(),
        healthNotice: BebeAgendaHealthNotice(
          description:
              'El historial completo de vacunas y controles está disponible en Salud.',
          actionLabel: 'Ir a Salud',
          onActionPressed: _showInteraction,
        ),
        offlineBanner: const _AgendaOfflineState(),
        loadingState: const _AgendaLoadingState(),
        emptyState: _AgendaEmptyState(
          onCreatePressed: _showInteraction,
        ),
        errorState: _AgendaErrorState(
          onRetryPressed: _showInteraction,
        ),
        onRefresh: _refresh,
        useSafeArea: true,
      ),
    );
  }

  Widget _buildHeader() {
    return BebePageHeader(
      title: 'Agenda de salud',
      alignment: BebePageHeaderAlignment.center,
      trailing: BebeNavigationIconButton(
        icon: const Icon(
          Icons.notifications_none_rounded,
        ),
        semanticLabel: 'Notificaciones',
        variant: BebeNavigationIconButtonVariant.brand,
        size: BebeNavigationIconButtonSize.large,
        onPressed: _showInteraction,
      ),
    );
  }

  Widget _buildWeekPicker() {
    return BebeAgendaWeekPicker(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focusedWeekDay,
      selectedDay: _selectedWeekDay,
      markersForDay: _markersForDay,
      onDaySelected: (
        selectedDay,
        focusedDay,
      ) {
        setState(() {
          _selectedWeekDay = selectedDay;
          _focusedWeekDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedWeekDay = focusedDay;
        });
      },
      onPreviousWeekPressed: () {
        _changeWeek(-7);
      },
      onNextWeekPressed: () {
        _changeWeek(7);
      },
    );
  }

  Widget _buildFilters() {
    return BebeAgendaCategoryFilters(
      selectedId: _selectedFilterId,
      onItemPressed: (selectedId) {
        setState(() {
          _selectedFilterId = selectedId;
        });
      },
      items: const [
        BebeAgendaFilterData(
          id: 'all',
          label: 'Todos',
          icon: Icon(
            Icons.grid_view_rounded,
          ),
          variant: BebeFilterChipVariant.brand,
          semanticLabel: 'Mostrar todos los eventos',
        ),
        BebeAgendaFilterData(
          id: 'vaccines',
          label: 'Vacunas',
          icon: Icon(
            Icons.vaccines_outlined,
          ),
          variant: BebeFilterChipVariant.accent,
        ),
        BebeAgendaFilterData(
          id: 'controls',
          label: 'Controles',
          icon: Icon(
            Icons.medical_services_outlined,
          ),
          variant: BebeFilterChipVariant.information,
        ),
        BebeAgendaFilterData(
          id: 'medication',
          label: 'Medicación',
          icon: Icon(
            Icons.medication_outlined,
          ),
          variant: BebeFilterChipVariant.warning,
        ),
        BebeAgendaFilterData(
          id: 'exams',
          label: 'Exámenes',
          icon: Icon(
            Icons.science_outlined,
          ),
          variant: BebeFilterChipVariant.information,
        ),
      ],
    );
  }

  Widget _buildTodaySection() {
    final events = _todayEvents.where(_matchesSelectedFilter).toList();

    return _AgendaEventGroup(
      title: 'Hoy',
      emptyMessage: 'No hay eventos de esta categoría programados para hoy.',
      children: events,
    );
  }

  Widget _buildUpcomingSection() {
    final events = _upcomingEvents.where(_matchesSelectedFilter).toList();

    return _AgendaEventGroup(
      title: 'Próximos días',
      emptyMessage: 'No hay próximos eventos para la categoría seleccionada.',
      children: events,
    );
  }

  Widget _buildMonthlyOverview() {
    return BebeAgendaMonthlyOverview(
      title: 'Próximo en tu agenda',
      calendar: BebeMonthCalendar(
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _focusedMonthDay,
        selectedDay: _selectedMonthDay,
        showContainer: false,
        markersForDay: _markersForDay,
        onDaySelected: (
          selectedDay,
          focusedDay,
        ) {
          setState(() {
            _selectedMonthDay = selectedDay;
            _focusedMonthDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedMonthDay = focusedDay;
          });
        },
        onPreviousMonthPressed: () {
          _changeMonth(-1);
        },
        onNextMonthPressed: () {
          _changeMonth(1);
        },
      ),
      nextEvent: BebeEventPreview(
        overline: const _TemporalBadge(
          label: 'Mañana',
        ),
        timeLabel: '10:30 AM',
        title: 'Vacuna Neumococo',
        description: 'Segunda dosis',
        icon: const Icon(
          Icons.vaccines_outlined,
        ),
        variant: BebeEventPreviewVariant.accent,
        supporting: BebeCaregiverBadge(
          label: 'Mamá',
          avatar: const _CaregiverAvatar(
            initials: 'M',
          ),
          size: BebeCaregiverBadgeSize.small,
          variant: BebeCaregiverBadgeVariant.brand,
        ),
        onPressed: _showInteraction,
      ),
    );
  }

  List<_AgendaEventFixture> get _todayEvents {
    return [
      _AgendaEventFixture(
        categoryId: 'vaccines',
        child: BebeAgendaEventCard(
          time: const BebeTimeBlock(
            timeLabel: '10:30',
            periodLabel: 'AM',
            size: BebeTimeBlockSize.small,
          ),
          icon: const Icon(
            Icons.vaccines_outlined,
          ),
          title: 'Vacuna Neumococo (PCV13)',
          description: 'Segunda dosis',
          variant: BebeAgendaEventCardVariant.accent,
          caregiver: BebeCaregiverBadge(
            label: 'Mamá',
            avatar: const _CaregiverAvatar(
              initials: 'M',
            ),
            size: BebeCaregiverBadgeSize.small,
            variant: BebeCaregiverBadgeVariant.brand,
          ),
          onPressed: _showInteraction,
        ),
      ),
      _AgendaEventFixture(
        categoryId: 'medication',
        child: BebeAgendaEventCard(
          time: const BebeTimeBlock(
            timeLabel: '20:00',
            size: BebeTimeBlockSize.small,
          ),
          icon: const Icon(
            Icons.medication_outlined,
          ),
          title: 'Vitamina D',
          description: 'Administrar dosis indicada',
          variant: BebeAgendaEventCardVariant.warning,
          syncIndicator: const _SyncBadge(
            label: 'Pendiente',
          ),
          onPressed: _showInteraction,
        ),
      ),
    ];
  }

  List<_AgendaEventFixture> get _upcomingEvents {
    return [
      _AgendaEventFixture(
        categoryId: 'controls',
        child: BebeAgendaEventCard(
          time: const BebeTimeBlock(
            dateLabel: 'Vie, 22 may',
            timeLabel: '09:00',
            periodLabel: 'AM',
            size: BebeTimeBlockSize.small,
          ),
          icon: const Icon(
            Icons.medical_services_outlined,
          ),
          title: 'Control pediátrico',
          description: 'Evaluación de peso, talla y desarrollo',
          variant: BebeAgendaEventCardVariant.information,
          caregiver: BebeCaregiverBadge(
            label: 'Papá',
            avatar: const _CaregiverAvatar(
              initials: 'P',
            ),
            size: BebeCaregiverBadgeSize.small,
            variant: BebeCaregiverBadgeVariant.accent,
          ),
          onPressed: _showInteraction,
        ),
      ),
      _AgendaEventFixture(
        categoryId: 'exams',
        child: BebeAgendaEventCard(
          time: const BebeTimeBlock(
            dateLabel: 'Lun, 25 may',
            timeLabel: '08:30',
            periodLabel: 'AM',
            size: BebeTimeBlockSize.small,
          ),
          icon: const Icon(
            Icons.science_outlined,
          ),
          title: 'Examen de laboratorio',
          description: 'Llevar orden médica y antecedentes',
          variant: BebeAgendaEventCardVariant.brand,
          onPressed: _showInteraction,
        ),
      ),
    ];
  }

  bool _matchesSelectedFilter(
    _AgendaEventFixture event,
  ) {
    return _selectedFilterId == 'all' || event.categoryId == _selectedFilterId;
  }

  List<BebeCalendarMarkerData> _markersForDay(
    DateTime day,
  ) {
    if (_isSameDate(day, DateTime(2026, 5, 18))) {
      return const [
        BebeCalendarMarkerData(
          id: 'control',
          color: Color(0xFF208A95),
          semanticLabel: 'Control',
        ),
      ];
    }

    if (_isSameDate(day, DateTime(2026, 5, 20))) {
      return const [
        BebeCalendarMarkerData(
          id: 'vaccine',
          color: Color(0xFF7357B6),
          semanticLabel: 'Vacuna',
        ),
        BebeCalendarMarkerData(
          id: 'medication',
          color: Color(0xFFE37B68),
          semanticLabel: 'Medicación',
        ),
      ];
    }

    if (_isSameDate(day, DateTime(2026, 5, 22))) {
      return const [
        BebeCalendarMarkerData(
          id: 'control',
          color: Color(0xFF208A95),
          semanticLabel: 'Control pediátrico',
        ),
      ];
    }

    if (_isSameDate(day, DateTime(2026, 5, 25))) {
      return const [
        BebeCalendarMarkerData(
          id: 'exam',
          color: Color(0xFF4B7EC2),
          semanticLabel: 'Examen',
        ),
      ];
    }

    return const [];
  }

  void _changeWeek(int days) {
    final candidate = _focusedWeekDay.add(
      Duration(days: days),
    );

    if (candidate.isBefore(_firstDay) || candidate.isAfter(_lastDay)) {
      return;
    }

    setState(() {
      _focusedWeekDay = candidate;
      _selectedWeekDay = candidate;
    });
  }

  void _changeMonth(int offset) {
    final candidate = DateTime(
      _focusedMonthDay.year,
      _focusedMonthDay.month + offset,
      1,
    );

    if (candidate.isBefore(_firstDay) || candidate.isAfter(_lastDay)) {
      return;
    }

    setState(() {
      _focusedMonthDay = candidate;
    });
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );
  }

  void _showInteraction() {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text(
          'Interacción de demostración',
        ),
        duration: Duration(
          milliseconds: 900,
        ),
      ),
    );
  }

  bool _isSameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

/// ---------------------------------------------------------------------------
/// SECCIONES DE EVENTOS
/// ---------------------------------------------------------------------------

class _AgendaEventFixture {
  const _AgendaEventFixture({
    required this.categoryId,
    required this.child,
  });

  final String categoryId;
  final Widget child;
}

class _AgendaEventGroup extends StatelessWidget {
  const _AgendaEventGroup({
    required this.title,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final String emptyMessage;
  final List<_AgendaEventFixture> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeTitleSection(
          title: title,
        ),
        SizedBox(
          height: spacing.spacingL,
        ),
        if (children.isEmpty)
          _AgendaSectionEmptyState(
            message: emptyMessage,
          )
        else
          for (var index = 0; index < children.length; index++) ...[
            children[index].child,
            if (index != children.length - 1)
              SizedBox(
                height: spacing.spacingM,
              ),
          ],
      ],
    );
  }
}

class _AgendaSectionEmptyState extends StatelessWidget {
  const _AgendaSectionEmptyState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;
    final colors = theme.colors;
    final typography = theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(
          radius.radius3xl,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          spacing.spacingL,
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: typography.styles.body.sm.regular.copyWith(
            color: colors.text.neutralBody,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ESTADOS DEL TEMPLATE
/// ---------------------------------------------------------------------------

class _AgendaOfflineState extends StatelessWidget {
  const _AgendaOfflineState();

  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    return const _AgendaStateCard(
      icon: Icon(
        Icons.cloud_off_outlined,
        size: _iconSize,
      ),
      title: 'Sin conexión',
      description:
          'Mostramos la información guardada en este dispositivo. Los cambios pendientes se sincronizarán más tarde.',
      variant: _AgendaStateCardVariant.warning,
    );
  }
}

class _AgendaLoadingState extends StatelessWidget {
  const _AgendaLoadingState();

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _AgendaSkeletonBox(
          height: 112,
        ),
        SizedBox(
          height: spacing.spacingL,
        ),
        const _AgendaSkeletonBox(
          height: 52,
        ),
        SizedBox(
          height: spacing.spacing2xl,
        ),
        const _AgendaSkeletonBox(
          height: 112,
        ),
        SizedBox(
          height: spacing.spacingM,
        ),
        const _AgendaSkeletonBox(
          height: 112,
        ),
        SizedBox(
          height: spacing.spacing2xl,
        ),
        const _AgendaSkeletonBox(
          height: 260,
        ),
      ],
    );
  }
}

class _AgendaEmptyState extends StatelessWidget {
  const _AgendaEmptyState({
    required this.onCreatePressed,
  });

  final VoidCallback onCreatePressed;

  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    return _AgendaStateCard(
      icon: const Icon(
        Icons.event_available_outlined,
        size: _iconSize,
      ),
      title: 'Tu agenda está vacía',
      description:
          'Los próximos controles, vacunas y recordatorios aparecerán aquí.',
      actionLabel: 'Crear recordatorio',
      actionIcon: const Icon(
        Icons.add_rounded,
      ),
      onActionPressed: onCreatePressed,
      variant: _AgendaStateCardVariant.brand,
    );
  }
}

class _AgendaErrorState extends StatelessWidget {
  const _AgendaErrorState({
    required this.onRetryPressed,
  });

  final VoidCallback onRetryPressed;

  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    return _AgendaStateCard(
      icon: const Icon(
        Icons.error_outline_rounded,
        size: _iconSize,
      ),
      title: 'No pudimos cargar la agenda',
      description: 'Revisa tu conexión e intenta nuevamente.',
      actionLabel: 'Reintentar',
      actionIcon: const Icon(
        Icons.refresh_rounded,
      ),
      onActionPressed: onRetryPressed,
      variant: _AgendaStateCardVariant.warning,
    );
  }
}

/// ---------------------------------------------------------------------------
/// CARD GENÉRICA PARA ESTADOS DEL FIXTURE
///
/// Pertenece solo a Widgetbook. No forma parte del Design System.
/// ---------------------------------------------------------------------------

enum _AgendaStateCardVariant {
  brand,
  warning,
}

class _AgendaStateCard extends StatelessWidget {
  const _AgendaStateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.variant,
    this.actionLabel,
    this.actionIcon,
    this.onActionPressed,
  });

  final Widget icon;
  final String title;
  final String description;
  final _AgendaStateCardVariant variant;
  final String? actionLabel;
  final Widget? actionIcon;
  final VoidCallback? onActionPressed;

  static const double _leadingSize = 52;
  static const double _actionIconSize = 18;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;
    final colors = theme.colors;
    final typography = theme.typography;

    final palette = switch (variant) {
      _AgendaStateCardVariant.brand => (
          surface: colors.background.brandSurface,
          content: colors.text.brandDefault,
          border: colors.border.brandAlternative,
        ),
      _AgendaStateCardVariant.warning => (
          surface: colors.background.warningSurface,
          content: colors.text.warningDefault,
          border: colors.border.warningDefault,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(
          radius.radius3xl,
        ),
        border: Border.all(
          color: palette.border,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          spacing.spacingXl,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useHorizontalLayout = constraints.maxWidth >= 360;

            final content = _AgendaStateCardContent(
              title: title,
              description: description,
            );

            final leading = SizedBox.square(
              dimension: _leadingSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.background.neutralsSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      color: palette.content,
                    ),
                    child: icon,
                  ),
                ),
              ),
            );

            final action = actionLabel == null
                ? null
                : TextButton.icon(
                    onPressed: onActionPressed,
                    icon: actionIcon == null
                        ? const SizedBox.shrink()
                        : IconTheme(
                            data: IconThemeData(
                              size: _actionIconSize,
                              color: palette.content,
                            ),
                            child: actionIcon!,
                          ),
                    label: Text(
                      actionLabel!,
                      style: typography.styles.label.md.semibold.copyWith(
                        color: palette.content,
                      ),
                    ),
                  );

            if (!useHorizontalLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: leading,
                  ),
                  SizedBox(
                    height: spacing.spacingL,
                  ),
                  content,
                  if (action != null) ...[
                    SizedBox(
                      height: spacing.spacingM,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: action,
                    ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                leading,
                SizedBox(
                  width: spacing.spacingL,
                ),
                Expanded(
                  child: content,
                ),
                if (action != null) ...[
                  SizedBox(
                    width: spacing.spacingL,
                  ),
                  Flexible(
                    child: action,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AgendaStateCardContent extends StatelessWidget {
  const _AgendaStateCardContent({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: typography.styles.title.sm.semibold.copyWith(
            color: colors.text.neutralTitle,
          ),
        ),
        SizedBox(
          height: spacing.spacingXs,
        ),
        Text(
          description,
          style: typography.styles.body.sm.regular.copyWith(
            color: colors.text.neutralBody,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// SKELETON DEL FIXTURE
/// ---------------------------------------------------------------------------

class _AgendaSkeletonBox extends StatelessWidget {
  const _AgendaSkeletonBox({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background.neutralsActive,
          borderRadius: BorderRadius.circular(
            theme.borderRadius.radius3xl,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// BADGES Y AVATAR LOCALES DEL FIXTURE
///
/// Se mantienen privados para no inventar contratos públicos adicionales.
/// ---------------------------------------------------------------------------

class _TemporalBadge extends StatelessWidget {
  const _TemporalBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.brandSurface,
        borderRadius: BorderRadius.circular(
          theme.borderRadius.radiusFull,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.spacingM,
          vertical: spacing.spacingXs,
        ),
        child: Text(
          label,
          maxLines: 1,
          style: typography.styles.label.sm.semibold.copyWith(
            color: colors.text.brandDefault,
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.warningSurface,
        borderRadius: BorderRadius.circular(
          theme.borderRadius.radiusFull,
        ),
        border: Border.all(
          color: colors.border.warningDefault,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.spacingM,
          vertical: spacing.spacingXs,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typography.styles.label.sm.semibold.copyWith(
            color: colors.text.warningDefault,
          ),
        ),
      ),
    );
  }
}

class _CaregiverAvatar extends StatelessWidget {
  const _CaregiverAvatar({
    required this.initials,
  });

  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.neutralsSurface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: typography.styles.label.sm.semibold.copyWith(
            color: colors.text.brandDefault,
          ),
        ),
      ),
    );
  }
}
