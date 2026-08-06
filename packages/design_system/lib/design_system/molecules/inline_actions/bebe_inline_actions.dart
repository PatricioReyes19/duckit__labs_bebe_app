import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeInlineAction extends StatelessWidget {
  const BebeInlineAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.variant = BebeInlineActionVariant.brand,
    this.size = BebeInlineActionSize.small,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final BebeInlineActionVariant variant;
  final BebeInlineActionSize size;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final overlays = theme.overlays;
    final colors = theme.colors;

    final contentColor = enabled
        ? _resolveContentColor(colors, variant)
        : colors.text.neutralDisabled;

    final iconSize = switch (size) {
      BebeInlineActionSize.small => 12,
      BebeInlineActionSize.medium => 16,
    };

    final textStyle = switch (size) {
      BebeInlineActionSize.small => typography.styles.label.sm.semibold,
      BebeInlineActionSize.medium => typography.styles.label.md.semibold,
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
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
                horizontal: spacing.spacingM,
                vertical: spacing.spacingS,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTheme(
                    data: IconThemeData(
                      color: contentColor,
                      size: iconSize.toDouble(),
                    ),
                    child: icon,
                  ),
                  SizedBox(width: spacing.spacingS),
                  Flexible(
                    child: Text(
                      label,
                      style: textStyle.copyWith(color: contentColor),
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

  Color _resolveContentColor(
    BebeColor colors,
    BebeInlineActionVariant variant,
  ) {
    return switch (variant) {
      BebeInlineActionVariant.neutral => colors.text.neutralBody,
      BebeInlineActionVariant.brand => colors.text.brandDefault,
      BebeInlineActionVariant.accent => colors.text.accentDefault,
      BebeInlineActionVariant.information => colors.text.infoDefault,
      BebeInlineActionVariant.success => colors.text.successDefault,
      BebeInlineActionVariant.warning => colors.text.warningDefault,
      BebeInlineActionVariant.error => colors.text.errorDefault,
    };
  }
}
