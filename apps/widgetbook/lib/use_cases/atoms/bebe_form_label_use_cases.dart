import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Obligatorio y opcional',
  type: BebeFormLabel,
  path: '[Átomos]/Formularios',
)
Widget bebeFormLabelUseCase(BuildContext context) {
  return const UseCaseFrame(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BebeFormLabel(label: 'Hora de inicio'),
        SizedBox(height: 16),
        BebeFormLabel(label: 'Síntomas / observaciones', optional: true),
      ],
    ),
  );
}
