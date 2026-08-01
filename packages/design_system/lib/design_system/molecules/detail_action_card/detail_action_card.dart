import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeDetailActionCard extends StatelessWidget {
  const BebeDetailActionCard({
    required this.title,
    required this.icon,
    this.description,
    this.metadata,
    this.variant = BebeDetailActionCardVariant.neutral,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final Widget icon;
  final String? description;

  /// Metadata opcional ubicada debajo de la descripción.
  ///
  /// Ejemplo:
  /// "12 jun 2025 · 11:30"
  final String? metadata;

  final BebeDetailActionCardVariant variant;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _leadingContainerSize = 48;
  static const double _leadingIconSize = 24;
  static const double _chevronSlotWidth = 20;
  static const double _chevronIconSize = 20;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = theme.borderRadius;
    final overlays = theme.overlays;
    final elevation = theme.elevation;

    final palette = _BebeDetailActionCardPalette.resolve(
      context: context,
      variant: variant,
    );

    final effectiveDescription = description?.trim();
    final effectiveMetadata = metadata?.trim();

    final card = Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
        child: _BebeDetailActionCardContent(
          title: title,
          description: effectiveDescription,
          metadata: effectiveMetadata,
          icon: icon,
          palette: palette,
          showChevron: onPressed != null,
        ),
      ),
    );

    final effectiveSemanticLabel =
        semanticLabel ??
        [
          title,
          if (effectiveDescription != null && effectiveDescription.isNotEmpty)
            effectiveDescription,
          if (effectiveMetadata != null && effectiveMetadata.isNotEmpty)
            effectiveMetadata,
        ].join('. ');

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: onPressed != null,
      label: effectiveSemanticLabel,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.radius3xl),
            boxShadow: elevation.low,
          ),
          child: card,
        ),
      ),
    );
  }
}

class _BebeDetailActionCardContent extends StatelessWidget {
  const _BebeDetailActionCardContent({
    required this.title,
    required this.description,
    required this.metadata,
    required this.icon,
    required this.palette,
    required this.showChevron,
  });

  final String title;
  final String? description;
  final String? metadata;
  final Widget icon;

  final _BebeDetailActionCardPalette palette;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.spacingL,
        vertical: spacing.spacingL,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: BebeDetailActionCard._leadingContainerSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.iconSurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(
                    size: BebeDetailActionCard._leadingIconSize,
                    color: palette.iconContent,
                  ),
                  child: icon,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing.spacingL),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.styles.title.sm.semibold.copyWith(
                    color: palette.title,
                  ),
                ),
                if (description != null && description!.isNotEmpty) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    description!,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: typography.styles.body.md.regular.copyWith(
                      color: palette.body,
                    ),
                  ),
                ],
                if (metadata != null && metadata!.isNotEmpty) ...[
                  SizedBox(height: spacing.spacingS),
                  Text(
                    metadata!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typography.styles.label.sm.semibold.copyWith(
                      color: palette.metadata,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showChevron) ...[
            SizedBox(width: spacing.spacingM),
            SizedBox(
              width: BebeDetailActionCard._chevronSlotWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: BebeDetailActionCard._chevronIconSize,
                  color: palette.chevron,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BebeDetailActionCardPalette {
  const _BebeDetailActionCardPalette({
    required this.surface,
    required this.border,
    required this.iconSurface,
    required this.iconContent,
    required this.title,
    required this.body,
    required this.metadata,
    required this.chevron,
  });

  final Color surface;
  final Color border;
  final Color iconSurface;
  final Color iconContent;
  final Color title;
  final Color body;
  final Color metadata;
  final Color chevron;

  static _BebeDetailActionCardPalette resolve({
    required BuildContext context,
    required BebeDetailActionCardVariant variant,
  }) {
    final colors = context.theme.colors;

    return switch (variant) {
      BebeDetailActionCardVariant.neutral => _BebeDetailActionCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.accentAlternative,
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
        title: colors.text.neutralTitle,
        body: colors.text.neutralBody,
        metadata: colors.text.neutralBody,
        chevron: colors.icons.neutralAlternative,
      ),
      BebeDetailActionCardVariant.brand => _BebeDetailActionCardPalette(
        surface: colors.background.brandSurface,
        border: colors.border.brandAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.brandDefault,
        title: colors.text.brandDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.brandDefault,
        chevron: colors.text.brandDefault,
      ),
      BebeDetailActionCardVariant.accent => _BebeDetailActionCardPalette(
        surface: colors.background.accentSurface,
        border: colors.border.accentAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.icons.accentDefault,
        title: colors.text.accentDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.accentDefault,
        chevron: colors.icons.accentDefault,
      ),
      BebeDetailActionCardVariant.information => _BebeDetailActionCardPalette(
        surface: colors.background.infoSurface,
        border: colors.border.infoDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.infoDefault,
        title: colors.text.infoDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.infoDefault,
        chevron: colors.text.infoDefault,
      ),
      BebeDetailActionCardVariant.warning => _BebeDetailActionCardPalette(
        surface: colors.background.warningSurface,
        border: colors.border.warningDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.warningDefault,
        title: colors.text.warningDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.warningDefault,
        chevron: colors.text.warningDefault,
      ),
      BebeDetailActionCardVariant.success => _BebeDetailActionCardPalette(
        surface: colors.background.successSurface,
        border: colors.border.successDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.successDefault,
        title: colors.text.successDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.successDefault,
        chevron: colors.text.successDefault,
      ),
    };
  }
}
