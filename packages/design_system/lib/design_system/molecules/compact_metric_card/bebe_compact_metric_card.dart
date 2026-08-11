import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Compact statistic used by report, consultation and family summaries.
class BebeCompactMetricCard extends StatelessWidget {
  const BebeCompactMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.unit,
    this.supportingText,
    this.status,
    this.trend,
    this.variant = BebeMetricCardVariant.neutral,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final String value;
  final String? unit;
  final String? supportingText;
  final Widget icon;
  final Widget? status;
  final Widget? trend;
  final BebeMetricCardVariant variant;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _minimumHeight = 112;
  static const double _iconContainerSize = 36;
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final palette = BebeMetricCardPalette.resolve(colors, variant);
    final radius = BorderRadius.circular(theme.borderRadius.radius3xl);
    final normalizedUnit = _normalize(unit);
    final normalizedSupporting = _normalize(supportingText);

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final compact = constraints.maxWidth < 124 || textScale > 1.3;
        final iconContainerSize = compact ? 32.0 : _iconContainerSize;
        final iconSize = compact ? 18.0 : _iconSize;
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minimumHeight),
          child: Padding(
            padding: EdgeInsets.all(
              compact ? spacing.spacingM : spacing.spacingL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: iconContainerSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette.iconSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: IconTheme(
                            data: IconThemeData(
                              size: iconSize,
                              color: palette.content,
                            ),
                            child: icon,
                          ),
                        ),
                      ),
                    ),
                    if (status != null) ...[
                      SizedBox(width: spacing.spacingS),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: status!,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: compact ? spacing.spacingS : spacing.spacingM),
                Text(
                  label,
                  style:
                      (compact
                              ? theme.typography.styles.label.sm.semibold
                              : theme.typography.styles.label.md.semibold)
                          .copyWith(color: palette.content),
                ),
                SizedBox(height: spacing.spacingXs),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: spacing.spacingXs,
                  children: [
                    Text(
                      value,
                      style:
                          (compact
                                  ? theme.typography.styles.title.md.bold
                                  : theme.typography.styles.title.lg.bold)
                              .copyWith(color: colors.text.neutralTitle),
                    ),
                    if (normalizedUnit != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: spacing.spacingXs),
                        child: Text(
                          normalizedUnit,
                          style: theme.typography.styles.label.sm.regular
                              .copyWith(color: colors.text.neutralBody),
                        ),
                      ),
                  ],
                ),
                if (normalizedSupporting != null) ...[
                  SizedBox(height: spacing.spacingS),
                  Text(
                    normalizedSupporting,
                    style:
                        (compact
                                ? theme.typography.styles.label.sm.regular
                                : theme.typography.styles.body.sm.regular)
                            .copyWith(color: colors.text.neutralBody),
                  ),
                ],
                if (trend != null) ...[
                  SizedBox(height: spacing.spacingS),
                  trend!,
                ],
              ],
            ),
          ),
        );
      },
    );

    final card = Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onPressed, child: content),
    );

    final generatedLabel = [
      label,
      value,
      ?normalizedUnit,
      ?normalizedSupporting,
    ].join('. ');

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: onPressed != null,
      label: semanticLabel ?? generatedLabel,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: theme.elevation.low,
          ),
          child: card,
        ),
      ),
    );
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
