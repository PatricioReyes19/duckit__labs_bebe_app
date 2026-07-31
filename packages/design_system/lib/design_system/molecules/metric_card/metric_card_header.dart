import 'package:design_system/design_system/design_system.dart';
import 'package:design_system/themes/theme_context.dart';
import 'package:flutter/material.dart';

class MetricCardHeader extends StatelessWidget {
  const MetricCardHeader({
    required this.label,
    required this.icon,
    required this.palette,
    super.key,
  });

  final String label;
  final Widget icon;
  final BebeMetricCardPalette palette;

  static const double _iconContainerSize = 40;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _iconContainerSize,
          height: _iconContainerSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.iconSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: palette.content, size: _iconSize),
                child: icon,
              ),
            ),
          ),
        ),
        SizedBox(width: spacing.spacingM),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.styles.label.sm.semibold.copyWith(
              color: palette.content,
            ),
          ),
        ),
      ],
    );
  }
}
