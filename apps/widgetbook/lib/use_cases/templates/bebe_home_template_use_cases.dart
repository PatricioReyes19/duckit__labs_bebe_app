import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: BebeHomeTemplate,
  path: '[Templates]/Home',
)
Widget homeTemplateDefault(BuildContext context) {
  return BebeHomeTemplate(
    activeBabyHeader: const BebeActiveBabyHeader(
      name: 'Mateo Reyes',
      ageLabel: '2 meses',
      avatar: AssetImage(
        'assets/images/babies/mateo.png',
      ),
      familyContextLabel: '2 bebés en la familia',
      siblings: [
        BebeSiblingSummaryData(
          name: 'Sofía',
          ageLabel: '8 meses',
          avatar: AssetImage(
            'assets/images/babies/sofia.png',
          ),
        )
      ],
    ),
    todaySummary: const BebeTodaySummary(
      items: [
        BebeTodayMetricData(
          variant: BebeMetricCardVariant.feeding,
          label: 'Alimentación',
          value: '5',
          unit: 'tomas',
          lastLabel: 'Última hace',
          lastValue: '2 h 10 min',
          icon: Icon(LucideIcons.milk),
        ),
        BebeTodayMetricData(
          variant: BebeMetricCardVariant.sleep,
          label: 'Sueño',
          value: '3',
          unit: 'h 45 min',
          lastLabel: 'Último hoy',
          lastValue: '07:30',
          icon: Icon(LucideIcons.moon),
        ),
        BebeTodayMetricData(
          variant: BebeMetricCardVariant.diaper,
          label: 'Pañales',
          value: '6',
          unit: 'cambios',
          lastLabel: 'Última hace',
          lastValue: '45 min',
          icon: Icon(LucideIcons.baby),
        ),
      ],
      title: 'Actividad del día',
    ),
    quickActions: BebeQuickRegistrationActions(
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
    upcomingHealth: BebeUpcomingHealthSection(
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
    recentInformation: BebeRecentInformationSection(
      data: const BebeRecentInformationData(
        title: 'Última consulta',
        dateLabel: '15 may 2025',
        description: 'Todo normal, buen desarrollo.',
        status: BebeRecentInformationStatus.success,
        statusLabel: 'Sin alertas',
        icon: Icon(
          Icons.assignment_turned_in_outlined,
        ),
      ),
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Loading',
  type: BebeHomeTemplate,
  path: '[Templates]/Home',
)
Widget homeTemplateLoading(BuildContext context) {
  return const BebeHomeTemplate(
    isLoading: true,
    activeBabyHeader: SizedBox.shrink(),
    todaySummary: SizedBox.shrink(),
    quickActions: SizedBox.shrink(),
    upcomingHealth: SizedBox.shrink(),
    recentInformation: SizedBox.shrink(),
  );
}

@widgetbook.UseCase(
  name: 'Error',
  type: BebeHomeTemplate,
  path: '[Templates]/Home',
)
Widget homeTemplateError(BuildContext context) {
  return BebeHomeTemplate(
    errorMessage: 'No pudimos cargar el Inicio.',
    onRetry: () {},
    activeBabyHeader: const SizedBox.shrink(),
    todaySummary: const SizedBox.shrink(),
    quickActions: const SizedBox.shrink(),
    upcomingHealth: const SizedBox.shrink(),
    recentInformation: const SizedBox.shrink(),
  );
}
