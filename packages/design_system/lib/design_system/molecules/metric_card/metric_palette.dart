import 'dart:ui';

import 'package:design_system/design_system.dart';

import 'metric_variant.dart';

class BebeMetricCardPalette {
  const BebeMetricCardPalette({
    required this.surface,
    required this.iconSurface,
    required this.content,
    required this.border,
  });

  final Color surface;
  final Color iconSurface;
  final Color content;
  final Color border;

  static BebeMetricCardPalette resolve(
    BebeColor colors,
    BebeMetricCardVariant variant,
  ) {
    return switch (variant) {
      BebeMetricCardVariant.feeding => BebeMetricCardPalette(
        surface: colors.background.brandSurface,
        iconSurface: colors.background.brandDefault.withAlpha(50),
        content: colors.text.brandDefault,
        border: colors.border.brandDefault,
      ),
      BebeMetricCardVariant.sleep => BebeMetricCardPalette(
        surface: colors.background.accentSurface,
        iconSurface: colors.background.accentDefault.withAlpha(50),
        content: colors.text.accentDefault,
        border: colors.border.accentAlternative,
      ),
      BebeMetricCardVariant.diaper => BebeMetricCardPalette(
        surface: colors.background.warningSurface,
        iconSurface: colors.background.warningDefault.withAlpha(50),
        content: colors.text.warningDefault,
        border: colors.border.warningDefault,
      ),
      BebeMetricCardVariant.neutral => BebeMetricCardPalette(
        surface: colors.background.neutralsSurface,
        iconSurface: colors.background.neutralsDefault.withAlpha(50),
        content: colors.text.neutralTitle,
        border: colors.border.neutralDefault,
      ),
    };
  }
}
