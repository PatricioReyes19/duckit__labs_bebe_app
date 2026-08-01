import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'selectable_date_cell_palette.dart';

class BebeSelectableDateCell extends StatelessWidget {
  const BebeSelectableDateCell({
    required this.label,
    required this.value,
    this.indicators = const [],
    this.variant = BebeSelectableDateCellVariant.brand,
    this.emphasis = BebeSelectableDateCellEmphasis.regular,
    this.isSelected = false,
    this.isToday = false,
    this.enabled = true,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final String value;
  final List<Widget> indicators;
  final BebeSelectableDateCellVariant variant;
  final BebeSelectableDateCellEmphasis emphasis;
  final bool isSelected;
  final bool isToday;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _minimumTouchTarget = 48;
  static const double _regularMinimumHeight = 72;
  static const double _prominentMinimumHeight = 96;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final radius = theme.borderRadius;
    final overlays = theme.overlays;

    final palette = BebeSelectableDateCellPalette.resolve(
      colors: theme.colors,
      variant: variant,
    );

    final effectiveEmphasis = isSelected
        ? BebeSelectableDateCellEmphasis.prominent
        : emphasis;

    final minimumHeight = switch (effectiveEmphasis) {
      BebeSelectableDateCellEmphasis.regular => _regularMinimumHeight,
      BebeSelectableDateCellEmphasis.prominent => _prominentMinimumHeight,
    };

    final surface = isSelected ? palette.selectedSurface : Colors.transparent;

    final labelColor = !enabled
        ? palette.disabledContent
        : isSelected
        ? palette.selectedContent
        : palette.label;

    final valueColor = !enabled
        ? palette.disabledContent
        : isSelected
        ? palette.selectedContent
        : palette.value;

    final valueStyle = switch (effectiveEmphasis) {
      BebeSelectableDateCellEmphasis.regular =>
        typography.styles.title.sm.semibold,
      BebeSelectableDateCellEmphasis.prominent =>
        typography.styles.title.lg.bold,
    };

    final card = Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: isToday && !isSelected
            ? BorderSide(color: palette.border)
            : BorderSide.none,
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.spacingS,
            vertical: spacing.spacingM,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.styles.label.sm.regular.copyWith(
                  color: labelColor,
                ),
              ),
              SizedBox(height: spacing.spacingS),
              Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: valueStyle.copyWith(color: valueColor),
              ),
              SizedBox(height: spacing.spacingS),
              _SelectableDateIndicators(indicators: indicators),
            ],
          ),
        ),
      ),
    );

    final effectiveSemanticLabel =
        semanticLabel ??
        '$label $value'
            '${isToday ? '. Hoy' : ''}'
            '${isSelected ? '. Seleccionado' : ''}';

    return Semantics(
      button: true,
      enabled: _isInteractive,
      selected: isSelected,
      label: effectiveSemanticLabel,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: _minimumTouchTarget,
            minHeight: minimumHeight,
          ),
          child: card,
        ),
      ),
    );
  }
}

class _SelectableDateIndicators extends StatelessWidget {
  const _SelectableDateIndicators({required this.indicators});

  final List<Widget> indicators;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    if (indicators.isEmpty) {
      return const SizedBox(height: 6);
    }

    return SizedBox(
      height: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < indicators.length; index++) ...[
            indicators[index],
            if (index != indicators.length - 1)
              SizedBox(width: spacing.spacingXs),
          ],
        ],
      ),
    );
  }
}
