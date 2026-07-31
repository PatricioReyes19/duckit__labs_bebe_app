import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'filter_chip_palette.dart';

class BebeFilterChip extends StatelessWidget {
  const BebeFilterChip({
    required this.label,
    required this.isSelected,
    this.icon,
    this.variant = BebeFilterChipVariant.neutral,
    this.onPressed,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final bool isSelected;
  final Widget? icon;
  final BebeFilterChipVariant variant;
  final VoidCallback? onPressed;
  final bool enabled;
  final String? semanticLabel;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final radius = theme.borderRadius;
    final overlays = theme.overlays;

    final palette = BebeFilterChipPalette.resolve(
      colors: theme.colors,
      variant: variant,
    );

    final surface = !enabled
        ? theme.colors.background.neutralsDisabled
        : isSelected
        ? palette.selectedSurface
        : palette.surface;

    final contentColor = !enabled
        ? theme.colors.text.neutralDisabled
        : isSelected
        ? palette.selectedContent
        : palette.content;

    return Semantics(
      button: true,
      enabled: _isInteractive,
      selected: isSelected,
      label: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 48),
        child: Material(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.radiusFull),
            side: BorderSide(color: palette.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _isInteractive ? onPressed : null,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return overlays.interactionPressed;
              }

              if (states.contains(WidgetState.hovered)) {
                return overlays.interactionHover;
              }

              if (states.contains(WidgetState.focused)) {
                return overlays.interactionFocus;
              }

              return null;
            }),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.spacingL,
                vertical: spacing.spacingS,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    IconTheme(
                      data: IconThemeData(size: 8, color: contentColor),
                      child: icon!,
                    ),
                    SizedBox(width: spacing.spacingS),
                  ],
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.styles.label.sm.semibold.copyWith(
                      color: contentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
