import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'bebe_family_metric_card_palette.dart';

class BebeFamilyMetricCard extends StatelessWidget {
  const BebeFamilyMetricCard({
    required this.value,
    required this.label,
    required this.icon,
    this.variant = BebeFamilyMetricCardVariant.neutral,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String value;
  final String label;
  final Widget icon;
  final BebeFamilyMetricCardVariant variant;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _minimumHeight = 88;
  static const double _iconContainerSize = 44;
  static const double _iconSize = 22;
  static const double _chevronSize = 18;

  bool get _isInteractive => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;
    final palette = BebeFamilyMetricCardPalette.resolve(
      colors: colors,
      variant: variant,
    );
    final cardRadius = BorderRadius.circular(radius.radius3xl);
    final effectiveValue = value.trim();
    final effectiveLabel = label.trim();
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final content = Padding(
      padding: EdgeInsets.all(spacing.spacingM),
      child: Row(
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
          SizedBox(width: spacing.spacingM),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effectiveValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.styles.title.md.semibold.copyWith(
                    color: palette.value,
                  ),
                ),
                SizedBox(height: spacing.spacingXs),
                Text(
                  effectiveLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.styles.body.sm.regular.copyWith(
                    color: palette.label,
                  ),
                ),
              ],
            ),
          ),
          if (_isInteractive) ...[
            SizedBox(width: spacing.spacingS),
            Icon(
              Icons.chevron_right_rounded,
              size: _chevronSize,
              color: palette.chevron,
            ),
          ],
        ],
      ),
    );

    final materialContent = _isInteractive
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
            borderRadius: cardRadius,
            boxShadow: elevation.low,
          ),
          child: Material(
            color: palette.surface,
            shape: RoundedRectangleBorder(
              borderRadius: cardRadius,
              side: BorderSide(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: materialContent,
          ),
        ),
      ),
    );

    final resolvedSemanticLabel =
        effectiveSemanticLabel ?? '$effectiveValue. $effectiveLabel';
    return Semantics(
      container: true,
      button: _isInteractive,
      enabled: _isInteractive ? true : null,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: visualCard),
    );
  }

  static String? _normalizeText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
