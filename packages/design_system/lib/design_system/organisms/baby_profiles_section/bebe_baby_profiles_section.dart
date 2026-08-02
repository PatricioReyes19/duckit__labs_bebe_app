import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeBabyProfilesSection extends StatelessWidget {
  const BebeBabyProfilesSection({
    required this.title,
    required this.children,
    this.trailing,
    this.minimumItemWidth = 240,
    this.maximumColumnCount = 2,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final double minimumItemWidth;
  final int maximumColumnCount;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(title: title.trim(), trailing: trailing),
          SizedBox(height: spacing.spacingL),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = spacing.spacingM;
              final columnCount = _resolveColumnCount(
                availableWidth: constraints.maxWidth,
                gap: gap,
              );
              final itemWidth = _resolveItemWidth(
                availableWidth: constraints.maxWidth,
                gap: gap,
                columnCount: columnCount,
              );
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final child in children)
                    SizedBox(width: itemWidth, child: child),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  int _resolveColumnCount({
    required double availableWidth,
    required double gap,
  }) {
    if (!availableWidth.isFinite || availableWidth <= 0) return 1;
    final calculated = ((availableWidth + gap) / (minimumItemWidth + gap))
        .floor();
    return calculated.clamp(1, math.min(maximumColumnCount, children.length));
  }

  double _resolveItemWidth({
    required double availableWidth,
    required double gap,
    required int columnCount,
  }) {
    if (!availableWidth.isFinite) return minimumItemWidth;
    final totalGap = gap * (columnCount - 1);
    return math.max(0, (availableWidth - totalGap) / columnCount);
  }
}
