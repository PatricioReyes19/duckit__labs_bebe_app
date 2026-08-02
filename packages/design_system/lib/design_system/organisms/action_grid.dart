import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class FeatureActionGrid extends StatelessWidget {
  const FeatureActionGrid({
    required this.children,
    this.minimumItemWidth = _defaultMinimumItemWidth,
    this.maximumColumnCount = _defaultMaximumColumnCount,
    this.semanticLabel,
    super.key,
  }) : assert(
         children.length > 0,
         'FeatureActionGrid requires at least one child.',
       ),
       assert(
         minimumItemWidth > 0,
         'minimumItemWidth must be greater than zero.',
       ),
       assert(
         maximumColumnCount > 0,
         'maximumColumnCount must be greater than zero.',
       );

  final List<Widget> children;
  final double minimumItemWidth;
  final int maximumColumnCount;
  final String? semanticLabel;

  static const double _defaultMinimumItemWidth = 152;
  static const int _defaultMaximumColumnCount = 2;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final grid = LayoutBuilder(
      builder: (context, constraints) {
        final horizontalGap = spacing.spacingM;
        final verticalGap = spacing.spacingM;

        final columnCount = _resolveColumnCount(
          availableWidth: constraints.maxWidth,
          horizontalGap: horizontalGap,
        );

        final itemWidth = _resolveItemWidth(
          availableWidth: constraints.maxWidth,
          horizontalGap: horizontalGap,
          columnCount: columnCount,
        );

        return Wrap(
          spacing: horizontalGap,
          runSpacing: verticalGap,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );

    final content = SizedBox(width: double.infinity, child: grid);

    if (effectiveSemanticLabel == null) {
      return content;
    }

    return Semantics(
      container: true,
      label: effectiveSemanticLabel,
      child: content,
    );
  }

  int _resolveColumnCount({
    required double availableWidth,
    required double horizontalGap,
  }) {
    if (!availableWidth.isFinite || availableWidth <= 0) {
      return 1;
    }

    final calculatedColumns =
        ((availableWidth + horizontalGap) / (minimumItemWidth + horizontalGap))
            .floor();

    final maximumAllowedColumns = math.min(maximumColumnCount, children.length);

    return calculatedColumns.clamp(1, maximumAllowedColumns);
  }

  double _resolveItemWidth({
    required double availableWidth,
    required double horizontalGap,
    required int columnCount,
  }) {
    if (!availableWidth.isFinite) {
      return minimumItemWidth;
    }

    final totalSpacing = horizontalGap * (columnCount - 1);

    return math.max(0, (availableWidth - totalSpacing) / columnCount);
  }

  static String? _normalizeText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
