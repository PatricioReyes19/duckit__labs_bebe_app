import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'indicator_dot_variant.dart';

class IndicatorDotPalette {
  const IndicatorDotPalette({required this.color});

  final Color color;

  static IndicatorDotPalette resolve({
    required BebeColor colors,
    required IndicatorDotVariant variant,
  }) {
    return switch (variant) {
      IndicatorDotVariant.neutral => IndicatorDotPalette(
        color: colors.text.neutralBody,
      ),
      IndicatorDotVariant.brand => IndicatorDotPalette(
        color: colors.background.brandDefault,
      ),
      IndicatorDotVariant.accent => IndicatorDotPalette(
        color: colors.background.accentDefault,
      ),
      IndicatorDotVariant.information => IndicatorDotPalette(
        color: colors.background.infoDefault,
      ),
      IndicatorDotVariant.success => IndicatorDotPalette(
        color: colors.background.successDefault,
      ),
      IndicatorDotVariant.warning => IndicatorDotPalette(
        color: colors.background.warningDefault,
      ),
    };
  }
}
