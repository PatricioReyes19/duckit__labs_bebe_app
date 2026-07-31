import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeUpcomingHealthActions extends StatelessWidget {
  const BebeUpcomingHealthActions({
    required this.onViewAgendaPressed,
    required this.onOpenHealthPressed,
    this.viewAgendaLabel = 'Ver agenda',
    this.openHealthLabel = 'Ir a Salud',
    this.viewAgendaIcon = const Icon(Icons.calendar_month_outlined),
    this.openHealthIcon = const Icon(Icons.health_and_safety_outlined),
    this.enabled = true,
    super.key,
  });

  final VoidCallback onViewAgendaPressed;
  final VoidCallback onOpenHealthPressed;

  final String viewAgendaLabel;
  final String openHealthLabel;

  final Widget viewAgendaIcon;
  final Widget openHealthIcon;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: BebeInlineAction(
              label: viewAgendaLabel,
              icon: viewAgendaIcon,
              onPressed: onViewAgendaPressed,
              variant: BebeInlineActionVariant.brand,
              enabled: enabled,
            ),
          ),
          SizedBox(
            height: 8,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: colors.border.neutralDefault,
            ),
          ),
          Expanded(
            child: BebeInlineAction(
              label: openHealthLabel,
              icon: openHealthIcon,
              onPressed: onOpenHealthPressed,
              variant: BebeInlineActionVariant.brand,
              enabled: enabled,
            ),
          ),
        ],
      ),
    );
  }
}
