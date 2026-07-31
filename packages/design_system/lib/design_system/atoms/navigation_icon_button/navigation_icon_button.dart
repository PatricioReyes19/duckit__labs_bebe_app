import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeNavigationIconButton extends StatelessWidget {
  const BebeNavigationIconButton({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.variant = BebeNavigationIconButtonVariant.neutral,
    this.size = BebeNavigationIconButtonSize.medium,
    this.enabled = true,
    super.key,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final BebeNavigationIconButtonVariant variant;
  final BebeNavigationIconButtonSize size;
  final bool enabled;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final overlays = theme.overlays;

    final foregroundColor = enabled
        ? _resolveForegroundColor(colors, variant)
        : colors.text.neutralDisabled;

    final iconSize = switch (size) {
      BebeNavigationIconButtonSize.small => 20,
      BebeNavigationIconButtonSize.medium => 24,
    };

    return Semantics(
      button: true,
      enabled: _isInteractive,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _isInteractive ? onPressed : null,
            customBorder: const CircleBorder(),
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
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  size: iconSize.toDouble(),
                  color: foregroundColor,
                ),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveForegroundColor(
    BebeColor colors,
    BebeNavigationIconButtonVariant variant,
  ) {
    return switch (variant) {
      BebeNavigationIconButtonVariant.neutral =>
        colors.icons.neutralAlternative,
      BebeNavigationIconButtonVariant.brand => colors.text.brandDefault,
      BebeNavigationIconButtonVariant.accent => colors.icons.accentDefault,
    };
  }
}
