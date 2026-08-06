import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeSectionHint extends StatelessWidget {
  const BebeSectionHint({
    required this.label,
    this.icon,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final Widget? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    return Semantics(
      label: semanticLabel ?? label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: typography.styles.caption.md.regular.copyWith(
                color: colors.text.neutralCaption,
              ),
            ),
          ),
          if (icon != null) ...[SizedBox(width: spacing.spacingS), icon!],
        ],
      ),
    );
  }
}
