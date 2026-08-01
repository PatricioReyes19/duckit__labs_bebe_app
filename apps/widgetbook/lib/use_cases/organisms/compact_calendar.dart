import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Calendario mensual',
  type: BebeMonthCalendar,
  path: '[Organisms]/Calendar',
)
Widget bebeMonthCalendarUseCase(
  BuildContext context,
) {
  return const _MonthCalendarExample();
}

class _MonthCalendarExample extends StatefulWidget {
  const _MonthCalendarExample();

  @override
  State<_MonthCalendarExample> createState() => _MonthCalendarExampleState();
}

class _MonthCalendarExampleState extends State<_MonthCalendarExample> {
  DateTime _focusedDay = DateTime(2026, 5, 20);
  DateTime? _selectedDay = DateTime(2026, 5, 20);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: BebeMonthCalendar(
          firstDay: DateTime(2025),
          lastDay: DateTime(2027, 12, 31),
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          markersForDay: _markersForDay,
          onDaySelected: (
            selectedDay,
            focusedDay,
          ) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          onPreviousMonthPressed: _goToPreviousMonth,
          onNextMonthPressed: _goToNextMonth,
        ),
      ),
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + 1,
      );
    });
  }

  List<BebeCalendarMarkerData> _markersForDay(
    DateTime day,
  ) {
    if (_isSameDate(day, DateTime(2026, 5, 12))) {
      return const [
        BebeCalendarMarkerData(
          id: 'control',
          color: Color(0xFF008F95),
          semanticLabel: 'Control',
        ),
      ];
    }

    if (_isSameDate(day, DateTime(2026, 5, 20))) {
      return const [
        BebeCalendarMarkerData(
          id: 'vaccine',
          color: Color(0xFF7E57C2),
          semanticLabel: 'Vacuna',
        ),
        BebeCalendarMarkerData(
          id: 'medication',
          color: Color(0xFFFF6F61),
          semanticLabel: 'Medicación',
        ),
      ];
    }

    if (_isSameDate(day, DateTime(2026, 5, 22))) {
      return const [
        BebeCalendarMarkerData(
          id: 'exam',
          color: Color(0xFF4285D4),
          semanticLabel: 'Examen',
        ),
      ];
    }

    return const [];
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
