import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeAdaptiveGrid extends StatelessWidget {
  const BebeAdaptiveGrid({
    required this.children,
    this.minimumItemWidth = 152,
    this.maximumColumnCount = 2,
    this.horizontalGap,
    this.verticalGap,
    this.semanticLabel,
    super.key,
  }) : assert(children.length > 0),
       assert(minimumItemWidth > 0),
       assert(maximumColumnCount > 0);

  final List<Widget> children;
  final double minimumItemWidth;
  final int maximumColumnCount;
  final double? horizontalGap;
  final double? verticalGap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final effectiveHorizontalGap = horizontalGap ?? spacing.spacingM;
    final effectiveVerticalGap = verticalGap ?? effectiveHorizontalGap;
    final normalizedSemanticLabel = semanticLabel?.trim();

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final metrics = resolveMetrics(
          availableWidth: constraints.maxWidth,
          itemCount: children.length,
          minimumItemWidth: minimumItemWidth,
          maximumColumnCount: maximumColumnCount,
          horizontalGap: effectiveHorizontalGap,
        );

        return Wrap(
          spacing: effectiveHorizontalGap,
          runSpacing: effectiveVerticalGap,
          children: [
            for (final child in children)
              SizedBox(width: metrics.itemWidth, child: child),
          ],
        );
      },
    );

    final grid = SizedBox(width: double.infinity, child: content);

    if (normalizedSemanticLabel == null || normalizedSemanticLabel.isEmpty) {
      return grid;
    }

    return Semantics(
      container: true,
      label: normalizedSemanticLabel,
      child: grid,
    );
  }

  @visibleForTesting
  static BebeAdaptiveGridMetrics resolveMetrics({
    required double availableWidth,
    required int itemCount,
    required double minimumItemWidth,
    required int maximumColumnCount,
    required double horizontalGap,
  }) {
    assert(itemCount > 0);
    assert(minimumItemWidth > 0);
    assert(maximumColumnCount > 0);

    if (!availableWidth.isFinite || availableWidth <= 0) {
      return BebeAdaptiveGridMetrics(columns: 1, itemWidth: minimumItemWidth);
    }

    final calculatedColumns =
        ((availableWidth + horizontalGap) / (minimumItemWidth + horizontalGap))
            .floor();
    final maximumAllowedColumns = math.min(maximumColumnCount, itemCount);
    final columns = calculatedColumns.clamp(1, maximumAllowedColumns).toInt();
    final totalGap = horizontalGap * (columns - 1);
    final itemWidth = math
        .max(0.0, (availableWidth - totalGap) / columns)
        .toDouble();

    return BebeAdaptiveGridMetrics(columns: columns, itemWidth: itemWidth);
  }
}
