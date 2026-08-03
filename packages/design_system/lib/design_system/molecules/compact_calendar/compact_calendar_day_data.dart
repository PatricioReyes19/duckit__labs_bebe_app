import 'package:flutter/widgets.dart';

@immutable
class BebeCompactCalendarDayData {
  const BebeCompactCalendarDayData({
    required this.id,
    required this.label,
    this.indicators = const [],
    this.isCurrentMonth = true,
    this.isToday = false,
    this.enabled = true,
    this.semanticLabel,
  });

  final String id;
  final String label;
  final List<Widget> indicators;
  final bool isCurrentMonth;
  final bool isToday;
  final bool enabled;
  final String? semanticLabel;
}

@immutable
class BebeCompactCalendarWeekdayData {
  const BebeCompactCalendarWeekdayData({
    required this.label,
    this.semanticLabel,
  });

  final String label;
  final String? semanticLabel;
}
