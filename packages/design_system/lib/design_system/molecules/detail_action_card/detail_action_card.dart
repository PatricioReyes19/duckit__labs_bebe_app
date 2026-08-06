import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'deatil_action_pallete.dart';

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
  final String? metadata;
  final BebeDetailActionCardVariant variant;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _iconContainerSize = 48;
  static const double _iconSize = 24;
  static const double _chevronSlotWidth = 20;
  static const double _chevronSize = 20;

  bool get _isInteractive => onPressed != null;

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
    final effectiveMetadata = _normalizeText(metadata);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final palette = BebeDetailActionCardPalette.resolve(
      colors: colors,
      variant: variant,
    );

    final borderRadius = BorderRadius.circular(radius.radius3xl);

    final content = Padding(
      padding: EdgeInsets.all(spacing.spacingL),
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
                    size: _iconSize,
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
                  effectiveTitle,
                  style: theme.typography.styles.title.sm.semibold.copyWith(
                    color: palette.title,
                  ),
                ),
                if (effectiveDescription != null) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    effectiveDescription,
                    style: theme.typography.styles.body.sm.regular.copyWith(
                      color: palette.body,
                    ),
                  ),
                ],
                if (effectiveMetadata != null) ...[
                  SizedBox(height: spacing.spacingS),
                  Text(
                    effectiveMetadata,
                    style: theme.typography.styles.label.sm.semibold.copyWith(
                      color: palette.metadata,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isInteractive) ...[
            SizedBox(width: spacing.spacingM),
            SizedBox(
              width: _chevronSlotWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: _chevronSize,
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: elevation.low,
        ),
        child: Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: palette.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: cardContent,
        ),
      ),
    );

    final generatedSemanticLabel = [
      effectiveTitle,
      ?effectiveDescription,
      ?effectiveMetadata,
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
