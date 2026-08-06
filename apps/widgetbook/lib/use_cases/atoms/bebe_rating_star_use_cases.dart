import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Estados',
  type: BebeRatingStar,
  path: '[Átomos]/Valoración',
)
Widget bebeRatingStarStates(BuildContext context) {
  return UseCaseFrame(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BebeRatingStar(selected: false, onPressed: () {}),
        BebeRatingStar(selected: true, onPressed: () {}),
        const BebeRatingStar(selected: true),
      ],
    ),
  );
}
