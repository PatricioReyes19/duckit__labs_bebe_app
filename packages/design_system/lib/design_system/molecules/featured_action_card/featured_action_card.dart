import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeFeatureActionCard extends StatelessWidget {
  const BebeFeatureActionCard({
    required this.title,
    required this.icon,
    this.description,
    this.variant = BebeFeaturedActionCardVariant.neutral,
    this.onPressed,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final Widget icon;
  final String? description;
  final BebeFeaturedActionCardVariant variant;
  final VoidCallback? onPressed;
  final bool enabled;
  final String? semanticLabel;

  static const double _minimumHeight = 104;
  static const double _iconContainerSize = 48;
  static const double _iconSize = 24;
  static const double _chevronSlotWidth = 20;
  static const double _chevronIconSize = 20;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;
    final colors = theme.colors;

    final effectiveTitle = title.trim();
    final effectiveDescription = _normalizeText(description);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final palette = BebeFeatureActionCardPalette.resolve(
      colors: colors,
      variant: variant,
      enabled: enabled,
    );

    final cardBorderRadius = BorderRadius.circular(radius.radius3xl);

    final content = Padding(
      padding: EdgeInsets.all(spacing.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: _iconContainerSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.iconSurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(
                    color: palette.iconContent,
                    size: _iconSize,
                  ),
                  child: icon,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing.spacingM),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effectiveTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.styles.title.sm.semibold.copyWith(
                    color: palette.title,
                  ),
                ),
                if (effectiveDescription != null) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    effectiveDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.styles.body.sm.regular.copyWith(
                      color: palette.description,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isInteractive) ...[
            SizedBox(width: spacing.spacingS),
            SizedBox(
              width: _chevronSlotWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: _chevronIconSize,
                  color: palette.chevron,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final cardContent = _isInteractive
        ? InkWell(
            onTap: onPressed,
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
            child: content,
          )
        : content;

    final visualCard = SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minimumHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: cardBorderRadius,
            boxShadow: enabled ? elevation.low : const [],
          ),
          child: Material(
            color: palette.surface,
            shape: RoundedRectangleBorder(
              borderRadius: cardBorderRadius,
              side: BorderSide(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: cardContent,
          ),
        ),
      ),
    );

    final generatedSemanticLabel = [
      effectiveTitle,
      if (effectiveDescription != null) effectiveDescription,
    ].join('. ');

    final resolvedSemanticLabel =
        effectiveSemanticLabel ?? generatedSemanticLabel;

    if (_isInteractive) {
      return Semantics(
        container: true,
        button: true,
        enabled: true,
        label: resolvedSemanticLabel,
        child: ExcludeSemantics(child: visualCard),
      );
    }

    return Semantics(
      container: true,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: visualCard),
    );
  }

  static String? _normalizeText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}

class BebeFeatureActionCardPalette {
  const BebeFeatureActionCardPalette({
    required this.surface,
    required this.border,
    required this.iconSurface,
    required this.iconContent,
    required this.title,
    required this.description,
    required this.chevron,
  });

  final Color surface;
  final Color border;
  final Color iconSurface;
  final Color iconContent;
  final Color title;
  final Color description;
  final Color chevron;

  static BebeFeatureActionCardPalette resolve({
    required BebeColor colors,
    required BebeFeaturedActionCardVariant variant,
    required bool enabled,
  }) {
    if (!enabled) {
      return BebeFeatureActionCardPalette(
        surface: colors.background.neutralsDisabled,
        border: colors.border.neutralDefault,
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
        title: colors.text.neutralDisabled,
        description: colors.text.neutralDisabled,
        chevron: colors.icons.neutralAlternative,
      );
    }

    return switch (variant) {
      BebeFeaturedActionCardVariant.neutral => BebeFeatureActionCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.neutralDefault,
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
        title: colors.text.neutralTitle,
        description: colors.text.neutralBody,
        chevron: colors.icons.neutralAlternative,
      ),

      BebeFeaturedActionCardVariant.brand => BebeFeatureActionCardPalette(
        surface: colors.background.brandSurface,
        border: colors.border.brandAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.brandDefault,
        title: colors.text.brandDefault,
        description: colors.text.neutralBody,
        chevron: colors.text.brandDefault,
      ),

      BebeFeaturedActionCardVariant.accent => BebeFeatureActionCardPalette(
        surface: colors.background.accentSurface,
        border: colors.border.accentAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.icons.accentDefault,
        title: colors.text.accentDefault,
        description: colors.text.neutralBody,
        chevron: colors.icons.accentDefault,
      ),

      BebeFeaturedActionCardVariant.information => BebeFeatureActionCardPalette(
        surface: colors.background.infoSurface,
        border: colors.border.infoDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.infoDefault,
        title: colors.text.infoDefault,
        description: colors.text.neutralBody,
        chevron: colors.text.infoDefault,
      ),

      BebeFeaturedActionCardVariant.warning => BebeFeatureActionCardPalette(
        surface: colors.background.warningSurface,
        border: colors.border.warningDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.warningDefault,
        title: colors.text.warningDefault,
        description: colors.text.neutralBody,
        chevron: colors.text.warningDefault,
      ),

      BebeFeaturedActionCardVariant.success => BebeFeatureActionCardPalette(
        surface: colors.background.successSurface,
        border: colors.border.successDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.successDefault,
        title: colors.text.successDefault,
        description: colors.text.neutralBody,
        chevron: colors.text.successDefault,
      ),
    };
  }
}
