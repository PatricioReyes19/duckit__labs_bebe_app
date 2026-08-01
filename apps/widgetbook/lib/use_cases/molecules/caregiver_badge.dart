import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Variantes',
  type: BebeCaregiverBadge,
  path: '[Molecules]/Identity',
)
Widget bebeCaregiverBadgeVariants(BuildContext context) {
  return UseCaseFrame(
    child: Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        BebeCaregiverBadge(
          label: 'Mamá',
          avatar: const CircleAvatar(
            child: Text('M'),
          ),
          variant: BebeCaregiverBadgeVariant.brand,
          onPressed: () {},
        ),
        BebeCaregiverBadge(
          label: 'Papá',
          avatar: const CircleAvatar(
            child: Text('P'),
          ),
          variant: BebeCaregiverBadgeVariant.accent,
          onPressed: () {},
        ),
        const BebeCaregiverBadge(
          label: 'Abuela',
          variant: BebeCaregiverBadgeVariant.neutral,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Tamaños',
  type: BebeCaregiverBadge,
  path: '[Molecules]/Identity',
)
Widget bebeCaregiverBadgeSizes(BuildContext context) {
  return const UseCaseFrame(
    child: Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        BebeCaregiverBadge(
          label: 'Cuidadora',
          avatar: CircleAvatar(
            child: Text('C'),
          ),
          size: BebeCaregiverBadgeSize.small,
        ),
        BebeCaregiverBadge(
          label: 'Cuidadora',
          avatar: CircleAvatar(
            child: Text('C'),
          ),
          size: BebeCaregiverBadgeSize.medium,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Estados',
  type: BebeCaregiverBadge,
  path: '[Molecules]/Identity',
)
Widget bebeCaregiverBadgeStates(BuildContext context) {
  return UseCaseFrame(
    width: 460,
    child: Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        BebeCaregiverBadge(
          label: 'Interactivo',
          onPressed: () {},
        ),
        const BebeCaregiverBadge(
          label: 'Informativo',
        ),
        const BebeCaregiverBadge(
          label: 'Deshabilitado',
          enabled: false,
        ),
        const BebeCaregiverBadge(
          label: 'Cuidador con un nombre extenso',
        ),
      ],
    ),
  );
}
