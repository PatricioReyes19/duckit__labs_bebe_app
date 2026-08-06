import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Responsive organism for the compact summary cards shown in reports.
class BebeMetricsOverview extends StatelessWidget {
  const BebeMetricsOverview({
    required this.children,
    this.title,
    this.description,
    this.actionLabel,
    this.onActionPressed,
    this.minimumItemWidth = 96,
    this.maximumColumnCount = 3,
    this.semanticLabel,
    super.key,
  }) : assert(children.length > 0),
       assert(minimumItemWidth > 0),
       assert(maximumColumnCount > 0);

  final List<Widget> children;
  final String? title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final double minimumItemWidth;
  final int maximumColumnCount;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final normalizedTitle = _normalize(title);

    return Semantics(
      container: true,
      label: semanticLabel ?? normalizedTitle ?? 'Resumen de métricas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (normalizedTitle != null) ...[
            BebeTitleSection(
              title: normalizedTitle,
              description: description,
              actionLabel: actionLabel,
              onActionPressed: onActionPressed,
            ),
            SizedBox(height: spacing.spacingL),
          ],
          BebeAdaptiveGrid(
            minimumItemWidth: minimumItemWidth,
            maximumColumnCount: maximumColumnCount,
            semanticLabel: 'Métricas',
            children: children,
          ),
        ],
      ),
    );
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
