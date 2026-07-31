import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'selectable_date_cell_palette.dart';

class BebeSelectableDateCell extends StatelessWidget {
  const BebeSelectableDateCell({
    required this.label,
    required this.value,
    this.indicators = const [],
    this.variant = BebeSelectableDateCellVariant.brand,
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
  final bool isSelected;
  final bool isToday;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? semanticLabel;

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

    final surface = isSelected ? palette.selectedSurface : palette.surface;

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

    final content = Material(
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
            horizontal: spacing.spacingM,
            vertical: spacing.spacingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                overflow: TextOverflow.ellipsis,
                style: typography.styles.title.md.semibold.copyWith(
                  color: valueColor,
                ),
              ),
              SizedBox(height: spacing.spacingS),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 6 / 2),
                child: _DateCellIndicators(indicators: indicators),
              ),
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
          constraints: BoxConstraints(minWidth: 48, minHeight: 48),
          child: content,
        ),
      ),
    );
  }
}

class _DateCellIndicators extends StatelessWidget {
  const _DateCellIndicators({required this.indicators});

  final List<Widget> indicators;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing.spacingXs,
      runSpacing: spacing.spacingXs,
      children: indicators,
    );
  }
}
