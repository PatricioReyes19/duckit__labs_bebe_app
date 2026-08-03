import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeLeadingIcon extends StatelessWidget {
  const BebeLeadingIcon({
    required this.icon,
    required this.variant,
    this.size = BebeLeadingIconSize.medium,
    this.showBorder = false,
    this.semanticLabel,
    super.key,
  });

  final Widget icon;
  final BebeLeadingIconVariant variant;
  final BebeLeadingIconSize size;
  final bool showBorder;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final palette = BebeLeadingIconPalette.resolve(
      colors: colors,
      variant: variant,
    );

    final dimensions = _resolveDimensions(size);

    final content = SizedBox.square(
      dimension: dimensions.containerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          shape: BoxShape.circle,
          border: showBorder ? Border.all(color: palette.border) : null,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: palette.content,
              size: dimensions.iconSize,
            ),
            child: icon,
          ),
        ),
      ),
    );

    final effectiveSemanticLabel = semanticLabel?.trim();

    if (effectiveSemanticLabel == null || effectiveSemanticLabel.isEmpty) {
      return ExcludeSemantics(child: content);
    }

    return Semantics(
      image: true,
      label: effectiveSemanticLabel,
      child: ExcludeSemantics(child: content),
    );
  }

  _BebeLeadingIconDimensions _resolveDimensions(BebeLeadingIconSize size) {
    return switch (size) {
      BebeLeadingIconSize.small => _BebeLeadingIconDimensions(
        containerSize: 24,
        iconSize: 16,
      ),

      BebeLeadingIconSize.medium => _BebeLeadingIconDimensions(
        containerSize: 40,
        iconSize: 24,
      ),

      BebeLeadingIconSize.large => _BebeLeadingIconDimensions(
        containerSize: 40,
        iconSize: 24,
      ),
    };
  }
}

@immutable
class _BebeLeadingIconDimensions {
  const _BebeLeadingIconDimensions({
    required this.containerSize,
    required this.iconSize,
  });

  final double containerSize;
  final double iconSize;
}
