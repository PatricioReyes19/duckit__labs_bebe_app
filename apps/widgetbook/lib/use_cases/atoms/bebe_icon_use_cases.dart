import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: BebeIcon,
  path: '[Átomos]/Iconografía',
)
Widget bebeIconPlayground(BuildContext context) {
  final size = context.knobs.object.dropdown<BebeIconSize>(
    label: 'Tamaño',
    options: BebeIconSize.values,
    initialOption: BebeIconSize.md,
    labelBuilder: (value) => value.name,
  );

  return UseCaseFrame(
    child: BebeIcon.material(
      icon: Icons.notifications_none_rounded,
      size: size,
      semanticLabel: 'Notificaciones',
    ),
  );
}

@widgetbook.UseCase(
  name: 'Escala completa',
  type: BebeIcon,
  path: '[Átomos]/Iconografía',
)
Widget bebeIconSizes(BuildContext context) {
  return UseCaseFrame(
    child: Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        for (final size in BebeIconSize.values)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BebeIcon.material(
                icon: Icons.child_care_rounded,
                size: size,
                semanticLabel: 'Cuidado infantil',
              ),
              const SizedBox(height: 8),
              Text(size.name),
            ],
          ),
      ],
    ),
  );
}
