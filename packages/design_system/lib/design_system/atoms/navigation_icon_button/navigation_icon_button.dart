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
    this.showSurface = false,
    super.key,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final BebeNavigationIconButtonVariant variant;
  final BebeNavigationIconButtonSize size;
  final bool enabled;
  final bool showSurface;

  static const double _minimumTouchTarget = 48;
  static const double _smallIconSize = 18;
  static const double _mediumIconSize = 22;
  static const double _largeIconSize = 26;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final overlays = theme.overlays;

    final foregroundColor = enabled
        ? _resolveForegroundColor(colors)
        : colors.text.neutralDisabled;

    final iconSize = switch (size) {
      BebeNavigationIconButtonSize.small => _smallIconSize,
      BebeNavigationIconButtonSize.medium => _mediumIconSize,
      BebeNavigationIconButtonSize.large => _largeIconSize,
    };

    final surfaceColor = showSurface
        ? colors.background.neutralsSurface
        : Colors.transparent;

    return Semantics(
      button: true,
      enabled: _isInteractive,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: _minimumTouchTarget,
          minHeight: _minimumTouchTarget,
        ),
        child: Material(
          color: surfaceColor,
          shape: const CircleBorder(),
          elevation: showSurface ? 1 : 0,
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
                data: IconThemeData(size: iconSize, color: foregroundColor),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveForegroundColor(BebeColor colors) {
    return switch (variant) {
      BebeNavigationIconButtonVariant.neutral =>
        colors.icons.neutralAlternative,
      BebeNavigationIconButtonVariant.brand => colors.text.brandDefault,
      BebeNavigationIconButtonVariant.accent => colors.icons.accentDefault,
    };
  }
}
