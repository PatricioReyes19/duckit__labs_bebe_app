import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Estados',
  type: BebeStatusIndicator,
  path: '[Átomos]/Estados',
)
Widget bebeStatusIndicatorStates(BuildContext context) {
  return UseCaseFrame(
    child: Wrap(
      spacing: 24,
      runSpacing: 20,
      children: [
        for (final status in BebeStatusType.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BebeStatusIndicator(
                type: status,
                semanticLabel: status.name,
              ),
              const SizedBox(width: 8),
              Text(status.name),
            ],
          ),
      ],
    ),
  );
}
