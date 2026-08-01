import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Variantes',
  type: BebeFilterChip,
  path: '[Molecules]/Filters',
)
Widget filterChipVariants(BuildContext context) {
  return UseCaseFrame(
    width: 620,
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        BebeFilterChip(
          label: 'Neutral',
          isSelected: false,
          variant: BebeFilterChipVariant.neutral,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Brand',
          isSelected: false,
          variant: BebeFilterChipVariant.brand,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Accent',
          isSelected: false,
          variant: BebeFilterChipVariant.accent,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Información',
          isSelected: false,
          variant: BebeFilterChipVariant.information,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Éxito',
          isSelected: false,
          variant: BebeFilterChipVariant.success,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Advertencia',
          isSelected: false,
          variant: BebeFilterChipVariant.warning,
          onPressed: () {},
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Seleccionados',
  type: BebeFilterChip,
  path: '[Molecules]/Filters',
)
Widget filterChipSelected(BuildContext context) {
  return UseCaseFrame(
    width: 620,
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        BebeFilterChip(
          label: 'Todos',
          isSelected: true,
          variant: BebeFilterChipVariant.brand,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Vacunas',
          icon: const Icon(
            Icons.vaccines_outlined,
          ),
          isSelected: true,
          variant: BebeFilterChipVariant.accent,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Medicación',
          icon: const Icon(
            Icons.medication_outlined,
          ),
          isSelected: true,
          variant: BebeFilterChipVariant.warning,
          onPressed: () {},
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Estados',
  type: BebeFilterChip,
  path: '[Molecules]/Filters',
)
Widget filterChipStates(BuildContext context) {
  return UseCaseFrame(
    width: 620,
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        BebeFilterChip(
          label: 'Disponible',
          isSelected: false,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Seleccionado',
          isSelected: true,
          onPressed: () {},
        ),
        const BebeFilterChip(
          label: 'Deshabilitado',
          isSelected: false,
          enabled: false,
        ),
        const BebeFilterChip(
          label: 'Seleccionado deshabilitado',
          isSelected: true,
          enabled: false,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Contenido largo',
  type: BebeFilterChip,
  path: '[Molecules]/Filters',
)
Widget filterChipLongContent(
  BuildContext context,
) {
  return UseCaseFrame(
    width: 300,
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        BebeFilterChip(
          label: 'Controles de crecimiento',
          icon: const Icon(
            Icons.monitor_weight_outlined,
          ),
          isSelected: false,
          onPressed: () {},
        ),
        BebeFilterChip(
          label: 'Seguimientos pendientes',
          icon: const Icon(
            Icons.event_repeat_outlined,
          ),
          isSelected: true,
          variant: BebeFilterChipVariant.success,
          onPressed: () {},
        ),
      ],
    ),
  );
}
