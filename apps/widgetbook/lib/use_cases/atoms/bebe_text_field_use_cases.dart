import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: BebeTextField,
  path: '[Átomos]/Formularios',
)
Widget bebeTextFieldPlayground(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Notas',
  );

  final hint = context.knobs.string(
    label: 'Placeholder',
    initialValue: 'Escribe algo...',
  );

  final enabled = context.knobs.boolean(
    label: 'Habilitado',
    initialValue: true,
  );

  final readOnly = context.knobs.boolean(
    label: 'Solo lectura',
    initialValue: false,
  );

  final multiline = context.knobs.boolean(
    label: 'Multiline',
    initialValue: false,
  );

  final error = context.knobs.stringOrNull(
    label: 'Error',
    initialValue: null,
  );

  return UseCaseFrame(
    child: BebeTextField(
      label: label,
      hintText: hint,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: multiline ? 4 : 1,
      maxLength: multiline ? 200 : null,
      errorText: error,
      leading: const Icon(Icons.edit_note_outlined),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Estados',
  type: BebeTextField,
  path: '[Átomos]/Formularios',
)
Widget bebeTextFieldStates(BuildContext context) {
  return const UseCaseFrame(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BebeTextField(
          label: 'Default',
          hintText: 'Escribe algo...',
        ),
        SizedBox(height: 20),
        BebeTextField(
          label: 'Error',
          hintText: 'Escribe algo...',
          errorText: 'Este campo es obligatorio',
        ),
        SizedBox(height: 20),
        BebeTextField(
          label: 'Disabled',
          hintText: 'No disponible',
          enabled: false,
        ),
      ],
    ),
  );
}
