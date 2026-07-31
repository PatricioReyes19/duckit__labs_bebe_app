import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: BebeButton,
  path: '[Átomos]/Acciones',
)
Widget bebeButtonPlayground(BuildContext context) {
  final variant = context.knobs.object.dropdown<BebeButtonVariant>(
    label: 'Variante',
    options: BebeButtonVariant.values,
    initialOption: BebeButtonVariant.primary,
    labelBuilder: (value) => value.name,
  );

  final label = context.knobs.string(
    label: 'Texto',
    initialValue: 'Guardar registro',
  );

  final enabled = context.knobs.boolean(
    label: 'Habilitado',
    initialValue: true,
  );

  final loading = context.knobs.boolean(
    label: 'Loading',
    initialValue: false,
  );

  final withIcon = context.knobs.boolean(
    label: 'Con icono',
    initialValue: true,
  );

  return UseCaseFrame(
    child: BebeButton(
      label: label,
      variant: variant,
      isLoading: loading,
      leading: withIcon ? const Icon(Icons.add_circle_outline) : null,
      onPressed: enabled ? () {} : null,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Todas las variantes',
  type: BebeButton,
  path: '[Átomos]/Acciones',
)
Widget bebeButtonVariants(BuildContext context) {
  return UseCaseFrame(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final variant in BebeButtonVariant.values) ...[
          BebeButton(
            label: variant.name,
            variant: variant,
            onPressed: () {},
          ),
          const SizedBox(height: 16),
        ],
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Texto largo y escala',
  type: BebeButton,
  path: '[Átomos]/Accesibilidad',
)
Widget bebeButtonLongText(BuildContext context) {
  return UseCaseFrame(
    width: 320,
    child: BebeButton(
      label: 'Guardar el registro y sincronizarlo con todos los cuidadores',
      onPressed: () {},
    ),
  );
}
