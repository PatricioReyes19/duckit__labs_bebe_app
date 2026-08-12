import 'package:agenda/agenda.dart';
import 'package:agenda/models/agenda_overview_vm.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({
    this.onNotificationsPressed,
    this.onConfigureRemindersPressed,
    this.onHealthPressed,
    this.onCreateReminderPressed,
    this.onRegisterPressed,
    this.onRegisterHistoryPressed,
    this.onEventPressed,
    super.key,
  });

  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onConfigureRemindersPressed;
  final VoidCallback? onHealthPressed;
  final VoidCallback? onCreateReminderPressed;
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onRegisterHistoryPressed;
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
            templateState:
                overview.connectionStatus == AgendaConnectionStatus.offline
                ? BebeAgendaTemplateState.offline
                : BebeAgendaTemplateState.content,
            onNotificationsPressed: onNotificationsPressed,
            onConfigureRemindersPressed: onConfigureRemindersPressed,
            onHealthPressed: onHealthPressed,
            onCreateReminderPressed: onCreateReminderPressed,
            onRegisterPressed: onRegisterPressed,
            onRegisterHistoryPressed: onRegisterHistoryPressed,
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
            onRegisterPressed: onRegisterPressed,
            onRegisterHistoryPressed: onRegisterHistoryPressed,
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
    this.onRegisterPressed,
    this.onRegisterHistoryPressed,
    this.onEventPressed,
  });

  final AgendaOverviewVm overview;
  final BebeAgendaTemplateState templateState;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onConfigureRemindersPressed;
  final VoidCallback? onHealthPressed;
  final VoidCallback? onCreateReminderPressed;
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onRegisterHistoryPressed;
  final ValueChanged<String>? onEventPressed;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AgendaBloc>();
    final spacing = context.theme.spacing;
    final todayEvents = overview.eventsFor(overview.selectedWeekDay);
    final dayRecords = overview.recordsFor(overview.selectedWeekDay);
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
        onTodayPressed: () {
          final today = DateTime.now();
          final day = DateTime(today.year, today.month, today.day);
          bloc.add(AgendaEvent.daySelected(selectedDay: day, focusedDay: day));
        },
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
      filters: _AgendaFullBleed(
        horizontalInset: spacing.spacingXl,
        child: BebeAgendaCategoryFilters(
          selectedId: overview.selectedCategory.name,
          onItemPressed: (id) => bloc.add(
            AgendaEvent.categorySelected(
              AgendaFilterCategory.values.firstWhere(
                (category) => category.name == id,
                orElse: () => AgendaFilterCategory.all,
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
      ),
      todaySection: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AgendaEventGroup(
            title: 'Programado',
            emptyMessage:
                'No hay eventos de esta categoría programados para este día.',
            events: todayEvents,
            onEventPressed: onEventPressed,
          ),
          SizedBox(height: spacing.spacing2xl),
          _RegisteredActivityGroup(
            events: dayRecords,
            onRegisterPressed: onRegisterPressed,
            onHistoryPressed: onRegisterHistoryPressed,
          ),
        ],
      ),
      upcomingSection: _AgendaEventGroup(
        title: 'Próximos días',
        emptyMessage: 'No hay próximos eventos para la categoría seleccionada.',
        events: upcomingEvents,
        scrollable: true,
        collapseRecurring: true,
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
      onRefresh: bloc.refreshFromRemote,
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
              icon: Icon(_eventIconData(next.category)),
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

class _AgendaFullBleed extends StatelessWidget {
  const _AgendaFullBleed({required this.child, required this.horizontalInset});

  final Widget child;
  final double horizontalInset;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth + horizontalInset * 2;
      return OverflowBox(
        minWidth: width,
        maxWidth: width,
        alignment: Alignment.center,
        fit: OverflowBoxFit.deferToChild,
        child: child,
      );
    },
  );
}

class _AgendaEventGroup extends StatelessWidget {
  const _AgendaEventGroup({
    required this.title,
    required this.emptyMessage,
    required this.events,
    this.scrollable = false,
    this.collapseRecurring = false,
    this.onEventPressed,
  });

  final String title;
  final String emptyMessage;
  final List<AgendaEventVm> events;
  final bool scrollable;
  final bool collapseRecurring;
  final ValueChanged<String>? onEventPressed;

  static const _maximumVisibleItems = 5;
  static const _compactCardHeight = 144.0;
  static const _regularCardHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final items = collapseRecurring
        ? _collapseRecurringEvents(events)
        : events.map(_AgendaEventListItem.single).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BebeTitleSection(title: title),
        SizedBox(height: spacing.spacingL),
        if (items.isEmpty)
          _AgendaSectionEmptyState(message: emptyMessage)
        else if (scrollable && items.length > _maximumVisibleItems)
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(
                context,
              ).scale(1).clamp(1.0, 1.4).toDouble();
              final estimatedCardHeight = constraints.maxWidth < 360
                  ? _compactCardHeight
                  : _regularCardHeight;
              final viewportHeight =
                  estimatedCardHeight * _maximumVisibleItems * textScale +
                  spacing.spacingM * (_maximumVisibleItems - 1);

              return SizedBox(
                key: const ValueKey('agenda-upcoming-scroll-viewport'),
                height: viewportHeight,
                child: Scrollbar(
                  child: ListView.separated(
                    key: const ValueKey('agenda-upcoming-scroll-list'),
                    primary: false,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(right: spacing.spacingXs),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: spacing.spacingM),
                    itemBuilder: (context, index) => _AgendaEventCard(
                      item: items[index],
                      onPressed: () =>
                          onEventPressed?.call(items[index].event.id),
                    ),
                  ),
                ),
              );
            },
          )
        else
          for (var index = 0; index < items.length; index++) ...[
            _AgendaEventCard(
              item: items[index],
              onPressed: () => onEventPressed?.call(items[index].event.id),
            ),
            if (index != items.length - 1) SizedBox(height: spacing.spacingM),
          ],
      ],
    );
  }
}

class _AgendaEventCard extends StatelessWidget {
  const _AgendaEventCard({required this.item, required this.onPressed});

  final _AgendaEventListItem item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final event = item.event;
    final recurrenceLabel = item.isRecurring
        ? _recurrenceLabel(event.description)
        : null;
    return BebeAgendaEventCard(
      time: BebeTimeBlock(
        dateLabel: _date(event.startsAt),
        timeLabel: _time(event.startsAt),
        size: BebeTimeBlockSize.small,
      ),
      icon: Icon(_eventIconData(event.category)),
      title: event.title,
      description: event.description,
      variant: _eventVariant(event.category),
      status: recurrenceLabel == null
          ? null
          : BebeStatusBadge(
              label: recurrenceLabel,
              variant: BebeStatusBadgeVariant.information,
              icon: const Icon(Icons.repeat_rounded),
              semanticLabel: [
                'Evento recurrente',
                recurrenceLabel,
                if (item.occurrenceCount > 1)
                  '${item.occurrenceCount} próximas ocurrencias agrupadas',
              ].join('. '),
            ),
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
      syncIndicator: event.syncStatus == AgendaSyncStatus.synced
          ? null
          : _SyncBadge(label: _agendaSyncLabel(event.syncStatus)),
      semanticLabel: [
        event.title,
        event.description,
        if (recurrenceLabel != null) 'Evento recurrente: $recurrenceLabel',
        if (item.occurrenceCount > 1)
          '${item.occurrenceCount} próximas ocurrencias agrupadas',
      ].join('. '),
      onPressed: onPressed,
    );
  }
}

class _AgendaEventListItem {
  _AgendaEventListItem.single(this.event) : occurrenceCount = 1;

  final AgendaEventVm event;
  int occurrenceCount;

  bool get isRecurring => event.isRecurring;
}

List<_AgendaEventListItem> _collapseRecurringEvents(
  List<AgendaEventVm> events,
) {
  final result = <_AgendaEventListItem>[];
  final seriesPositions = <String, int>{};
  for (final event in events) {
    final seriesId = event.sourceRegisterEventId?.trim();
    if (seriesId == null || seriesId.isEmpty) {
      result.add(_AgendaEventListItem.single(event));
      continue;
    }
    final position = seriesPositions[seriesId];
    if (position == null) {
      seriesPositions[seriesId] = result.length;
      result.add(_AgendaEventListItem.single(event));
    } else {
      result[position].occurrenceCount += 1;
    }
  }
  return result;
}

String _recurrenceLabel(String description) {
  final frequency = description
      .split('·')
      .map((part) => part.trim())
      .where((part) => part.startsWith('Cada ') || part == 'Una vez al día')
      .firstOrNull;
  return switch (frequency) {
    'Una vez al día' => 'Todos los días',
    final String value => value,
    null => 'Recurrente',
  };
}

class _RegisteredActivityGroup extends StatelessWidget {
  const _RegisteredActivityGroup({
    required this.events,
    this.onRegisterPressed,
    this.onHistoryPressed,
  });

  final List<AgendaRegisterEventVm> events;
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onHistoryPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Registros del día',
                style: theme.typography.styles.title.sm.semibold.copyWith(
                  color: theme.colors.text.neutralTitle,
                ),
              ),
            ),
            if (onHistoryPressed != null)
              TextButton(
                onPressed: onHistoryPressed,
                child: const Text('Ver historial'),
              ),
          ],
        ),
        SizedBox(height: theme.spacing.spacingM),
        if (events.isEmpty)
          _AgendaSectionEmptyState(
            message: 'Aún no hay actividad registrada para este día.',
          )
        else
          for (var index = 0; index < events.length; index++) ...[
            _RegisteredActivityCard(event: events[index]),
            if (index != events.length - 1)
              SizedBox(height: theme.spacing.spacingS),
          ],
        SizedBox(height: theme.spacing.spacingM),
        OutlinedButton.icon(
          onPressed: onRegisterPressed,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Registrar evento ahora'),
        ),
      ],
    );
  }
}

class _RegisteredActivityCard extends StatelessWidget {
  const _RegisteredActivityCard({required this.event});

  final AgendaRegisterEventVm event;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isPending = event.syncStatus != RegisterSyncStatus.synced;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(theme.borderRadius.radius3xl),
        border: Border.all(color: theme.colors.border.neutralDefault),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.spacingL),
        child: Row(
          children: [
            Icon(
              _registerIcon(event.type),
              color: theme.colors.icons.brandDefault,
            ),
            SizedBox(width: theme.spacing.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.typography.styles.body.md.semibold.copyWith(
                      color: theme.colors.text.neutralTitle,
                    ),
                  ),
                  SizedBox(height: theme.spacing.spacingXs),
                  Text(
                    '${_time(event.occurredAt)} · ${event.description}',
                    style: theme.typography.styles.body.sm.regular.copyWith(
                      color: theme.colors.text.neutralBody,
                    ),
                  ),
                ],
              ),
            ),
            if (isPending)
              _SyncBadge(label: _registerSyncLabel(event.syncStatus)),
          ],
        ),
      ),
    );
  }
}

IconData _registerIcon(RegisterEventType type) => switch (type) {
  RegisterEventType.feeding => Icons.local_drink_outlined,
  RegisterEventType.sleep => Icons.bedtime_outlined,
  RegisterEventType.diaper => Icons.baby_changing_station_outlined,
  RegisterEventType.clinicalObservation => Icons.edit_note_outlined,
  RegisterEventType.medication => Icons.medication_outlined,
  RegisterEventType.measurement => Icons.straighten_outlined,
};

String _agendaSyncLabel(AgendaSyncStatus status) => switch (status) {
  AgendaSyncStatus.synced => 'Sincronizado',
  AgendaSyncStatus.pending => 'Local',
  AgendaSyncStatus.syncing => 'Sincronizando',
  AgendaSyncStatus.failed => 'Reintentar',
};

String _registerSyncLabel(RegisterSyncStatus status) => switch (status) {
  RegisterSyncStatus.synced => 'Sincronizado',
  RegisterSyncStatus.pending => 'Local',
  RegisterSyncStatus.syncing => 'Sincronizando',
  RegisterSyncStatus.failed => 'Reintentar',
};

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

IconData _eventIconData(AgendaCategory category) => switch (category) {
  AgendaCategory.vaccines => Icons.vaccines_outlined,
  AgendaCategory.controls => Icons.medical_services_outlined,
  AgendaCategory.medication => Icons.medication_outlined,
  AgendaCategory.exams => Icons.science_outlined,
};

BebeAgendaEventCardVariant _eventVariant(AgendaCategory category) {
  return switch (category) {
    AgendaCategory.vaccines => BebeAgendaEventCardVariant.accent,
    AgendaCategory.controls => BebeAgendaEventCardVariant.information,
    AgendaCategory.medication => BebeAgendaEventCardVariant.warning,
    AgendaCategory.exams => BebeAgendaEventCardVariant.brand,
  };
}

BebeEventPreviewVariant _previewVariant(AgendaCategory category) {
  return switch (category) {
    AgendaCategory.vaccines => BebeEventPreviewVariant.accent,
    AgendaCategory.controls => BebeEventPreviewVariant.information,
    AgendaCategory.medication => BebeEventPreviewVariant.warning,
    AgendaCategory.exams => BebeEventPreviewVariant.brand,
  };
}

Color _markerColor(BuildContext context, AgendaCategory category) {
  final icons = context.theme.colors.icons;

  return switch (category) {
    AgendaCategory.vaccines => icons.accentDefault,
    AgendaCategory.controls => icons.brandDefault,
    AgendaCategory.medication => icons.warningDefault,
    AgendaCategory.exams => icons.infoDefault,
  };
}

String _categoryLabel(AgendaCategory category) => switch (category) {
  AgendaCategory.vaccines => 'Vacuna',
  AgendaCategory.controls => 'Control',
  AgendaCategory.medication => 'Medicación',
  AgendaCategory.exams => 'Examen',
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
      icon: Image.asset(
        BebeIllustrationAssets.emptyAgenda,
        package: BebeIllustrationAssets.packageName,
        height: 176,
        fit: BoxFit.contain,
        semanticLabel: 'Elefante bebé junto a un calendario vacío',
      ),
      title: 'Tu agenda está vacía',
      description:
          'Crea el primer recordatorio para una vacuna, control o medicamento.',
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

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Cargando componentes de la agenda',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AgendaWeekPickerSkeleton(),
            SizedBox(height: spacing.spacingL),
            const _AgendaFiltersSkeleton(),
            SizedBox(height: spacing.spacing2xl),
            const _AgendaSectionSkeleton(
              key: ValueKey('agenda-loading-today'),
              cardCount: 2,
            ),
            SizedBox(height: spacing.spacing2xl),
            const _AgendaSectionSkeleton(
              key: ValueKey('agenda-loading-upcoming'),
              cardCount: 2,
            ),
            SizedBox(height: spacing.spacing2xl),
            const _AgendaMonthlySkeleton(),
          ],
        ),
      ),
    );
  }
}

class _AgendaWeekPickerSkeleton extends StatelessWidget {
  const _AgendaWeekPickerSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      key: const ValueKey('agenda-loading-week-picker'),
      decoration: BoxDecoration(
        color: theme.colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(theme.borderRadius.radius3xl),
        border: Border.all(color: theme.colors.border.neutralDefault),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BebeSkeleton.line(width: 132, height: 16),
            SizedBox(height: theme.spacing.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var index = 0; index < 7; index++)
                  Column(
                    children: [
                      const BebeSkeleton.line(width: 18, height: 8),
                      SizedBox(height: theme.spacing.spacingS),
                      const BebeSkeleton.circle(size: 32),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaFiltersSkeleton extends StatelessWidget {
  const _AgendaFiltersSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return SizedBox(
      key: const ValueKey('agenda-loading-filters'),
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            for (final width in [88.0, 104.0, 96.0, 112.0]) ...[
              BebeSkeleton(
                width: width,
                height: 40,
                shape: BebeSkeletonShape.pill,
              ),
              SizedBox(width: spacing.spacingS),
            ],
          ],
        ),
      ),
    );
  }
}

class _AgendaSectionSkeleton extends StatelessWidget {
  const _AgendaSectionSkeleton({required this.cardCount, super.key});

  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BebeSkeleton.line(width: 144, height: 18),
        SizedBox(height: spacing.spacingL),
        for (var index = 0; index < cardCount; index++) ...[
          const _AgendaEventCardSkeleton(),
          if (index != cardCount - 1) SizedBox(height: spacing.spacingM),
        ],
      ],
    );
  }
}

class _AgendaEventCardSkeleton extends StatelessWidget {
  const _AgendaEventCardSkeleton();

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
        child: Row(
          children: [
            const BebeSkeleton.circle(size: 40),
            SizedBox(width: theme.spacing.spacingM),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BebeSkeleton.line(width: 156, height: 14),
                  SizedBox(height: 8),
                  BebeSkeleton.line(height: 10),
                  SizedBox(height: 6),
                  BebeSkeleton.line(width: 112, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaMonthlySkeleton extends StatelessWidget {
  const _AgendaMonthlySkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      key: const ValueKey('agenda-loading-monthly'),
      decoration: BoxDecoration(
        color: theme.colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(theme.borderRadius.radius3xl),
        border: Border.all(color: theme.colors.border.neutralDefault),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BebeSkeleton.line(width: 184, height: 18),
            SizedBox(height: theme.spacing.spacingL),
            for (var row = 0; row < 5; row++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var day = 0; day < 7; day++)
                    const BebeSkeleton.circle(size: 24),
                ],
              ),
              if (row != 4) SizedBox(height: theme.spacing.spacingS),
            ],
          ],
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
