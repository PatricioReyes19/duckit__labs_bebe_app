import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Bebé activo',
  type: BebeActiveBabyHeader,
  path: '[Organismos]/Home',
)
Widget activeBabyHeaderDefault(BuildContext context) {
  final showSibling = context.knobs.boolean(
    label: 'Mostrar segundo bebé',
    initialValue: true,
  );

  return UseCaseFrame(
    width: 760,
    child: BebeActiveBabyHeader(
      name: 'Mateo Reyes',
      ageLabel: '2 meses',
      avatar: const AssetImage('assets/images/babies/mateo.png'),
      familyContextLabel: '2 bebés en la familia',
      sibling: showSibling
          ? const BebeSiblingSummaryData(
              name: 'Sofía',
              ageLabel: '8 meses',
              avatar: AssetImage('assets/images/babies/sofia.png'),
            )
          : null,
      onBabyPressed: () {},
      onSiblingPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Contenido extenso',
  type: BebeActiveBabyHeader,
  path: '[Organismos]/Accesibilidad',
)
Widget activeBabyHeaderLongText(BuildContext context) {
  return const UseCaseFrame(
    width: 340,
    child: BebeActiveBabyHeader(
      name: 'Maximiliano Benjamín Reyes González',
      ageLabel: '11 meses y 28 días',
      avatar: AssetImage('assets/images/babies/placeholder.png'),
      familyContextLabel: '4 bebés disponibles en 3 círculos de cuidado',
    ),
  );
}
