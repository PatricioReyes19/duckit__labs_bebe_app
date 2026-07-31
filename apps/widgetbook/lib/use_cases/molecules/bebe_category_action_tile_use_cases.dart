import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: CategoryActionTile,
  path: '[Moléculas]/Acciones rápidas',
)
Widget bebeCategoryTilePlayground(BuildContext context) {
  final label = context.knobs.string(
    label: 'Texto',
    initialValue: 'Alimentación',
  );

  final selected = context.knobs.boolean(
    label: 'Seleccionado',
    initialValue: false,
  );

  final enabled = context.knobs.boolean(
    label: 'Habilitado',
    initialValue: true,
  );

  return UseCaseFrame(
    child: SizedBox(
      width: 116,
      child: CategoryActionTile(
        label: label,
        icon: const Icon(LucideIcons.milk),
        isSelected: selected,
        enabled: enabled,
        onPressed: () {},
        variant: BebeCategoryActionTileVariant.diaper,
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Categorías BebéApp',
  type: CategoryActionTile,
  path: '[Moléculas]/Acciones rápidas',
)
Widget bebeCategoryTiles(BuildContext context) {
  return UseCaseFrame(
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        SizedBox(
          width: 112,
          child: CategoryActionTile(
            label: 'Alimentación',
            icon: Icon(LucideIcons.milk),
            variant: BebeCategoryActionTileVariant.feeding,
            onPressed: null,
          ),
        ),
        SizedBox(
          width: 112,
          child: CategoryActionTile(
            label: 'Sueño',
            icon: Icon(LucideIcons.moon),
            variant: BebeCategoryActionTileVariant.sleep,
            onPressed: null,
          ),
        ),
        SizedBox(
          width: 112,
          child: CategoryActionTile(
            label: 'Pañal',
            icon: Icon(LucideIcons.baby),
            variant: BebeCategoryActionTileVariant.diaper,
            onPressed: null,
          ),
        ),
      ],
    ),
  );
}
