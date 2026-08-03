import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeStatusBadge extends StatelessWidget {
  const BebeStatusBadge({
    required this.label,
    required this.variant,
    this.icon,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final BebeStatusBadgeVariant variant;
  final Widget? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final radius = theme.borderRadius;

    final palette = BebeStatusBadgePalette.resolve(
      colors: theme.colors,
      variant: variant,
    );

    return Semantics(
      label: semanticLabel ?? label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: radius.full,
            border: Border.all(color: palette.border),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.spacingM,
              vertical: spacing.spacingS,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: palette.icon, size: 16),
                    child: icon!,
                  ),
                  SizedBox(width: spacing.spacingS),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.styles.label.sm.semibold.copyWith(
                      color: palette.content,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
