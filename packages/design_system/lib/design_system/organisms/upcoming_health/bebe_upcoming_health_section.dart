import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeUpcomingHealthStatus { success, information, attention }

enum BebeUpcomingHealthType { control, vaccine, exam, appointment, other }

class BebeUpcomingHealthData {
  const BebeUpcomingHealthData({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.icon,
    this.type = BebeUpcomingHealthType.control,
    this.caregiverLabel,
    this.semanticLabel,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final Widget icon;

  /// Tipo funcional del evento.
  final BebeUpcomingHealthType type;

  final String? caregiverLabel;
  final String? semanticLabel;
}

class BebeUpcomingHealthSection extends StatelessWidget {
  const BebeUpcomingHealthSection({
    required this.data,
    this.title = 'Próxima atención de salud',
    this.viewAgendaLabel = 'Ver agenda',
    this.openHealthLabel = 'Ir a Salud',
    this.viewAgendaIcon = const Icon(Icons.calendar_month_outlined),
    this.openHealthIcon = const Icon(Icons.health_and_safety_outlined),
    this.onCardPressed,
    this.onViewAgendaPressed,
    this.onOpenHealthPressed,
    super.key,
  });

  final BebeUpcomingHealthData data;
  final String title;

  final String viewAgendaLabel;
  final String openHealthLabel;

  final Widget viewAgendaIcon;
  final Widget openHealthIcon;

  final VoidCallback? onCardPressed;
  final VoidCallback? onViewAgendaPressed;
  final VoidCallback? onOpenHealthPressed;

  bool get _hasFooterActions =>
      onViewAgendaPressed != null && onOpenHealthPressed != null;

  @override
  Widget build(BuildContext context) {
    assert(
      (onViewAgendaPressed == null && onOpenHealthPressed == null) ||
          (onViewAgendaPressed != null && onOpenHealthPressed != null),
      'BebeUpcomingHealthSection requires both footer callbacks '
      'or neither of them.',
    );

    final theme = context.theme;
    final spacing = theme.spacing;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(title: title),
          SizedBox(height: spacing.spacingXl),
          BebeUpcomingHealthCard(
            title: data.title,
            dateLabel: data.dateLabel,
            timeLabel: data.timeLabel,
            caregiverLabel: data.caregiverLabel,
            icon: data.icon,
            variant: data.type.toCardVariant(),
            semanticLabel: data.semanticLabel,
            onPressed: onCardPressed,
            footer: _hasFooterActions
                ? BebeUpcomingHealthActions(
                    viewAgendaLabel: viewAgendaLabel,
                    openHealthLabel: openHealthLabel,
                    viewAgendaIcon: viewAgendaIcon,
                    openHealthIcon: openHealthIcon,
                    onViewAgendaPressed: onViewAgendaPressed!,
                    onOpenHealthPressed: onOpenHealthPressed!,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

extension BebeUpcomingHealthTypeMapper on BebeUpcomingHealthType {
  BebeUpcomingHealthCardVariant toCardVariant() {
    return switch (this) {
      BebeUpcomingHealthType.control => BebeUpcomingHealthCardVariant.brand,

      BebeUpcomingHealthType.vaccine => BebeUpcomingHealthCardVariant.accent,

      BebeUpcomingHealthType.exam => BebeUpcomingHealthCardVariant.information,

      BebeUpcomingHealthType.appointment => BebeUpcomingHealthCardVariant.brand,

      BebeUpcomingHealthType.other => BebeUpcomingHealthCardVariant.neutral,
    };
  }
}
