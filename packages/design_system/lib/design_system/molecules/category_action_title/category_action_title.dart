import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Compact domain action used in category selectors and quick actions.
class BebeCategoryActionTile extends StatelessWidget {
  const BebeCategoryActionTile({
    required this.variant,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isSelected = false,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final BebeCategoryActionTileVariant variant;
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool enabled;
  final String? semanticLabel;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final overlays = theme.overlays;
    final colors = theme.colors;
    final palette = resolveCategoryPalette(context, variant);

    final surface = enabled
        ? palette.surface
        : colors.background.neutralsDisabled;
    final content = enabled ? palette.content : colors.text.neutralDisabled;
    final iconSurface = enabled
        ? palette.iconSurface
        : colors.background.neutralsActive;
    final border = isSelected ? palette.content : palette.border;
    final labelStyle = isSelected
        ? typography.styles.label.sm.bold
        : typography.styles.label.sm.regular;

    return Semantics(
      container: true,
      button: true,
      selected: isSelected,
      enabled: _isInteractive,
      label: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: spacing.spacing8xl + spacing.spacing4xl,
        ),
        child: Material(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: theme.borderRadius.x3l,
            side: BorderSide(color: border, width: isSelected ? 2 : 1),
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
                horizontal: spacing.spacingS,
                vertical: spacing.spacingM,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: BebeIconSize.xl.value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: iconSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: IconTheme(
                          data: IconThemeData(
                            color: content,
                            size: BebeIconSize.sm.value,
                          ),
                          child: icon,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.spacingS),
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: labelStyle.copyWith(color: content),
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

/// Backward-compatible alias for the original public API.
@Deprecated('Use BebeCategoryActionTile instead.')
class CategoryActionTile extends BebeCategoryActionTile {
  const CategoryActionTile({
    required super.variant,
    required super.label,
    required super.icon,
    super.onPressed,
    super.isSelected,
    super.enabled,
    super.semanticLabel,
    super.key,
  });
}
