import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Mobile',
  type: BebeUpcomingHealthSection,
  path: '[Organisms]/Home',
)
Widget upcomingHealthMobile(BuildContext context) {
  return UseCaseFrame(
    width: 380,
    child: BebeUpcomingHealthSection(
      data: const BebeUpcomingHealthData(
        title: 'Control pediátrico',
        dateLabel: 'Lun, 26 may 2025',
        timeLabel: '10:00',
        caregiverLabel: 'Mamá',
        type: BebeUpcomingHealthType.control,
        icon: Icon(
          Icons.medical_services_outlined,
        ),
      ),
      onCardPressed: () {},
      onViewAgendaPressed: () {},
      onOpenHealthPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Wide',
  type: BebeUpcomingHealthSection,
  path: '[Organisms]/Home',
)
Widget upcomingHealthWide(BuildContext context) {
  return UseCaseFrame(
    width: 760,
    child: BebeUpcomingHealthSection(
      data: const BebeUpcomingHealthData(
        title: 'Control pediátrico',
        dateLabel: 'Lun, 26 may 2025',
        timeLabel: '10:00',
        caregiverLabel: 'Mamá',
        type: BebeUpcomingHealthType.control,
        icon: Icon(
          Icons.medical_services_outlined,
        ),
      ),
      onCardPressed: () {},
      onViewAgendaPressed: () {},
      onOpenHealthPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sin cuidador',
  type: BebeUpcomingHealthSection,
  path: '[Organisms]/Home',
)
Widget upcomingHealthWithoutCaregiver(
  BuildContext context,
) {
  return UseCaseFrame(
    width: 380,
    child: BebeUpcomingHealthSection(
      data: const BebeUpcomingHealthData(
        title: 'Vacuna de los 2 meses',
        dateLabel: 'Vie, 30 may 2025',
        timeLabel: '09:30',
        type: BebeUpcomingHealthType.vaccine,
        icon: Icon(
          Icons.vaccines_outlined,
        ),
      ),
      onCardPressed: () {},
      onViewAgendaPressed: () {},
      onOpenHealthPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sin acciones inferiores',
  type: BebeUpcomingHealthSection,
  path: '[Organisms]/Home',
)
Widget upcomingHealthWithoutFooter(
  BuildContext context,
) {
  return UseCaseFrame(
    width: 380,
    child: BebeUpcomingHealthSection(
      data: const BebeUpcomingHealthData(
        title: 'Examen de control',
        dateLabel: 'Mar, 3 jun 2025',
        timeLabel: '12:15',
        caregiverLabel: 'Papá',
        type: BebeUpcomingHealthType.exam,
        icon: Icon(
          Icons.biotech_outlined,
        ),
      ),
      onCardPressed: () {},
    ),
  );
}
