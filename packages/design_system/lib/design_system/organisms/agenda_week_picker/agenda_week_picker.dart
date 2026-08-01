import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
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
  final String locale;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel ?? 'Agenda semanal',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: BebeWeekCalendar(
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
          ),
        ],
      ),
    );
  }
}
