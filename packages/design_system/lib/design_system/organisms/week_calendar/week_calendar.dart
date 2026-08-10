import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class BebeCalendarMarkerData {
  const BebeCalendarMarkerData({
    required this.id,
    required this.color,
    this.semanticLabel,
  });

  /// Identificador estable del indicador.
  ///
  /// Ejemplos:
  /// vaccine
  /// control
  /// medication
  final String id;

  /// El color es explícito porque la iconografía y los indicadores
  /// calendáricos no se resolverán desde el tema.
  final Color color;

  /// Descripción accesible opcional.
  final String? semanticLabel;
}

class BebeWeekCalendar extends StatelessWidget {
  const BebeWeekCalendar({
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.markersForDay,
    this.onPageChanged,
    this.locale = 'es_CL',
    this.startingDayOfWeek = StartingDayOfWeek.monday,
    this.semanticLabel,
    super.key,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime? selectedDay;

  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  /// Indicadores visuales de cada fecha.
  final List<BebeCalendarMarkerData> Function(DateTime day)? markersForDay;

  /// Se ejecuta cuando cambia la semana enfocada.
  final ValueChanged<DateTime>? onPageChanged;

  final String locale;
  final StartingDayOfWeek startingDayOfWeek;
  final String? semanticLabel;

  static const double _calendarHeight = 104;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final colors = theme.colors;

    final calendar = Material(
      color: colors.background.neutralsSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: BorderSide(color: colors.border.accentAlternative),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: _calendarHeight,
        child: TableCalendar<BebeCalendarMarkerData>(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: focusedDay,
          locale: locale,
          calendarFormat: CalendarFormat.week,
          headerVisible: false,
          daysOfWeekVisible: false,
          startingDayOfWeek: startingDayOfWeek,
          availableGestures: AvailableGestures.horizontalSwipe,
          rowHeight: _calendarHeight,
          selectedDayPredicate: (day) {
            return selectedDay != null && isSameDay(selectedDay, day);
          },
          eventLoader: (day) {
            return markersForDay?.call(day) ?? const <BebeCalendarMarkerData>[];
          },
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: true,
            markersMaxCount: 0,
            cellMargin: EdgeInsets.zero,
            cellPadding: EdgeInsets.zero,
          ),
          calendarBuilders: CalendarBuilders<BebeCalendarMarkerData>(
            defaultBuilder: (context, day, focusedDay) {
              return BebeWeekCalendarDay(
                day: day,
                markers:
                    markersForDay?.call(day) ??
                    const <BebeCalendarMarkerData>[],
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return BebeWeekCalendarDay(
                day: day,
                isToday: true,
                markers:
                    markersForDay?.call(day) ??
                    const <BebeCalendarMarkerData>[],
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return BebeWeekCalendarDay(
                day: day,
                isSelected: true,
                isToday: isSameDay(day, DateTime.now()),
                markers:
                    markersForDay?.call(day) ??
                    const <BebeCalendarMarkerData>[],
              );
            },
            outsideBuilder: (context, day, focusedDay) {
              return BebeWeekCalendarDay(
                day: day,
                isOutside: true,
                markers:
                    markersForDay?.call(day) ??
                    const <BebeCalendarMarkerData>[],
              );
            },
            markerBuilder: (context, day, events) {
              // Los indicadores ya se dibujan dentro
              // de BebeWeekCalendarDay.
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Selector semanal',
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.radius3xl),
            boxShadow: elevation.low,
          ),
          child: calendar,
        ),
      ),
    );
  }
}

class BebeWeekCalendarDay extends StatelessWidget {
  const BebeWeekCalendarDay({
    required this.day,
    this.markers = const [],
    this.isSelected = false,
    this.isToday = false,
    this.isOutside = false,
    super.key,
  });

  final DateTime day;
  final List<BebeCalendarMarkerData> markers;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;

  static const double _selectedRadius = 20;
  static const double _horizontalPadding = 5;
  static const double _verticalPadding = 8;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    final weekdayLabel = _capitalize(DateFormat.E('es_CL').format(day));

    final selectedContentColor = colors.background.neutralsSurface;

    final regularContentColor = isOutside
        ? colors.text.neutralDisabled
        : colors.text.neutralTitle;

    final foregroundColor = isSelected
        ? selectedContentColor
        : regularContentColor;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? colors.background.brandDefault : Colors.transparent,
        borderRadius: BorderRadius.circular(_selectedRadius),
        border: isToday && !isSelected
            ? Border.all(color: colors.border.brandAlternative)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdayLabel,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: typography.styles.label.sm.regular.copyWith(
                color: foregroundColor,
              ),
            ),
            SizedBox(height: spacing.spacingS),
            Text(
              '${day.day}',
              maxLines: 1,
              softWrap: false,
              style: isSelected
                  ? typography.styles.title.lg.bold.copyWith(
                      color: foregroundColor,
                    )
                  : typography.styles.title.md.semibold.copyWith(
                      color: foregroundColor,
                    ),
            ),
            SizedBox(height: spacing.spacingS),
            BebeWeekCalendarMarkers(markers: markers),
          ],
        ),
      ),
    );

    return Semantics(
      selected: isSelected,
      label: _semanticLabel(
        day: day,
        markers: markers,
        isToday: isToday,
        isSelected: isSelected,
      ),
      child: ExcludeSemantics(
        child: SizedBox(
          width: 80,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.spacingXs),
            child: content,
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _semanticLabel({
    required DateTime day,
    required List<BebeCalendarMarkerData> markers,
    required bool isToday,
    required bool isSelected,
  }) {
    final parts = <String>[
      DateFormat.yMMMMEEEEd('es_CL').format(day),
      if (isToday) 'Hoy',
      if (markers.isNotEmpty)
        '${markers.length} '
            '${markers.length == 1 ? 'evento' : 'eventos'}',
      if (isSelected) 'Seleccionado',
    ];

    return parts.join('. ');
  }
}

class BebeWeekCalendarMarkers extends StatelessWidget {
  const BebeWeekCalendarMarkers({required this.markers, super.key});

  final List<BebeCalendarMarkerData> markers;

  static const int _maximumVisibleMarkers = 3;
  static const double _markerSize = 15;
  static const double _markerSpacing = 3;
  static const double _reservedHeight = 6;

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      return const SizedBox(height: _reservedHeight);
    }

    final visibleMarkers = markers
        .take(_maximumVisibleMarkers)
        .toList(growable: false);

    return SizedBox(
      height: _reservedHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < visibleMarkers.length; index++) ...[
            ExcludeSemantics(
              child: SizedBox.square(
                dimension: _markerSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: visibleMarkers[index].color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            if (index != visibleMarkers.length - 1)
              const SizedBox(width: _markerSpacing),
          ],
        ],
      ),
    );
  }
}
