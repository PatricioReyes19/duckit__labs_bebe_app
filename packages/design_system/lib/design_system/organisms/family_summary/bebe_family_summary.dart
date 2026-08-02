import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeFamilySummary extends StatelessWidget {
  const BebeFamilySummary({
    required this.children,
    this.minimumItemWidth = 150,
    this.maximumColumnCount = 3,
    this.semanticLabel,
    super.key,
  }) : assert(children.length > 0, 'BebeFamilySummary requires at least one child.'),
       assert(minimumItemWidth > 0, 'minimumItemWidth must be greater than zero.'),
       assert(maximumColumnCount > 0, 'maximumColumnCount must be greater than zero.');

  final List<Widget> children;
  final double minimumItemWidth;
  final int maximumColumnCount;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final effectiveSemanticLabel = _normalizeText(semanticLabel);
    final content = LayoutBuilder(builder: (context, constraints) {
      final gap = spacing.spacingM;
      final columnCount = _resolveColumnCount(availableWidth: constraints.maxWidth, gap: gap);
      final itemWidth = _resolveItemWidth(availableWidth: constraints.maxWidth, gap: gap, columnCount: columnCount);
      return Wrap(spacing: gap, runSpacing: gap, children: [for (final child in children) SizedBox(width: itemWidth, child: child)]);
    });
    final constrained = SizedBox(width: double.infinity, child: content);
    return effectiveSemanticLabel == null ? constrained : Semantics(container: true, label: effectiveSemanticLabel, child: constrained);
  }

  int _resolveColumnCount({required double availableWidth, required double gap}) {
    if (!availableWidth.isFinite || availableWidth <= 0) return 1;
    final calculated = ((availableWidth + gap) / (minimumItemWidth + gap)).floor();
    return calculated.clamp(1, math.min(maximumColumnCount, children.length));
  }

  double _resolveItemWidth({required double availableWidth, required double gap, required int columnCount}) {
    if (!availableWidth.isFinite) return minimumItemWidth;
    final totalGap = gap * (columnCount - 1);
    return math.max(0, (availableWidth - totalGap) / columnCount);
  }

  static String? _normalizeText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
