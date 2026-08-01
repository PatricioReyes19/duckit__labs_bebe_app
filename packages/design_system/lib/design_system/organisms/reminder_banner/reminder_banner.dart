import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeAgendaReminderBanner extends StatelessWidget {
  const BebeAgendaReminderBanner({
    required this.onActionPressed,
    this.title = 'Recordatorios activos',
    this.description =
        'Te avisaremos antes de tus próximos eventos programados.',
    this.actionLabel = 'Configurar',
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onActionPressed;
  final String? semanticLabel;

  static const double _notificationIconSize = 22;
  static const double _actionIconSize = 18;

  @override
  Widget build(BuildContext context) {
    return BebeAgendaSupportBanner(
      title: title,
      description: description,
      actionLabel: actionLabel,
      semanticLabel: semanticLabel,
      variant: BebeAgendaSupportBannerVariant.brand,
      icon: const Icon(
        Icons.notifications_none_rounded,
        size: _notificationIconSize,
      ),
      actionIcon: const Icon(
        Icons.chevron_right_rounded,
        size: _actionIconSize,
      ),
      onActionPressed: onActionPressed,
    );
  }
}
