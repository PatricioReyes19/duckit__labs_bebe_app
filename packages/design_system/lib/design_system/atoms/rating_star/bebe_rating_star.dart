import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Atomic star used by read-only ratings and interactive rating selectors.
class BebeRatingStar extends StatelessWidget {
  const BebeRatingStar({
    required this.selected,
    this.onPressed,
    this.size = 32,
    this.semanticLabel,
    super.key,
  }) : assert(size > 0);

  final bool selected;
  final VoidCallback? onPressed;
  final double size;
  final String? semanticLabel;

  static const double _minimumTouchTarget = 48;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final selectedColor = theme.colors.icons.warningDefault;
    final unselectedColor = theme.colors.icons.neutralDisabled;
    final icon = Icon(
      selected ? Icons.star_rounded : Icons.star_border_rounded,
      size: size,
      color: selected ? selectedColor : unselectedColor,
    );
    final label = semanticLabel ??
        (selected ? 'Estrella seleccionada' : 'Estrella no seleccionada');

    if (onPressed == null) {
      return Semantics(
        image: true,
        selected: selected,
        label: label,
        child: ExcludeSemantics(child: icon),
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: SizedBox.square(
        dimension: _minimumTouchTarget,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          tooltip: label,
          icon: icon,
        ),
      ),
    );
  }
}
