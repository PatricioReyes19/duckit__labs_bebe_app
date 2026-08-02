import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeCarouselPageIndicator extends StatelessWidget {
  const BebeCarouselPageIndicator({
    required this.itemCount,
    required this.currentIndex,
    super.key,
  }) : assert(itemCount > 0, 'itemCount must be greater than zero.'),
       assert(
         currentIndex >= 0 && currentIndex < itemCount,
         'currentIndex must be inside the item range.',
       );

  final int itemCount;
  final int currentIndex;

  static const double _activeWidth = 18;
  static const double _inactiveSize = 8;
  static const double _indicatorHeight = 8;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    return Semantics(
      label: 'Página ${currentIndex + 1} de $itemCount',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < itemCount; index++) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: index == currentIndex ? _activeWidth : _inactiveSize,
                height: _indicatorHeight,
                decoration: ShapeDecoration(
                  color: index == currentIndex
                      ? colors.text.brandDefault
                      : colors.background.neutralsActive,
                  shape: const StadiumBorder(),
                ),
              ),
              if (index < itemCount - 1) SizedBox(width: spacing.spacingS),
            ],
          ],
        ),
      ),
    );
  }
}
