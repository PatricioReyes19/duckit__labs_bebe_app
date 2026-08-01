import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeCaregiverBadge extends StatelessWidget {
  const BebeCaregiverBadge({
    required this.label,
    this.avatar,
    this.variant = BebeCaregiverBadgeVariant.brand,
    this.size = BebeCaregiverBadgeSize.small,
    this.onPressed,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final Widget? avatar;
  final BebeCaregiverBadgeVariant variant;
  final BebeCaregiverBadgeSize size;
  final VoidCallback? onPressed;
  final bool enabled;
  final String? semanticLabel;

  static const double _smallAvatarSize = 24;
  static const double _mediumAvatarSize = 30;
  static const double _minimumHeight = 32;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final radius = theme.borderRadius;
    final overlays = theme.overlays;
    final colors = theme.colors;

    final palette = _CaregiverBadgePalette.resolve(
      colors: colors,
      variant: variant,
    );

    final backgroundColor = enabled
        ? palette.surface
        : colors.background.neutralsDisabled;

    final contentColor = enabled
        ? palette.content
        : colors.text.neutralDisabled;

    final avatarSize = switch (size) {
      BebeCaregiverBadgeSize.small => _smallAvatarSize,
      BebeCaregiverBadgeSize.medium => _mediumAvatarSize,
    };

    final textStyle = switch (size) {
      BebeCaregiverBadgeSize.small => typography.styles.label.sm.semibold,
      BebeCaregiverBadgeSize.medium => typography.styles.label.md.semibold,
    };

    final badge = Material(
      color: backgroundColor,
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minimumHeight),
          child: Padding(
            padding: EdgeInsets.only(
              left: avatar == null ? spacing.spacingM : spacing.spacingXs,
              right: spacing.spacingM,
              top: spacing.spacingXs,
              bottom: spacing.spacingXs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avatar != null) ...[
                  SizedBox.square(dimension: avatarSize, child: avatar!),
                  SizedBox(width: spacing.spacingS),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(color: contentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: _isInteractive,
      label: semanticLabel ?? label,
      child: ExcludeSemantics(child: badge),
    );
  }
}

class _CaregiverBadgePalette {
  const _CaregiverBadgePalette({
    required this.surface,
    required this.content,
    required this.border,
  });

  final Color surface;
  final Color content;
  final Color border;

  static _CaregiverBadgePalette resolve({
    required BebeColor colors,
    required BebeCaregiverBadgeVariant variant,
  }) {
    return switch (variant) {
      BebeCaregiverBadgeVariant.neutral => _CaregiverBadgePalette(
        surface: colors.background.neutralsSurface,
        content: colors.text.neutralBody,
        border: colors.border.accentAlternative,
      ),
      BebeCaregiverBadgeVariant.brand => _CaregiverBadgePalette(
        surface: colors.background.brandSurface,
        content: colors.text.brandDefault,
        border: colors.border.brandAlternative,
      ),
      BebeCaregiverBadgeVariant.accent => _CaregiverBadgePalette(
        surface: colors.background.accentSurface,
        content: colors.text.accentDefault,
        border: colors.border.accentAlternative,
      ),
    };
  }
}
