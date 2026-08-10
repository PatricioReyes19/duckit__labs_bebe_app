import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'metric_card_body.dart';

class BebeMetricCard extends StatelessWidget {
  const BebeMetricCard({
    required this.variant,
    required this.label,
    required this.icon,
    this.value,
    this.unit,
    this.trailing,
    this.content,
    this.supporting,
    this.footer,
    this.showFooterDivider = true,
    this.semanticLabel,
    this.onPressed,
    super.key,
  });

  final BebeMetricCardVariant variant;
  final String label;
  final Widget icon;

  final String? value;

  final String? unit;

  final Widget? trailing;

  final Widget? content;

  final Widget? supporting;

  final Widget? footer;

  final bool showFooterDivider;

  final String? semanticLabel;

  final VoidCallback? onPressed;

  static const double _minimumHeight = 168;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;
    final colors = theme.colors;

    final palette = BebeMetricCardPalette.resolve(colors, variant);

    final effectiveValue = _normalizeText(value);
    final effectiveUnit = _normalizeText(unit);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final cardBorderRadius = BorderRadius.circular(radius.radius3xl);

    final cardContent = Padding(
      padding: EdgeInsets.all(spacing.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricCardHeader(
            label: label,
            icon: icon,
            palette: palette,
            trailing: trailing,
          ),
          if (effectiveValue != null) ...[
            SizedBox(height: spacing.spacingL),
            MetricCardValue(value: effectiveValue, unit: effectiveUnit),
          ],
          if (content != null) ...[
            SizedBox(height: spacing.spacingL),
            SizedBox(width: double.infinity, child: content),
          ],
          if (supporting != null) ...[
            SizedBox(height: spacing.spacingL),
            SizedBox(width: double.infinity, child: supporting),
          ],
          if (footer != null) ...[
            SizedBox(height: spacing.spacingL),
            if (showFooterDivider) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: colors.border.neutralDefault,
              ),
              SizedBox(height: spacing.spacingM),
            ],
            SizedBox(width: double.infinity, child: footer),
          ],
        ],
      ),
    );

    final materialContent = onPressed == null
        ? cardContent
        : InkWell(
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
            child: cardContent,
          );

    final visualCard = SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: _minimumHeight,
          minWidth: 60,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: cardBorderRadius,
            boxShadow: elevation.low,
          ),
          child: Material(
            color: palette.surface,
            shape: RoundedRectangleBorder(
              borderRadius: cardBorderRadius,
              side: BorderSide(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: materialContent,
          ),
        ),
      ),
    );

    if (effectiveSemanticLabel != null) {
      return Semantics(
        container: true,
        button: onPressed != null,
        enabled: onPressed != null ? true : null,
        label: effectiveSemanticLabel,
        child: ExcludeSemantics(child: visualCard),
      );
    }

    if (onPressed != null) {
      return Semantics(
        container: true,
        button: true,
        enabled: true,
        child: visualCard,
      );
    }

    return Semantics(container: true, child: visualCard);
  }

  static String? _normalizeText(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}
