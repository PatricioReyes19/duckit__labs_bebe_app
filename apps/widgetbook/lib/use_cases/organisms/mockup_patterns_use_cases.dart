import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Tres métricas',
  type: BebeMetricsOverview,
  path: '[Organismos]/Resumen',
)
Widget bebeMetricsOverviewDefault(BuildContext context) {
  return UseCaseFrame(
    width: 380,
    child: BebeMetricsOverview(
      title: 'Resumen del informe',
      children: [
        BebeCompactMetricCard(
          label: 'Peso',
          value: '7,25',
          unit: 'kg',
          icon: Icon(Icons.monitor_weight_outlined),
        ),
        BebeCompactMetricCard(
          label: 'Talla',
          value: '66',
          unit: 'cm',
          icon: Icon(Icons.straighten_outlined),
        ),
        BebeCompactMetricCard(
          label: 'Controles',
          value: '4',
          icon: Icon(Icons.medical_services_outlined),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Éxito',
  type: BebeStatePanel,
  path: '[Organismos]/Estados',
)
Widget bebeStatePanelSuccess(BuildContext context) {
  return UseCaseFrame(
    width: 380,
    child: BebeStatePanel(
      title: 'Registro guardado',
      description:
          'La información ya está disponible para el círculo de cuidado.',
      variant: BebeStatePanelVariant.success,
      primaryActionLabel: 'Volver al inicio',
      onPrimaryActionPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Historial del día',
  type: BebeTimeline,
  path: '[Organismos]/Historial',
)
Widget bebeTimelineDefault(BuildContext context) {
  return UseCaseFrame(
    width: 420,
    child: BebeTimeline(
      entries: [
        BebeTimelineEntry(
          timeLabel: '09:30',
          title: 'Alimentación',
          description: 'Lactancia · 18 min',
          icon: const Icon(Icons.local_drink_outlined),
          variant: BebeLeadingIconVariant.brand,
          onPressed: () {},
        ),
        BebeTimelineEntry(
          timeLabel: '08:10',
          title: 'Cambio de pañal',
          description: 'Orina · cantidad normal',
          icon: const Icon(Icons.baby_changing_station_outlined),
          variant: BebeLeadingIconVariant.warning,
          onPressed: () {},
        ),
      ],
    ),
  );
}
