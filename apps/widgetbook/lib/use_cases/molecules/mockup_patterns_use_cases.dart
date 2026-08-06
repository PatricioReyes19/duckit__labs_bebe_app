import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Métrica de informe',
  type: BebeCompactMetricCard,
  path: '[Moléculas]/Métricas',
)
Widget bebeCompactMetricCardDefault(BuildContext context) {
  return const UseCaseFrame(
    width: 180,
    child: BebeCompactMetricCard(
      label: 'Peso actual',
      value: '7,25',
      unit: 'kg',
      supportingText: 'Dentro del rango esperado',
      icon: Icon(Icons.monitor_weight_outlined),
      variant: BebeMetricCardVariant.success,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Tres pasos',
  type: BebeProgressSteps,
  path: '[Moléculas]/Progreso',
)
Widget bebeProgressStepsDefault(BuildContext context) {
  return UseCaseFrame(
    width: 360,
    child: BebeProgressSteps(
      currentIndex: 1,
      steps: [
        BebeProgressStep(label: 'Datos'),
        BebeProgressStep(label: 'Evaluación'),
        BebeProgressStep(label: 'Confirmación'),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Interactivo',
  type: BebeRatingSelector,
  path: '[Moléculas]/Valoración',
)
Widget bebeRatingSelectorDefault(BuildContext context) {
  return const UseCaseFrame(child: _RatingSelectorExample());
}

class _RatingSelectorExample extends StatefulWidget {
  const _RatingSelectorExample();

  @override
  State<_RatingSelectorExample> createState() => _RatingSelectorExampleState();
}

class _RatingSelectorExampleState extends State<_RatingSelectorExample> {
  int value = 4;

  @override
  Widget build(BuildContext context) {
    return BebeRatingSelector(
      label: '¿Cómo fue la atención?',
      value: value,
      valueLabel: 'Muy buena',
      onChanged: (next) => setState(() => value = next),
    );
  }
}
