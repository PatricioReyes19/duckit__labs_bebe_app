import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeAgendaHealthNotice extends StatelessWidget {
  const BebeAgendaHealthNotice({
    required this.onActionPressed,
    this.description =
        'El historial completo de vacunas y controles está disponible en Salud.',
    this.actionLabel = 'Ir a Salud',
    this.semanticLabel,
    super.key,
  });

  final String description;
  final String actionLabel;
  final VoidCallback? onActionPressed;
  final String? semanticLabel;

  static const double _healthIconSize = 22;
  static const double _actionIconSize = 18;

  @override
  Widget build(BuildContext context) {
    return BebeAgendaSupportBanner(
      description: description,
      actionLabel: actionLabel,
      semanticLabel: semanticLabel,
      variant: BebeAgendaSupportBannerVariant.information,
      icon: const Icon(Icons.health_and_safety_outlined, size: _healthIconSize),
      actionIcon: const Icon(
        Icons.chevron_right_rounded,
        size: _actionIconSize,
      ),
      onActionPressed: onActionPressed,
      title: '',
    );
  }
}
