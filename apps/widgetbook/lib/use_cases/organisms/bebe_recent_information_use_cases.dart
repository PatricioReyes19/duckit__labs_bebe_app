import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Consulta reciente',
  type: BebeRecentInformationSection,
  path: '[Organismos]/Home',
)
Widget recentInformationDefault(BuildContext context) {
  return UseCaseFrame(
    width: 760,
    child: BebeRecentInformationSection(
      data: const BebeRecentInformationData(
        title: 'Última consulta',
        description: '15 may 2025 · Todo normal, buen desarrollo.',
        statusLabel: 'Sin alertas',
        icon: Icon(Icons.assignment_turned_in_outlined),
        dateLabel: '',
        status: BebeRecentInformationStatus.information,
      ),
      onPressed: () {},
    ),
  );
}
