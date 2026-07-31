import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: BebeBabySelector,
  path: '[Moléculas]/Contexto activo',
)
Widget bebeBabySelectorPlayground(BuildContext context) {
  final name = context.knobs.string(
    label: 'Nombre',
    initialValue: 'Mateo Reyes',
  );
  final age = context.knobs.string(
    label: 'Edad',
    initialValue: '2 meses',
  );
  final showContext = context.knobs.boolean(
    label: 'Mostrar contexto familiar',
    initialValue: true,
  );

  return UseCaseFrame(
    child: BebeBabySelector(
      name: name,
      ageLabel: age,
      contextLabel: showContext ? '2 bebés en la familia' : null,
      avatar: BebeAvatar.initials(
        initials: name,
        size: BebeAvatarSize.lg,
      ),
      isSelected: true,
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Nombre extenso',
  type: BebeBabySelector,
  path: '[Moléculas]/Accesibilidad',
)
Widget bebeBabySelectorLongName(BuildContext context) {
  return UseCaseFrame(
    width: 320,
    child: BebeBabySelector(
      name: 'Maximiliano Benjamín de los Ángeles Reyes González',
      ageLabel: '11 meses y 28 días',
      contextLabel: '4 bebés disponibles en 3 círculos de cuidado',
      avatar: const BebeAvatar.initials(
        initials: 'Maximiliano Reyes',
        size: BebeAvatarSize.lg,
      ),
      onPressed: () {},
      isSelected: true,
    ),
  );
}
