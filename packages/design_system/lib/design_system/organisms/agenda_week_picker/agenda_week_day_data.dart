import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class BebeAgendaWeekDayData {
  const BebeAgendaWeekDayData({
    required this.id,
    required this.weekdayLabel,
    required this.dayLabel,
    this.indicators = const [],
    this.isToday = false,
    this.enabled = true,
    this.semanticLabel,
  });

  final String id;
  final String weekdayLabel;
  final String dayLabel;
  final List<Widget> indicators;
  final bool isToday;
  final bool enabled;
  final String? semanticLabel;
}
