import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'metric_card_body.dart';
import 'metric_card_header.dart';
import 'metric_palette.dart';
import 'metric_variant.dart';

class BebeMetricCard extends StatelessWidget {
  const BebeMetricCard({
    required this.variant,
    required this.label,
    required this.value,
    required this.unit,
    required this.supportingLabel,
    required this.supportingValue,
    required this.icon,
    this.semanticLabel,
    this.onPressed,
    super.key,
  });

  final BebeMetricCardVariant variant;
  final String label;
  final String value;
  final String unit;
  final String supportingLabel;
  final String supportingValue;
  final Widget icon;
  final String? semanticLabel;
  final VoidCallback? onPressed;

  static const double _minimumHeight = 168;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;

    final palette = BebeMetricCardPalette.resolve(colors, variant);

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: onPressed != null,
      label:
          semanticLabel ??
          '$label. $value $unit. $supportingLabel. $supportingValue.',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minimumHeight),
        child: Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius.x3l,
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
            child: DecoratedBox(
              decoration: BoxDecoration(boxShadow: elevation.low),
              child: Padding(
                padding: EdgeInsets.all(spacing.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MetricCardHeader(
                      label: label,
                      icon: icon,
                      palette: palette,
                    ),
                    SizedBox(height: spacing.spacingL),
                    MetricCardValue(value: value, unit: unit),
                    SizedBox(height: spacing.spacingL),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.border.neutralDefault,
                    ),
                    SizedBox(height: spacing.spacingM),
                    Text(
                      supportingLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.styles.body.sm.regular.copyWith(
                        color: colors.text.neutralBody,
                      ),
                    ),
                    SizedBox(height: spacing.spacingXs),
                    Text(
                      supportingValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.styles.label.lg.semibold.copyWith(
                        color: palette.content,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
