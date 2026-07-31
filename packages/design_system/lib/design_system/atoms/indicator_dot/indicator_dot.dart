import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'indicator_dot_palette.dart';
import 'indicator_dot_variant.dart';

class BebeIndicatorDot extends StatelessWidget {
  const BebeIndicatorDot({
    required this.variant,
    this.size = IndicatorDotSize.small,
    this.semanticLabel,
    super.key,
  });

  final IndicatorDotVariant variant;
  final IndicatorDotSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final palette = IndicatorDotPalette.resolve(
      colors: theme.colors,
      variant: variant,
    );

    final dimension = switch (size) {
      IndicatorDotSize.small => 4,
      IndicatorDotSize.medium => 6,
    };

    final dot = SizedBox.square(
      dimension: dimension.toDouble(),
      child: DecoratedBox(
        decoration: BoxDecoration(color: palette.color, shape: BoxShape.circle),
      ),
    );

    final label = semanticLabel?.trim();

    if (label == null || label.isEmpty) {
      return ExcludeSemantics(child: dot);
    }

    return Semantics(
      label: label,
      child: ExcludeSemantics(child: dot),
    );
  }
}
