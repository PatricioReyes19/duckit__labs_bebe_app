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
    return BebeAdaptiveGrid(
      minimumItemWidth: minimumItemWidth,
      maximumColumnCount: maximumColumnCount,
      semanticLabel: semanticLabel,
      children: children,
    );
  }
}
