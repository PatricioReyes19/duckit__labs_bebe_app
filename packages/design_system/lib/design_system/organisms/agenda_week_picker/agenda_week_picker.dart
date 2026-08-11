import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class BebeAgendaWeekPicker extends StatelessWidget {
  const BebeAgendaWeekPicker({
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPreviousWeekPressed,
    required this.onNextWeekPressed,
    this.markersForDay,
    this.onPageChanged,
    this.onTodayPressed,
    this.locale = 'es_CL',
    this.semanticLabel,
    super.key,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime? selectedDay;

  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  final VoidCallback onPreviousWeekPressed;
  final VoidCallback onNextWeekPressed;

  final List<BebeCalendarMarkerData> Function(DateTime day)? markersForDay;

  final ValueChanged<DateTime>? onPageChanged;
  final VoidCallback? onTodayPressed;
  final String locale;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel ?? 'Agenda semanal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: context.theme.spacing.spacingS,
              right: context.theme.spacing.spacingXs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _monthLabel(focusedDay),
                    style: context.theme.typography.styles.title.sm.semibold
                        .copyWith(
                          color: context.theme.colors.text.neutralTitle,
                        ),
                  ),
                ),
                if (onTodayPressed != null)
                  TextButton.icon(
                    onPressed: onTodayPressed,
                    icon: const Icon(Icons.today_outlined, size: 18),
                    label: const Text('Hoy'),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.theme.spacing.spacingS),
          BebeWeekCalendar(
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: focusedDay,
            selectedDay: selectedDay,
            locale: locale,
            markersForDay: markersForDay,
            onDaySelected: onDaySelected,
            onPageChanged: onPageChanged,
            startingDayOfWeek: StartingDayOfWeek.monday,
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime value) {
    final label = DateFormat.yMMMM(locale).format(value);
    return label.isEmpty
        ? ''
        : '${label[0].toUpperCase()}${label.substring(1)}';
  }
}
