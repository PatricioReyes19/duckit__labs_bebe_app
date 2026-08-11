import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class MetricCardHeader extends StatelessWidget {
  const MetricCardHeader({
    required this.label,
    required this.icon,
    required this.palette,
    this.trailing,
    super.key,
  });

  final String label;
  final Widget icon;
  final BebeMetricCardPalette palette;

  /// Contenido visual opcional ubicado al final del encabezado.
  ///
  /// Puede utilizarse para un badge, estado, tendencia o percentil.
  ///
  /// No debe contener una acción interactiva cuando la card completa
  /// tenga un [onPressed].
  final Widget? trailing;

  static const double _iconContainerSize = 40;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;

    final leading = SizedBox.square(
      dimension: _iconContainerSize,
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
    );
    final copy = Text(
      label,
      style: typography.styles.label.sm.semibold.copyWith(
        color: palette.content,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 140) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  leading,
                  if (trailing != null) ...[
                    SizedBox(width: spacing.spacingS),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: trailing!,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: spacing.spacingM),
              copy,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading,
            SizedBox(width: spacing.spacingM),
            Expanded(child: copy),
            if (trailing != null) ...[
              SizedBox(width: spacing.spacingM),
              Flexible(fit: FlexFit.loose, child: trailing!),
            ],
          ],
        );
      },
    );
  }
}
