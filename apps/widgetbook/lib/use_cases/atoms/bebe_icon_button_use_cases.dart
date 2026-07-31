import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: BebeIconButton,
  path: '[Átomos]/Acciones',
)
Widget bebeIconButtonPlayground(BuildContext context) {
  final variant = context.knobs.object.dropdown<BebeIconButtonVariant>(
    label: 'Variante',
    options: BebeIconButtonVariant.values,
    initialOption: BebeIconButtonVariant.standard,
    labelBuilder: (value) => value.name,
  );

  final enabled = context.knobs.boolean(
    label: 'Habilitado',
    initialValue: true,
  );

  final selected = context.knobs.boolean(
    label: 'Seleccionado',
    initialValue: false,
  );

  return UseCaseFrame(
    child: BebeIconButton(
      icon: const Icon(Icons.notifications_none_rounded),
      semanticLabel: 'Notificaciones',
      variant: variant,
      isSelected: selected,
      onPressed: enabled ? () {} : null,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Área táctil mínima',
  type: BebeIconButton,
  path: '[Átomos]/Accesibilidad',
)
Widget bebeIconButtonTouchTarget(BuildContext context) {
  return const UseCaseFrame(
    child: DecoratedBox(
      decoration: BoxDecoration(color: Color(0x2207838C)),
      child: BebeIconButton(
        icon: Icon(Icons.arrow_back_rounded, size: 20),
        semanticLabel: 'Volver',
        onPressed: null,
      ),
    ),
  );
}
