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

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final compact = constraints.maxWidth < 160 || textScale > 1.3;
        return _FamilyMetricCardContent(
          value: effectiveValue,
          label: effectiveLabel,
          icon: icon,
          palette: palette,
          interactive: _isInteractive,
          compact: compact,
        );
      },
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

class _FamilyMetricCardContent extends StatelessWidget {
  const _FamilyMetricCardContent({
    required this.value,
    required this.label,
    required this.icon,
    required this.palette,
    required this.interactive,
    required this.compact,
  });

  final String value;
  final String label;
  final Widget icon;
  final BebeFamilyMetricCardPalette palette;
  final bool interactive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final leading = SizedBox.square(
      dimension: compact ? 32 : BebeFamilyMetricCard._iconContainerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.iconSurface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: compact ? 18 : BebeFamilyMetricCard._iconSize,
              color: palette.iconContent,
            ),
            child: icon,
          ),
        ),
      ),
    );
    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.typography.styles.title.md.semibold.copyWith(
            color: palette.value,
          ),
        ),
        SizedBox(height: spacing.spacingXs),
        Text(
          label,
          style:
              (compact
                      ? theme.typography.styles.label.sm.regular
                      : theme.typography.styles.body.sm.regular)
                  .copyWith(color: palette.label),
        ),
      ],
    );
    final chevron = Icon(
      Icons.chevron_right_rounded,
      size: BebeFamilyMetricCard._chevronSize,
      color: palette.chevron,
    );

    return Padding(
      padding: EdgeInsets.all(spacing.spacingM),
      child: compact
          ? interactive
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [leading, const Spacer(), chevron]),
                      SizedBox(height: spacing.spacingM),
                      copy,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leading,
                      SizedBox(height: spacing.spacingM),
                      copy,
                    ],
                  )
          : Row(
              children: [
                leading,
                SizedBox(width: spacing.spacingM),
                Expanded(child: copy),
                if (interactive) ...[
                  SizedBox(width: spacing.spacingS),
                  chevron,
                ],
              ],
            ),
    );
  }
}
