import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeButtonVariant { primary, secondary, text, destructive }

enum BebeButtonSize {
  medium(48),
  large(56);

  const BebeButtonSize(this.height);

  final double height;
}

class BebeButton extends StatelessWidget {
  const BebeButton({
    required this.label,
    required this.onPressed,
    this.variant = BebeButtonVariant.primary,
    this.size = BebeButtonSize.large,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.expand = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final BebeButtonVariant variant;
  final BebeButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool expand;
  final String? semanticLabel;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final transparentSurface = colors.background.neutralsSurface.withValues(
      alpha: 0,
    );

    final background = switch (variant) {
      BebeButtonVariant.primary => colors.background.brandDefault,
      BebeButtonVariant.secondary => colors.background.neutralsSurface,
      BebeButtonVariant.text => transparentSurface,
      BebeButtonVariant.destructive => colors.background.errorDefault,
    };

    final foreground = switch (variant) {
      BebeButtonVariant.primary => colors.onPrimary.neutralDefault,
      BebeButtonVariant.secondary ||
      BebeButtonVariant.text => colors.text.brandDefault,
      BebeButtonVariant.destructive => colors.onPrimary.neutralDefault,
    };

    final border = switch (variant) {
      BebeButtonVariant.secondary => BorderSide(
        color: colors.border.brandDefault,
      ),
      _ => BorderSide.none,
    };

    final content = isLoading
        ? SizedBox.square(
            dimension: BebeIconSize.sm.value,
            child: CircularProgressIndicator(
              strokeWidth: theme.spacing.spacingXs,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(color: foreground),
                  child: leading!,
                ),
                SizedBox(width: spacing.spacingM),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.typography.styles.label.lg.semibold.copyWith(
                    color: foreground,
                  ),
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: spacing.spacingM),
                IconTheme(
                  data: IconThemeData(color: foreground),
                  child: trailing!,
                ),
              ],
            ],
          );

    final button = Semantics(
      button: true,
      enabled: _isEnabled,
      label: semanticLabel ?? label,
      value: isLoading ? 'Cargando' : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.height),
        child: FilledButton(
          onPressed: _isEnabled ? onPressed : null,
          style: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colors.background.neutralsDisabled;
              }
              if (states.contains(WidgetState.pressed)) {
                return switch (variant) {
                  BebeButtonVariant.primary => colors.background.brandPressed,
                  BebeButtonVariant.destructive =>
                    colors.background.errorPressed,
                  _ => background,
                };
              }
              return background;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colors.text.neutralDisabled;
              }
              return foreground;
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
                return theme.overlays.interactionFocus;
              }
              if (states.contains(WidgetState.hovered)) {
                return theme.overlays.interactionHover;
              }
              if (states.contains(WidgetState.pressed)) {
                return theme.overlays.interactionPressed;
              }
              return null;
            }),
            side: WidgetStatePropertyAll(border),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: theme.borderRadius.xl),
            ),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(
                horizontal: spacing.spacing2xl,
                vertical: spacing.spacingM,
              ),
            ),
          ),
          child: content,
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
