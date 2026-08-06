import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Campo compuesto',
  type: BebeFormField,
  path: '[Moléculas]/Formularios',
)
Widget bebeFormFieldUseCase(BuildContext context) => const UseCaseFrame(
      child: BebeFormField(
        label: 'Nombre del medicamento',
        child: BebeTextField(hintText: 'Ej. Paracetamol'),
      ),
    );

@widgetbook.UseCase(
  name: 'Fecha, hora y selección',
  type: BebePickerField,
  path: '[Moléculas]/Formularios',
)
Widget bebePickerFieldUseCase(BuildContext context) => UseCaseFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BebePickerField(
            label: 'Fecha',
            value: '20 may 2024',
            kind: BebePickerFieldKind.date,
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          BebePickerField(
            label: 'Duración',
            value: '1 h 05 min',
            kind: BebePickerFieldKind.duration,
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          const BebePickerField(
            label: 'Fecha de término',
            value: '',
            placeholder: 'Selecciona una fecha',
            optional: true,
            kind: BebePickerFieldKind.date,
            onPressed: null,
          ),
        ],
      ),
    );

@widgetbook.UseCase(
  name: 'Notas',
  type: BebeNotesField,
  path: '[Moléculas]/Formularios',
)
Widget bebeNotesFieldUseCase(BuildContext context) => const UseCaseFrame(
      child: BebeNotesField(label: 'Síntomas / observaciones'),
    );

@widgetbook.UseCase(
  name: 'Selector segmentado con label',
  type: BebeSegmentedFormField<String>,
  path: '[Moléculas]/Formularios',
)
Widget bebeSegmentedFormFieldUseCase(BuildContext context) => UseCaseFrame(
      width: 320,
      child: BebeSegmentedFormField<String>(
        label: 'Estado de ánimo',
        items: const [
          BebeSegmentedItem(value: 'calm', label: 'Tranquilo'),
          BebeSegmentedItem(value: 'sleepy', label: 'Dormido'),
          BebeSegmentedItem(value: 'irritable', label: 'Irritable'),
        ],
        selectedValue: 'calm',
        onChanged: (_) {},
        allowWrap: true,
      ),
    );

@widgetbook.UseCase(
  name: 'Fotos vacío y con preview',
  type: BebePhotoPicker,
  path: '[Moléculas]/Formularios',
)
Widget bebePhotoPickerUseCase(BuildContext context) {
  final theme = context.theme;
  return UseCaseFrame(
    child: BebePhotoPicker(
      label: 'Fotos',
      items: [
        BebePhotoItem(
          id: 'preview',
          semanticLabel: 'Vista previa de observación',
          preview: ColoredBox(
            color: theme.colors.background.warningSurface,
            child: Icon(
              Icons.photo_outlined,
              color: theme.colors.icons.warningDefault,
            ),
          ),
        ),
      ],
      onAddPressed: () {},
      onRemovePressed: (_) {},
    ),
  );
}
