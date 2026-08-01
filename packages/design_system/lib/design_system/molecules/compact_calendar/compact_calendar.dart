import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'compact_calendar_day_data.dart';

class BebeCompactCalendar extends StatelessWidget {
  const BebeCompactCalendar({
    required this.monthLabel,
    required this.weekdays,
    required this.days,
    required this.selectedDayId,
    required this.onDayPressed,
    this.onPreviousMonthPressed,
    this.onNextMonthPressed,
    this.previousMonthSemanticLabel = 'Mes anterior',
    this.nextMonthSemanticLabel = 'Mes siguiente',
    this.semanticLabel,
    super.key,
  });

  final String monthLabel;
  final List<BebeCompactCalendarWeekdayData> weekdays;
  final List<BebeCompactCalendarDayData> days;
  final String? selectedDayId;

  final ValueChanged<String> onDayPressed;
  final VoidCallback? onPreviousMonthPressed;
  final VoidCallback? onNextMonthPressed;

  final String previousMonthSemanticLabel;
  final String nextMonthSemanticLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(
      weekdays.length == 7,
      'BebeCompactCalendar requires exactly seven weekdays.',
    );

    assert(days.isNotEmpty, 'BebeCompactCalendar requires at least one day.');

    assert(
      days.length % 7 == 0,
      'The supplied days must complete full calendar weeks.',
    );

    assert(
      selectedDayId == null || days.any((day) => day.id == selectedDayId),
      'selectedDayId must match one of the supplied days.',
    );

    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;
    final colors = theme.colors;

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Calendario de $monthLabel',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background.neutralsSurface,
          borderRadius: BorderRadius.circular(radius.radius3xl),
          border: Border.all(color: colors.border.accentAlternative),
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CompactCalendarHeader(
                monthLabel: monthLabel,
                onPreviousPressed: onPreviousMonthPressed,
                onNextPressed: onNextMonthPressed,
                previousSemanticLabel: previousMonthSemanticLabel,
                nextSemanticLabel: nextMonthSemanticLabel,
              ),
              SizedBox(height: spacing.spacingL),
              _CompactCalendarWeekdays(weekdays: weekdays),
              SizedBox(height: spacing.spacingS),
              _CompactCalendarGrid(
                days: days,
                selectedDayId: selectedDayId,
                onDayPressed: onDayPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactCalendarHeader extends StatelessWidget {
  const _CompactCalendarHeader({
    required this.monthLabel,
    required this.onPreviousPressed,
    required this.onNextPressed,
    required this.previousSemanticLabel,
    required this.nextSemanticLabel,
  });

  final String monthLabel;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;
  final String previousSemanticLabel;
  final String nextSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final typography = theme.typography;
    final colors = theme.colors;

    return Row(
      children: [
        BebeNavigationIconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          semanticLabel: previousSemanticLabel,
          size: BebeNavigationIconButtonSize.small,
          onPressed: onPreviousPressed,
        ),
        Expanded(
          child: Text(
            monthLabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.styles.label.md.semibold.copyWith(
              color: colors.text.neutralTitle,
            ),
          ),
        ),
        BebeNavigationIconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          semanticLabel: nextSemanticLabel,
          size: BebeNavigationIconButtonSize.small,
          onPressed: onNextPressed,
        ),
      ],
    );
  }
}

class _CompactCalendarWeekdays extends StatelessWidget {
  const _CompactCalendarWeekdays({required this.weekdays});

  final List<BebeCompactCalendarWeekdayData> weekdays;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final typography = theme.typography;
    final colors = theme.colors;

    return Row(
      children: [
        for (final weekday in weekdays)
          Expanded(
            child: Semantics(
              label: weekday.semanticLabel ?? weekday.label,
              child: ExcludeSemantics(
                child: Text(
                  weekday.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: typography.styles.label.sm.regular.copyWith(
                    color: colors.text.neutralBody,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompactCalendarGrid extends StatelessWidget {
  const _CompactCalendarGrid({
    required this.days,
    required this.selectedDayId,
    required this.onDayPressed,
  });

  final List<BebeCompactCalendarDayData> days;
  final String? selectedDayId;
  final ValueChanged<String> onDayPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final weekCount = days.length ~/ 7;

    return Column(
      children: [
        for (var weekIndex = 0; weekIndex < weekCount; weekIndex++) ...[
          Row(
            children: [
              for (var dayIndex = 0; dayIndex < 7; dayIndex++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.spacingXs),
                    child: _CompactCalendarDay(
                      data: days[weekIndex * 7 + dayIndex],
                      isSelected:
                          days[weekIndex * 7 + dayIndex].id == selectedDayId,
                      onPressed: onDayPressed,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CompactCalendarDay extends StatelessWidget {
  const _CompactCalendarDay({
    required this.data,
    required this.isSelected,
    required this.onPressed,
  });

  final BebeCompactCalendarDayData data;
  final bool isSelected;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;
    final overlays = theme.overlays;

    final backgroundColor = isSelected
        ? colors.background.brandDefault
        : Colors.transparent;

    final contentColor = !data.enabled
        ? colors.text.neutralDisabled
        : isSelected
        ? colors.background.neutralsSurface
        : data.isCurrentMonth
        ? colors.text.neutralTitle
        : colors.text.neutralDisabled;

    final content = Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.enabled ? () => onPressed(data.id) : null,
        customBorder: const CircleBorder(),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return overlays.interactionPressed;
          }

          if (states.contains(WidgetState.hovered)) {
            return overlays.interactionHover;
          }

          if (states.contains(WidgetState.focused)) {
            return overlays.interactionFocus;
          }

          return null;
        }),
        child: Padding(
          padding: EdgeInsets.all(spacing.spacingS),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: typography.styles.label.sm.regular.copyWith(
                  color: contentColor,
                ),
              ),
              SizedBox(height: spacing.spacingXs),
              _CompactDayIndicators(indicators: data.indicators),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: data.enabled,
      label:
          data.semanticLabel ??
          '${data.label}'
              '${data.isToday ? '. Hoy' : ''}'
              '${isSelected ? '. Seleccionado' : ''}',
      child: ExcludeSemantics(child: content),
    );
  }
}

class _CompactDayIndicators extends StatelessWidget {
  const _CompactDayIndicators({required this.indicators});

  final List<Widget> indicators;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    if (indicators.isEmpty) {
      return SizedBox(height: 6 / 2);
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing.spacingXs,
      children: indicators,
    );
  }
}
