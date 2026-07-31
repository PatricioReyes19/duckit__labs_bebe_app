import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Dos opciones',
  type: BebeSegmentedSelector<String>,
  path: '[Moléculas]/Selectores',
)
Widget bebeSegmentedTwoOptions(BuildContext context) {
  final selected = context.knobs.object.dropdown<String>(
    label: 'Seleccionado',
    options: const ['vacunas', 'controles'],
    initialOption: 'vacunas',
  );

  return UseCaseFrame(
    child: BebeSegmentedSelector<String>(
      items: const [
        BebeSegmentedItem(
          value: 'vacunas',
          label: 'Vacunas',
          icon: Icon(Icons.vaccines_outlined),
        ),
        BebeSegmentedItem(
          value: 'controles',
          label: 'Controles',
          icon: Icon(Icons.medical_services_outlined),
        ),
      ],
      selectedValue: selected,
      onChanged: (_) {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Texto largo',
  type: BebeSegmentedSelector<String>,
  path: '[Moléculas]/Accesibilidad',
)
Widget bebeSegmentedLongText(BuildContext context) {
  return UseCaseFrame(
    width: 320,
    child: BebeSegmentedSelector<String>(
      items: const [
        BebeSegmentedItem(
          value: 'home',
          label: 'Medición realizada en casa',
        ),
        BebeSegmentedItem(
          value: 'clinic',
          label: 'Medición realizada en consulta',
        ),
      ],
      selectedValue: 'home',
      allowWrap: true,
      onChanged: (_) {},
    ),
  );
}
