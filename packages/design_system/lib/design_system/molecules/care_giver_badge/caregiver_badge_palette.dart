import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeCaregiverBadgePalette {
  const BebeCaregiverBadgePalette({
    required this.surface,
    required this.content,
    this.border,
  });

  final Color surface;
  final Color content;
  final Color? border;

  static BebeCaregiverBadgePalette resolve({
    required BebeColor colors,
    required BebeCaregiverBadgeVariant variant,
  }) {
    return switch (variant) {
      BebeCaregiverBadgeVariant.brand => BebeCaregiverBadgePalette(
        surface: colors.background.brandSurface,
        content: colors.text.brandDefault,
        border: colors.border.brandAlternative,
      ),
      BebeCaregiverBadgeVariant.accent => BebeCaregiverBadgePalette(
        surface: colors.background.accentSurface,
        content: colors.text.accentDefault,
        border: colors.border.accentAlternative,
      ),
      BebeCaregiverBadgeVariant.neutral => BebeCaregiverBadgePalette(
        surface: colors.background.neutralsSurface,
        content: colors.text.neutralBody,
      ),
    };
  }
}
