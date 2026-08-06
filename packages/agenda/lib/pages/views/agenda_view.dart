import 'package:agenda/agenda.dart';
import 'package:agenda/models/agenda_overview_vm.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({
    this.onNotificationsPressed,
    this.onConfigureRemindersPressed,
    this.onHealthPressed,
    this.onCreateReminderPressed,
    this.onEventPressed,
    super.key,
  });

  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onConfigureRemindersPressed;
  final VoidCallback? onHealthPressed;
  final VoidCallback? onCreateReminderPressed;
  final ValueChanged<String>? onEventPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgendaBloc, AgendaState>(
      builder: (context, state) {
        return switch (state) {
          AgendaInitial() || AgendaLoading() => _AgendaStateFrame(
            state: BebeAgendaTemplateState.loading,
            loadingState: const _AgendaLoadingState(),
            onNotificationsPressed: onNotificationsPressed,
          ),
          AgendaFailure(:final message) => _AgendaStateFrame(
            state: BebeAgendaTemplateState.error,
            errorState: _AgendaErrorState(
              message: message,
              onRetryPressed: () =>
                  context.read<AgendaBloc>().add(const AgendaEvent.retried()),
            ),
            onNotificationsPressed: onNotificationsPressed,
          ),
          AgendaEmpty(:final overview) => _AgendaContent(
            overview: overview,
            templateState: BebeAgendaTemplateState.empty,
            onNotificationsPressed: onNotificationsPressed,
            onConfigureRemindersPressed: onConfigureRemindersPressed,
            onHealthPressed: onHealthPressed,
            onCreateReminderPressed: onCreateReminderPressed,
            onEventPressed: onEventPressed,
          ),
          AgendaLoaded(:final overview) => _AgendaContent(
            overview: overview,
            templateState:
                overview.connectionStatus == AgendaConnectionStatus.offline
                ? BebeAgendaTemplateState.offline
                : BebeAgendaTemplateState.content,
            onNotificationsPressed: onNotificationsPressed,
            onConfigureRemindersPressed: onConfigureRemindersPressed,
            onHealthPressed: onHealthPressed,
            onCreateReminderPressed: onCreateReminderPressed,
            onEventPressed: onEventPressed,
          ),
        };
      },
    );
  }
}

class _AgendaStateFrame extends StatelessWidget {
  const _AgendaStateFrame({
    required this.state,
    this.loadingState,
    this.errorState,
    this.onNotificationsPressed,
  });

  final BebeAgendaTemplateState state;
  final Widget? loadingState;
  final Widget? errorState;
  final VoidCallback? onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return BebeAgendaTemplate(
      state: state,
      semanticLabel: 'Agenda de salud',
      weekPicker: const SizedBox.shrink(),
      filters: const SizedBox.shrink(),
      todaySection: const SizedBox.shrink(),
      upcomingSection: const SizedBox.shrink(),
      loadingState: loadingState ?? const SizedBox.shrink(),
      emptyState: const SizedBox.shrink(),
      errorState: errorState ?? const SizedBox.shrink(),
      useSafeArea: false,
      bottomSpacing: spacing.spacing8xl + spacing.spacing4xl,
    );
  }
}

class _AgendaContent extends StatelessWidget {
  const _AgendaContent({
    required this.overview,
    required this.templateState,
    this.onNotificationsPressed,
    this.onConfigureRemindersPressed,
    this.onHealthPressed,
    this.onCreateReminderPressed,
    this.onEventPressed,
  });

  final AgendaOverviewVm overview;
  final BebeAgendaTemplateState templateState;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onConfigureRemindersPressed;
  final VoidCallback? onHealthPressed;
  final VoidCallback? onCreateReminderPressed;
  final ValueChanged<String>? onEventPressed;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AgendaBloc>();
    final spacing = context.theme.spacing;
    final todayEvents = overview.eventsFor(overview.selectedWeekDay);
    final upcomingEvents = overview.upcomingAfter(overview.selectedWeekDay);

    return BebeAgendaTemplate(
      state: templateState,
      semanticLabel: 'Agenda de salud',
      weekPicker: BebeAgendaWeekPicker(
        firstDay: overview.firstDay,
        lastDay: overview.lastDay,
        focusedDay: overview.focusedWeekDay,
        selectedDay: overview.selectedWeekDay,
        markersForDay: (day) => _markersForDay(context, overview, day),
        onDaySelected: (selectedDay, focusedDay) => bloc.add(
          AgendaEvent.daySelected(
            selectedDay: selectedDay,
            focusedDay: focusedDay,
          ),
        ),
        onPageChanged: (focusedDay) =>
            bloc.add(AgendaEvent.weekChanged(focusedDay)),
        onPreviousWeekPressed: () => bloc.add(
          AgendaEvent.weekChanged(
            overview.focusedWeekDay.subtract(const Duration(days: 7)),
          ),
        ),
        onNextWeekPressed: () => bloc.add(
          AgendaEvent.weekChanged(
            overview.focusedWeekDay.add(const Duration(days: 7)),
          ),
        ),
      ),
      filters: BebeAgendaCategoryFilters(
        selectedId: overview.selectedCategory.name,
        onItemPressed: (id) => bloc.add(
          AgendaEvent.categorySelected(
            AgendaCategory.values.firstWhere(
              (category) => category.name == id,
              orElse: () => AgendaCategory.all,
            ),
          ),
        ),
        items: const [
          BebeAgendaFilterData(
            id: 'all',
            label: 'Todos',
            icon: Icon(Icons.grid_view_rounded),
            variant: BebeFilterChipVariant.brand,
            semanticLabel: 'Mostrar todos los eventos',
          ),
          BebeAgendaFilterData(
            id: 'vaccines',
            label: 'Vacunas',
            icon: Icon(Icons.vaccines_outlined),
            variant: BebeFilterChipVariant.accent,
          ),
          BebeAgendaFilterData(
            id: 'controls',
            label: 'Controles',
            icon: Icon(Icons.medical_services_outlined),
            variant: BebeFilterChipVariant.information,
          ),
          BebeAgendaFilterData(
            id: 'medication',
            label: 'Medicación',
            icon: Icon(Icons.medication_outlined),
            variant: BebeFilterChipVariant.warning,
          ),
          BebeAgendaFilterData(
            id: 'exams',
            label: 'Exámenes',
            icon: Icon(Icons.science_outlined),
            variant: BebeFilterChipVariant.information,
          ),
        ],
      ),
      todaySection: _AgendaEventGroup(
        title: 'Hoy',
        emptyMessage: 'No hay eventos de esta categoría programados para hoy.',
        events: todayEvents,
        onEventPressed: onEventPressed,
      ),
      upcomingSection: _AgendaEventGroup(
        title: 'Próximos días',
        emptyMessage: 'No hay próximos eventos para la categoría seleccionada.',
        events: upcomingEvents,
        onEventPressed: onEventPressed,
      ),
      reminderBanner: BebeAgendaReminderBanner(
        title: overview.remindersEnabled
            ? 'Recordatorios activos'
            : 'Recordatorios desactivados',
        description:
            'Te avisaremos antes de cada vacuna, control o medicamento programado.',
        actionLabel: 'Configurar',
        onActionPressed: onConfigureRemindersPressed ?? _emptyCallback,
      ),
      monthlyOverview: _MonthlyOverview(
        overview: overview,
        onEventPressed: onEventPressed,
      ),
      healthNotice: BebeAgendaHealthNotice(
        description:
            'El historial completo de vacunas y controles está disponible en Salud.',
        actionLabel: 'Ir a Salud',
        onActionPressed: onHealthPressed ?? _emptyCallback,
      ),
      offlineBanner: const _AgendaOfflineState(),
      loadingState: const _AgendaLoadingState(),
      emptyState: _AgendaEmptyState(
        onCreatePressed: onCreateReminderPressed ?? _emptyCallback,
      ),
      errorState: _AgendaErrorState(
        message: 'Revisa tu conexión e intenta nuevamente.',
        onRetryPressed: () => bloc.add(const AgendaEvent.retried()),
      ),
      onRefresh: () async {
        bloc.add(const AgendaEvent.refreshed());
        await Future<void>.delayed(const Duration(milliseconds: 450));
      },
      useSafeArea: false,
      bottomSpacing: spacing.spacing8xl + spacing.spacing4xl,
    );
  }
}

class _MonthlyOverview extends StatelessWidget {
  const _MonthlyOverview({required this.overview, this.onEventPressed});

  final AgendaOverviewVm overview;
  final ValueChanged<String>? onEventPressed;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AgendaBloc>();
    final next = overview.nextEvent;

    return BebeAgendaMonthlyOverview(
      title: 'Próximo en tu agenda',
      calendar: BebeMonthCalendar(
        firstDay: overview.firstDay,
        lastDay: overview.lastDay,
        focusedDay: overview.focusedMonthDay,
        selectedDay: overview.selectedMonthDay,
        showContainer: false,
        markersForDay: (day) => _markersForDay(context, overview, day),
        onDaySelected: (selectedDay, focusedDay) => bloc.add(
          AgendaEvent.monthDaySelected(
            selectedDay: selectedDay,
            focusedDay: focusedDay,
          ),
        ),
        onPageChanged: (focusedDay) =>
            bloc.add(AgendaEvent.monthChanged(focusedDay)),
        onPreviousMonthPressed: () => bloc.add(
          AgendaEvent.monthChanged(
            DateTime(
              overview.focusedMonthDay.year,
              overview.focusedMonthDay.month - 1,
            ),
          ),
        ),
        onNextMonthPressed: () => bloc.add(
          AgendaEvent.monthChanged(
            DateTime(
              overview.focusedMonthDay.year,
              overview.focusedMonthDay.month + 1,
            ),
          ),
        ),
      ),
      nextEvent: next == null
          ? SizedBox.shrink()
          : BebeEventPreview(
              overline: const _TemporalBadge(label: 'Próximo'),
              timeLabel: _time(next.startsAt),
              title: next.title,
              description: next.description,
              icon: _eventIcon(next.category),
              variant: _previewVariant(next.category),
              supporting: next.caregiver == null
                  ? null
                  : BebeCaregiverBadge(
                      label: next.caregiver!.role,
                      avatar: _CaregiverAvatar(
                        initials: next.caregiver!.initials,
                      ),
                      size: BebeCaregiverBadgeSize.small,
                      variant: next.caregiver!.role == 'Mamá'
                          ? BebeCaregiverBadgeVariant.brand
                          : BebeCaregiverBadgeVariant.accent,
                    ),
              onPressed: () => onEventPressed?.call(next.id),
            ),
    );
  }
}

class _AgendaEventGroup extends StatelessWidget {
  const _AgendaEventGroup({
    required this.title,
    required this.emptyMessage,
    required this.events,
    this.onEventPressed,
  });

  final String title;
  final String emptyMessage;
  final List<AgendaEventVm> events;
  final ValueChanged<String>? onEventPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeTitleSection(title: title),
        SizedBox(height: spacing.spacingL),
        if (events.isEmpty)
          _AgendaSectionEmptyState(message: emptyMessage)
        else
          for (var index = 0; index < events.length; index++) ...[
            _AgendaEventCard(
              event: events[index],
              onPressed: () => onEventPressed?.call(events[index].id),
            ),
            if (index != events.length - 1) SizedBox(height: spacing.spacingM),
          ],
      ],
    );
  }
}

class _AgendaEventCard extends StatelessWidget {
  const _AgendaEventCard({required this.event, required this.onPressed});

  final AgendaEventVm event;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BebeAgendaEventCard(
      time: BebeTimeBlock(
        dateLabel: _date(event.startsAt),
        timeLabel: _time(event.startsAt),
        size: BebeTimeBlockSize.small,
      ),
      icon: _eventIcon(event.category),
      title: event.title,
      description: event.description,
      variant: _eventVariant(event.category),
      caregiver: event.caregiver == null
          ? null
          : BebeCaregiverBadge(
              label: event.caregiver!.role,
              avatar: _CaregiverAvatar(initials: event.caregiver!.initials),
              size: BebeCaregiverBadgeSize.small,
              variant: event.caregiver!.role == 'Mamá'
                  ? BebeCaregiverBadgeVariant.brand
                  : BebeCaregiverBadgeVariant.accent,
            ),
      syncIndicator: event.syncStatus == AgendaSyncStatus.pending
          ? const _SyncBadge(label: 'Pendiente')
          : null,
      onPressed: onPressed,
    );
  }
}

List<BebeCalendarMarkerData> _markersForDay(
  BuildContext context,
  AgendaOverviewVm overview,
  DateTime day,
) {
  return overview.markers
      .where(
        (marker) =>
            marker.date.year == day.year &&
            marker.date.month == day.month &&
            marker.date.day == day.day,
      )
      .map(
        (marker) => BebeCalendarMarkerData(
          id: marker.id,
          color: _markerColor(context, marker.category),
          semanticLabel: _categoryLabel(marker.category),
        ),
      )
      .toList(growable: false);
}

Widget _eventIcon(AgendaCategory category) => switch (category) {
  AgendaCategory.vaccines => const Icon(Icons.vaccines_outlined),
  AgendaCategory.controls => const Icon(Icons.medical_services_outlined),
  AgendaCategory.medication => const Icon(Icons.medication_outlined),
  AgendaCategory.exams => const Icon(Icons.science_outlined),
  AgendaCategory.all => const Icon(Icons.event_outlined),
};

BebeAgendaEventCardVariant _eventVariant(AgendaCategory category) {
  return switch (category) {
    AgendaCategory.vaccines => BebeAgendaEventCardVariant.accent,
    AgendaCategory.controls => BebeAgendaEventCardVariant.information,
    AgendaCategory.medication => BebeAgendaEventCardVariant.warning,
    AgendaCategory.exams ||
    AgendaCategory.all => BebeAgendaEventCardVariant.brand,
  };
}

BebeEventPreviewVariant _previewVariant(AgendaCategory category) {
  return switch (category) {
    AgendaCategory.vaccines => BebeEventPreviewVariant.accent,
    AgendaCategory.controls => BebeEventPreviewVariant.information,
    AgendaCategory.medication => BebeEventPreviewVariant.warning,
    AgendaCategory.exams || AgendaCategory.all => BebeEventPreviewVariant.brand,
  };
}

Color _markerColor(BuildContext context, AgendaCategory category) {
  final icons = context.theme.colors.icons;

  return switch (category) {
    AgendaCategory.vaccines => icons.accentDefault,
    AgendaCategory.controls => icons.brandDefault,
    AgendaCategory.medication => icons.warningDefault,
    AgendaCategory.exams => icons.infoDefault,
    AgendaCategory.all => icons.brandDefault,
  };
}

String _categoryLabel(AgendaCategory category) => switch (category) {
  AgendaCategory.vaccines => 'Vacuna',
  AgendaCategory.controls => 'Control',
  AgendaCategory.medication => 'Medicación',
  AgendaCategory.exams => 'Examen',
  AgendaCategory.all => 'Evento',
};

String _date(DateTime date) {
  const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sept',
    'oct',
    'nov',
    'dic',
  ];

  return '${weekdays[date.weekday - 1]}, '
      '${date.day} ${months[date.month - 1]}';
}

String _time(DateTime date) {
  final hours = date.hour.toString().padLeft(2, '0');
  final minutes = date.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

class _AgendaSectionEmptyState extends StatelessWidget {
  const _AgendaSectionEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(theme.borderRadius.radius3xl),
        border: Border.all(color: theme.colors.border.neutralDefault),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.spacingL),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.typography.styles.body.sm.regular.copyWith(
            color: theme.colors.text.neutralBody,
          ),
        ),
      ),
    );
  }
}

enum _AgendaStateCardVariant { brand, warning, error }

class _AgendaOfflineState extends StatelessWidget {
  const _AgendaOfflineState();

  @override
  Widget build(BuildContext context) {
    return const _AgendaStateCard(
      icon: Icon(Icons.cloud_off_outlined),
      title: 'Sin conexión',
      description:
          'Mostramos la información guardada. Los cambios pendientes se sincronizarán más tarde.',
      variant: _AgendaStateCardVariant.warning,
    );
  }
}

class _AgendaEmptyState extends StatelessWidget {
  const _AgendaEmptyState({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return _AgendaStateCard(
      icon: const Icon(Icons.event_available_outlined),
      title: 'Tu agenda está vacía',
      description:
          'Los próximos controles, vacunas y recordatorios aparecerán aquí.',
      actionLabel: 'Crear recordatorio',
      onActionPressed: onCreatePressed,
      variant: _AgendaStateCardVariant.brand,
    );
  }
}

class _AgendaErrorState extends StatelessWidget {
  const _AgendaErrorState({
    required this.message,
    required this.onRetryPressed,
  });

  final String message;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return _AgendaStateCard(
      icon: const Icon(Icons.error_outline_rounded),
      title: 'No pudimos cargar la agenda',
      description: message,
      actionLabel: 'Reintentar',
      onActionPressed: onRetryPressed,
      variant: _AgendaStateCardVariant.error,
    );
  }
}

class _AgendaStateCard extends StatelessWidget {
  const _AgendaStateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.variant,
    this.actionLabel,
    this.onActionPressed,
  });

  final Widget icon;
  final String title;
  final String description;
  final _AgendaStateCardVariant variant;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final palette = switch (variant) {
      _AgendaStateCardVariant.brand => (
        surface: theme.colors.background.brandSurface,
        content: theme.colors.text.brandDefault,
        border: theme.colors.border.brandAlternative,
      ),
      _AgendaStateCardVariant.warning => (
        surface: theme.colors.background.warningSurface,
        content: theme.colors.text.warningDefault,
        border: theme.colors.border.warningDefault,
      ),
      _AgendaStateCardVariant.error => (
        surface: theme.colors.background.errorSurface,
        content: theme.colors.text.errorDefault,
        border: theme.colors.border.errorDefault,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(theme.borderRadius.radius3xl),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(color: palette.content),
              child: icon,
            ),
            SizedBox(height: theme.spacing.spacingM),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.typography.styles.title.sm.semibold.copyWith(
                color: theme.colors.text.neutralTitle,
              ),
            ),
            SizedBox(height: theme.spacing.spacingXs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.typography.styles.body.sm.regular.copyWith(
                color: theme.colors.text.neutralBody,
              ),
            ),
            if (actionLabel != null) ...[
              SizedBox(height: theme.spacing.spacingM),
              TextButton(onPressed: onActionPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
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
        const _Skeleton(height: 112),
        SizedBox(height: spacing.spacingL),
        const _Skeleton(height: 52),
        SizedBox(height: spacing.spacing2xl),
        const _Skeleton(height: 112),
        SizedBox(height: spacing.spacingM),
        const _Skeleton(height: 112),
        SizedBox(height: spacing.spacing2xl),
        const _Skeleton(height: 260),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height});

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

class _TemporalBadge extends StatelessWidget {
  const _TemporalBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colors.background.brandSurface,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.spacingM,
          vertical: theme.spacing.spacingXs,
        ),
        child: Text(
          label,
          style: theme.typography.styles.label.sm.semibold.copyWith(
            color: theme.colors.text.brandDefault,
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colors.background.warningSurface,
        shape: StadiumBorder(
          side: BorderSide(color: theme.colors.border.warningDefault),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.spacingM,
          vertical: theme.spacing.spacingXs,
        ),
        child: Text(
          label,
          style: theme.typography.styles.label.sm.semibold.copyWith(
            color: theme.colors.text.warningDefault,
          ),
        ),
      ),
    );
  }
}

class _CaregiverAvatar extends StatelessWidget {
  const _CaregiverAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background.neutralsSurface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.typography.styles.label.sm.semibold.copyWith(
            color: theme.colors.text.brandDefault,
          ),
        ),
      ),
    );
  }
}

void _emptyCallback() {}
