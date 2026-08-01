import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Resumen completo',
  type: BebeTodaySummary,
  path: '[Organisms]/Home',
)
Widget todaySummaryDefault(BuildContext context) {
  const metrics = [
    BebeTodayMetricData(
      type: BebeTodayMetricType.feeding,
      label: 'Alimentación',
      value: '5',
      unit: 'tomas',
      lastLabel: 'Última hace',
      lastValue: '2 h 10 min',
      icon: Icon(LucideIcons.milk),
    ),
    BebeTodayMetricData(
      type: BebeTodayMetricType.sleep,
      label: 'Sueño',
      value: '3',
      unit: 'h 45 min',
      lastLabel: 'Último hoy',
      lastValue: '07:30',
      icon: Icon(LucideIcons.moon),
    ),
    BebeTodayMetricData(
      type: BebeTodayMetricType.diaper,
      label: 'Pañales',
      value: '6',
      unit: 'cambios',
      lastLabel: 'Última hace',
      lastValue: '45 min',
      icon: Icon(LucideIcons.baby),
    ),
  ];
  return UseCaseFrame(
    width: double.infinity,
    child: BebeTodaySummary(
      items: metrics,
      onViewMorePressed: () {},
    ),
  );
}
