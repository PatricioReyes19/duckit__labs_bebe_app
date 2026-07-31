import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'status_badge_variant.dart';

@immutable
class BebeStatusBadgePalette {
  const BebeStatusBadgePalette({
    required this.surface,
    required this.content,
    required this.border,
    required this.icon,
  });

  final Color surface;
  final Color content;
  final Color border;
  final Color icon;

  static BebeStatusBadgePalette resolve({
    required BebeColor colors,
    required BebeStatusBadgeVariant variant,
  }) {
    return switch (variant) {
      BebeStatusBadgeVariant.neutral => BebeStatusBadgePalette(
        surface: colors.background.neutralsActive,
        content: colors.text.neutralBody,
        border: colors.border.neutralDefault,
        icon: colors.icons.neutralAlternative,
      ),

      BebeStatusBadgeVariant.success => BebeStatusBadgePalette(
        surface: colors.background.successSurface,
        content: colors.text.successDefault,
        border: colors.border.successDefault,
        icon: colors.icons.successDefault,
      ),

      BebeStatusBadgeVariant.information => BebeStatusBadgePalette(
        surface: colors.background.infoSurface,
        content: colors.text.infoDefault,
        border: colors.border.infoDefault,
        icon: colors.icons.infoDefault,
      ),

      BebeStatusBadgeVariant.warning => BebeStatusBadgePalette(
        surface: colors.background.warningSurface,
        content: colors.text.warningDefault,
        border: colors.border.warningDefault,
        icon: colors.icons.warningDefault,
      ),

      BebeStatusBadgeVariant.error => BebeStatusBadgePalette(
        surface: colors.background.errorSurface,
        content: colors.text.errorDefault,
        border: colors.border.errorDefault,
        icon: colors.icons.errorDefault,
      ),
    };
  }
}
