import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeResponsiveFormGrid extends StatelessWidget {
  const BebeResponsiveFormGrid({
    required this.children,
    this.minimumItemWidth = 168,
    this.maximumColumnCount = 3,
    this.semanticLabel,
    super.key,
  }) : assert(children.length > 0),
       assert(minimumItemWidth > 0),
       assert(maximumColumnCount > 0);

  final List<Widget> children;
  final double minimumItemWidth;
  final int maximumColumnCount;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final gap = context.theme.spacing.spacingL;
    return BebeAdaptiveGrid(
      minimumItemWidth: minimumItemWidth,
      maximumColumnCount: maximumColumnCount,
      horizontalGap: gap,
      verticalGap: gap,
      semanticLabel: semanticLabel,
      children: children,
    );
  }
}
