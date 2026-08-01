import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Acciones principales',
  type: BebeQuickRegistrationActions,
  path: '[Organisms]/Home',
)
Widget quickRegistrationActionsDefault(BuildContext context) {
  return UseCaseFrame(
    width: 760,
    child: BebeQuickRegistrationActions(
      items: const [
        BebeQuickActionData(
          id: 'feeding',
          type: BebeQuickActionType.feeding,
          label: 'Alimentación',
          icon: Icon(LucideIcons.milk),
        ),
        BebeQuickActionData(
          id: 'sleep',
          type: BebeQuickActionType.sleep,
          label: 'Sueño',
          icon: Icon(LucideIcons.moon),
        ),
        BebeQuickActionData(
          id: 'diaper',
          type: BebeQuickActionType.diaper,
          label: 'Pañal',
          icon: Icon(LucideIcons.baby),
        ),
        BebeQuickActionData(
          id: 'observation',
          type: BebeQuickActionType.observation,
          label: 'Observación',
          icon: Icon(Icons.edit_outlined),
        ),
        BebeQuickActionData(
          id: 'medicine',
          type: BebeQuickActionType.medicine,
          label: 'Medicina',
          icon: Icon(Icons.medication_outlined),
        ),
      ],
      onItemPressed: (_) {},
    ),
  );
}
