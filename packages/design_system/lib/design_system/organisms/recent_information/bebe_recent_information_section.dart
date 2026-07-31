import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeRecentInformationStatus { success, information, warning }

class BebeRecentInformationData {
  const BebeRecentInformationData({
    required this.title,
    required this.dateLabel,
    required this.description,
    required this.icon,
    required this.status,
    required this.statusLabel,
    this.semanticLabel,
  });

  final String title;
  final String dateLabel;
  final String description;
  final Widget icon;

  /// Estado semántico del organismo.
  final BebeRecentInformationStatus status;

  final String statusLabel;
  final String? semanticLabel;
}

class BebeRecentInformationSection extends StatelessWidget {
  const BebeRecentInformationSection({
    required this.data,
    this.title = 'Información reciente',
    this.onPressed,
    super.key,
  });

  final BebeRecentInformationData data;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(title: title),
          SizedBox(height: spacing.spacingXl),
          BebeRecentInformationCard(
            title: data.title,
            dateLabel: data.dateLabel,
            description: data.description,
            icon: data.icon,
            variant: data.status.toCardVariant(),
            semanticLabel: data.semanticLabel,
            onPressed: onPressed,
            status: BebeStatusBadge(
              label: data.statusLabel,
              variant: data.status.toBadgeVariant(),
            ),
          ),
        ],
      ),
    );
  }
}

extension BebeRecentInformationStatusMapper on BebeRecentInformationStatus {
  BebeStatusBadgeVariant toBadgeVariant() {
    return switch (this) {
      BebeRecentInformationStatus.success => BebeStatusBadgeVariant.success,

      BebeRecentInformationStatus.information =>
        BebeStatusBadgeVariant.information,

      BebeRecentInformationStatus.warning => BebeStatusBadgeVariant.warning,
    };
  }

  BebeRecentInformationCardVariant toCardVariant() {
    return switch (this) {
      BebeRecentInformationStatus.success =>
        BebeRecentInformationCardVariant.success,

      BebeRecentInformationStatus.information =>
        BebeRecentInformationCardVariant.information,

      BebeRecentInformationStatus.warning =>
        BebeRecentInformationCardVariant.warning,
    };
  }
}
