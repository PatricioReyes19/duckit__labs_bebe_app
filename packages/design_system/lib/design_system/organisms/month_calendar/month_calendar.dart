import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class BebeMonthCalendar extends StatelessWidget {
  const BebeMonthCalendar({
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    this.markersForDay,
    this.enabledDayPredicate,
    this.onPreviousMonthPressed,
    this.onNextMonthPressed,
    this.locale = 'es_CL',
    this.startingDayOfWeek = StartingDayOfWeek.monday,
    this.showContainer = true,
    this.semanticLabel,
    super.key,
  });

  final DateTime firstDay;

  final DateTime lastDay;

  final DateTime focusedDay;

  final DateTime? selectedDay;

  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  final ValueChanged<DateTime> onPageChanged;

  final List<BebeCalendarMarkerData> Function(DateTime day)? markersForDay;

  final bool Function(DateTime day)? enabledDayPredicate;

  final VoidCallback? onPreviousMonthPressed;
  final VoidCallback? onNextMonthPressed;

  final String locale;
  final StartingDayOfWeek startingDayOfWeek;

  final bool showContainer;

  final String? semanticLabel;

  static const double _rowHeight = 38;
  static const double _daysOfWeekHeight = 22;
  static const double _selectedDaySize = 30;
  static const double _navigationIconSize = 18;

  @override
  Widget build(BuildContext context) {
    assert(
      !lastDay.isBefore(firstDay),
      'lastDay must be equal to or after firstDay.',
    );

    assert(
      !focusedDay.isBefore(firstDay) && !focusedDay.isAfter(lastDay),
      'focusedDay must be between firstDay and lastDay.',
    );

    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;
    final colors = theme.colors;

    final monthLabel = _formatMonth(focusedDay, locale);

    final calendarContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MonthCalendarHeader(
          monthLabel: monthLabel,
          onPreviousPressed: onPreviousMonthPressed,
          onNextPressed: onNextMonthPressed,
        ),
        SizedBox(height: spacing.spacingM),
        TableCalendar<BebeCalendarMarkerData>(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: focusedDay,
          currentDay: DateTime.now(),
          locale: locale,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: startingDayOfWeek,
          headerVisible: false,
          daysOfWeekVisible: true,
          sixWeekMonthsEnforced: false,
          shouldFillViewport: false,
          availableGestures: AvailableGestures.horizontalSwipe,
          rowHeight: _rowHeight,
          daysOfWeekHeight: _daysOfWeekHeight,
          selectedDayPredicate: (day) {
            return selectedDay != null && isSameDay(selectedDay, day);
          },
          enabledDayPredicate: enabledDayPredicate,
          eventLoader: _markersForDay,
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          calendarStyle: const CalendarStyle(
            markersMaxCount: 0,
            cellMargin: EdgeInsets.zero,
            cellPadding: EdgeInsets.zero,
            outsideDaysVisible: true,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.typography.styles.label.sm.regular.copyWith(
              color: colors.text.neutralBody,
            ),
            weekendStyle: theme.typography.styles.label.sm.regular.copyWith(
              color: colors.text.neutralBody,
            ),
            dowTextFormatter: (date, effectiveLocale) {
              return _weekdayInitial(date, effectiveLocale);
            },
          ),
          calendarBuilders: CalendarBuilders<BebeCalendarMarkerData>(
            defaultBuilder: (context, day, focusedDay) {
              return _MonthCalendarDay(day: day, markers: _markersForDay(day));
            },
            todayBuilder: (context, day, focusedDay) {
              return _MonthCalendarDay(
                day: day,
                isToday: true,
                markers: _markersForDay(day),
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return _MonthCalendarDay(
                day: day,
                isSelected: true,
                isToday: isSameDay(day, DateTime.now()),
                markers: _markersForDay(day),
              );
            },
            outsideBuilder: (context, day, focusedDay) {
              return _MonthCalendarDay(
                day: day,
                isOutside: true,
                markers: _markersForDay(day),
              );
            },
            disabledBuilder: (context, day, focusedDay) {
              return _MonthCalendarDay(
                day: day,
                isDisabled: true,
                isOutside: day.month != focusedDay.month,
              );
            },
            markerBuilder: (context, day, events) {
              // Los marcadores se renderizan dentro
              // de _MonthCalendarDay.
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );

    final content = Padding(
      padding: showContainer
          ? EdgeInsets.all(spacing.spacingL)
          : EdgeInsets.zero,
      child: calendarContent,
    );

    final calendar = showContainer
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background.neutralsSurface,
              borderRadius: BorderRadius.circular(radius.radius3xl),
              border: Border.all(color: colors.border.accentAlternative),
            ),
            child: content,
          )
        : content;

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Calendario de $monthLabel',
      child: SizedBox(width: double.infinity, child: calendar),
    );
  }

  List<BebeCalendarMarkerData> _markersForDay(DateTime day) {
    return markersForDay?.call(day) ?? const <BebeCalendarMarkerData>[];
  }

  String _formatMonth(DateTime date, String locale) {
    final formatted = DateFormat.yMMMM(locale).format(date);

    return _capitalize(formatted);
  }

  String _weekdayInitial(DateTime date, String? locale) {
    final formatted = DateFormat.E(locale ?? this.locale).format(date);

    if (formatted.isEmpty) {
      return formatted;
    }

    return formatted.characters.first.toUpperCase();
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value.characters.first.toUpperCase()}'
        '${value.characters.skip(1)}';
  }
}

class _MonthCalendarHeader extends StatelessWidget {
  const _MonthCalendarHeader({
    required this.monthLabel,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  final String monthLabel;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final typography = theme.typography;
    final colors = theme.colors;

    return Row(
      children: [
        BebeNavigationIconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: BebeMonthCalendar._navigationIconSize,
          ),
          semanticLabel: 'Mes anterior',
          size: BebeNavigationIconButtonSize.small,
          onPressed: onPreviousPressed,
        ),
        Expanded(
          child: Text(
            monthLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.styles.label.md.semibold.copyWith(
              color: colors.text.neutralTitle,
            ),
          ),
        ),
        BebeNavigationIconButton(
          icon: const Icon(
            Icons.chevron_right_rounded,
            size: BebeMonthCalendar._navigationIconSize,
          ),
          semanticLabel: 'Mes siguiente',
          size: BebeNavigationIconButtonSize.small,
          onPressed: onNextPressed,
        ),
      ],
    );
  }
}

class _MonthCalendarDay extends StatelessWidget {
  const _MonthCalendarDay({
    required this.day,
    this.markers = const [],
    this.isSelected = false,
    this.isToday = false,
    this.isOutside = false,
    this.isDisabled = false,
  });

  final DateTime day;
  final List<BebeCalendarMarkerData> markers;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final bool isDisabled;

  static const double _todayBorderWidth = 1;
  static const double _markerSize = 4;
  static const double _markerSpacing = 2;
  static const double _markersHeight = 5;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final typography = theme.typography;
    final colors = theme.colors;

    final Color contentColor;

    if (isDisabled || isOutside) {
      contentColor = colors.text.neutralDisabled;
    } else if (isSelected) {
      contentColor = colors.background.neutralsSurface;
    } else {
      contentColor = colors.text.neutralTitle;
    }

    final dayContent = SizedBox.square(
      dimension: BebeMonthCalendar._selectedDaySize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? colors.background.brandDefault
              : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(
                  color: colors.border.brandAlternative,
                  width: _todayBorderWidth,
                )
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            maxLines: 1,
            softWrap: false,
            style: typography.styles.label.sm.regular.copyWith(
              color: contentColor,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      selected: isSelected,
      enabled: !isDisabled,
      label: _buildSemanticLabel(),
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dayContent,
            BebeCalendarMarkers(
              markers: markers,
              maximumVisibleMarkers: 3,
              markerSize: _markerSize,
              markerSpacing: _markerSpacing,
              reservedHeight: _markersHeight,
            ),
          ],
        ),
      ),
    );
  }

  String _buildSemanticLabel() {
    final markerLabels = markers
        .map((marker) => marker.semanticLabel)
        .whereType<String>()
        .where((label) => label.trim().isNotEmpty)
        .toList(growable: false);

    final parts = <String>[
      DateFormat.yMMMMd('es_CL').format(day),
      if (isToday) 'Hoy',
      if (markerLabels.isNotEmpty)
        markerLabels.join(', ')
      else if (markers.isNotEmpty)
        '${markers.length} '
            '${markers.length == 1 ? 'evento' : 'eventos'}',
      if (isSelected) 'Seleccionado',
      if (isDisabled) 'No disponible',
    ];

    return parts.join('. ');
  }
}
