import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeFilterChip extends StatelessWidget {
  const BebeFilterChip({
    required this.label,
    this.icon,
    this.variant = BebeFilterChipVariant.neutral,
    this.size = BebeFilterChipSize.medium,
    this.isSelected = false,
    this.enabled = true,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final Widget? icon;
  final BebeFilterChipVariant variant;
  final BebeFilterChipSize size;
  final bool isSelected;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _smallMinimumHeight = 36;
  static const double _mediumMinimumHeight = 44;

  static const double _smallIconSize = 16;
  static const double _mediumIconSize = 19;

  static const double _selectedBorderWidth = 1.5;
  static const double _regularBorderWidth = 1;

  bool get _isInteractive {
    return enabled && onPressed != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final radius = theme.borderRadius;
    final colors = theme.colors;
    final overlays = theme.overlays;

    final palette = _resolvePalette(
      variant: variant,
      isSelected: isSelected,
      enabled: enabled,
      colors: colors,
    );

    final minimumHeight = switch (size) {
      BebeFilterChipSize.small => _smallMinimumHeight,
      BebeFilterChipSize.medium => _mediumMinimumHeight,
    };

    final iconSize = switch (size) {
      BebeFilterChipSize.small => _smallIconSize,
      BebeFilterChipSize.medium => _mediumIconSize,
    };

    final horizontalPadding = switch (size) {
      BebeFilterChipSize.small => spacing.spacingM,
      BebeFilterChipSize.medium => spacing.spacingL,
    };

    final textStyle = switch (size) {
      BebeFilterChipSize.small => typography.styles.label.sm.semibold,
      BebeFilterChipSize.medium => typography.styles.label.md.semibold,
    };

    final chip = Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radiusFull),
        side: BorderSide(
          color: palette.border,
          width: isSelected ? _selectedBorderWidth : _regularBorderWidth,
        ),
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
          constraints: BoxConstraints(minHeight: minimumHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: spacing.spacingS,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(size: iconSize, color: palette.content),
                    child: icon!,
                  ),
                  SizedBox(width: spacing.spacingS),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: textStyle.copyWith(color: palette.content),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _isInteractive,
      selected: isSelected,
      label: semanticLabel ?? label,
      child: ExcludeSemantics(child: chip),
    );
  }

  _BebeFilterChipPalette _resolvePalette({
    required BebeFilterChipVariant variant,
    required bool isSelected,
    required bool enabled,
    required dynamic colors,
  }) {
    if (!enabled) {
      return _BebeFilterChipPalette(
        surface: colors.background.neutralsDisabled,
        content: colors.text.neutralDisabled,
        border: colors.background.neutralsDisabled,
      );
    }

    return switch (variant) {
      BebeFilterChipVariant.neutral => _BebeFilterChipPalette(
        surface: isSelected
            ? colors.background.neutralsActive
            : colors.background.neutralsSurface,
        content: colors.text.neutralTitle,
        border: colors.border.accentAlternative,
      ),
      BebeFilterChipVariant.brand => _BebeFilterChipPalette(
        surface: isSelected
            ? colors.background.brandDefault
            : colors.background.brandSurface,
        content: isSelected
            ? colors.background.neutralsSurface
            : colors.text.brandDefault,
        border: colors.border.brandAlternative,
      ),
      BebeFilterChipVariant.accent => _BebeFilterChipPalette(
        surface: isSelected
            ? colors.background.accentDefault
            : colors.background.accentSurface,
        content: isSelected
            ? colors.background.neutralsSurface
            : colors.text.accentDefault,
        border: colors.border.accentAlternative,
      ),
      BebeFilterChipVariant.information => _BebeFilterChipPalette(
        surface: isSelected
            ? colors.background.infoDefault
            : colors.background.infoSurface,
        content: isSelected
            ? colors.background.neutralsSurface
            : colors.text.infoDefault,
        border: colors.border.infoDefault,
      ),
      BebeFilterChipVariant.warning => _BebeFilterChipPalette(
        surface: isSelected
            ? colors.background.warningDefault
            : colors.background.warningSurface,
        content: isSelected
            ? colors.background.neutralsSurface
            : colors.text.warningDefault,
        border: colors.border.warningDefault,
      ),
      BebeFilterChipVariant.success => _BebeFilterChipPalette(
        surface: isSelected
            ? colors.background.successDefault
            : colors.background.successSurface,
        content: isSelected
            ? colors.background.neutralsSurface
            : colors.text.successDefault,
        border: colors.border.successDefault,
      ),
    };
  }
}

class _BebeFilterChipPalette {
  const _BebeFilterChipPalette({
    required this.surface,
    required this.content,
    required this.border,
  });

  final Color surface;
  final Color content;
  final Color border;
}
