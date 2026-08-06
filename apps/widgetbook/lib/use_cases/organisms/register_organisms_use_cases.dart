import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Seis categorías',
  type: BebeRegisterCategorySelector<String>,
  path: '[Organismos]/Registro',
)
Widget registerCategorySelectorUseCase(BuildContext context) => UseCaseFrame(
      width: 390,
      child: BebeRegisterCategorySelector<String>(
        items: const [
          BebeRegisterCategoryItem(
            value: 'feeding',
            label: 'Alimentación',
            icon: Icon(Icons.local_drink_outlined),
            variant: BebeCategoryActionTileVariant.feeding,
          ),
          BebeRegisterCategoryItem(
            value: 'sleep',
            label: 'Sueño',
            icon: Icon(Icons.bedtime_outlined),
            variant: BebeCategoryActionTileVariant.sleep,
          ),
          BebeRegisterCategoryItem(
            value: 'diaper',
            label: 'Pañal',
            icon: Icon(Icons.child_friendly_outlined),
            variant: BebeCategoryActionTileVariant.diaper,
          ),
          BebeRegisterCategoryItem(
            value: 'observation',
            label: 'Observación',
            icon: Icon(Icons.edit_outlined),
            variant: BebeCategoryActionTileVariant.observation,
          ),
          BebeRegisterCategoryItem(
            value: 'medication',
            label: 'Medicina',
            icon: Icon(Icons.medication_outlined),
            variant: BebeCategoryActionTileVariant.medication,
          ),
          BebeRegisterCategoryItem(
            value: 'measurement',
            label: 'Medición',
            icon: Icon(Icons.straighten_outlined),
            variant: BebeCategoryActionTileVariant.measurement,
          ),
        ],
        selectedValue: 'feeding',
        onChanged: (_) {},
      ),
    );

@widgetbook.UseCase(
  name: 'Sección',
  type: BebeRegisterFormSection,
  path: '[Organismos]/Registro',
)
Widget registerFormSectionUseCase(BuildContext context) => const UseCaseFrame(
      child: BebeRegisterFormSection(
        child: BebeTextField(label: 'Notas', hintText: 'Escribe algo…'),
      ),
    );

@widgetbook.UseCase(
  name: 'Guardar y cancelar',
  type: BebeRegisterActionBar,
  path: '[Organismos]/Registro',
)
Widget registerActionBarUseCase(BuildContext context) => UseCaseFrame(
      child: BebeRegisterActionBar(
        onSavePressed: () {},
        onCancelPressed: () {},
      ),
    );

@widgetbook.UseCase(
  name: 'Responsive 1–3 columnas',
  type: BebeResponsiveFormGrid,
  path: '[Organismos]/Registro',
)
Widget responsiveFormGridUseCase(BuildContext context) => UseCaseFrame(
      child: BebeResponsiveFormGrid(
        children: [
          BebePickerField(
            label: 'Inicio',
            value: '09:30',
            kind: BebePickerFieldKind.time,
            onPressed: () {},
          ),
          BebePickerField(
            label: 'Duración',
            value: '15 min',
            kind: BebePickerFieldKind.duration,
            onPressed: () {},
          ),
          BebePickerField(
            label: 'Término',
            value: '09:45',
            kind: BebePickerFieldKind.time,
            onPressed: () {},
          ),
        ],
      ),
    );
