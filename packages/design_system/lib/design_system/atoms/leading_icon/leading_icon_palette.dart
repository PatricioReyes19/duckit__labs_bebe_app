import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeLeadingIconPalette {
  const BebeLeadingIconPalette({
    required this.surface,
    required this.content,
    required this.border,
  });

  final Color surface;
  final Color content;
  final Color border;

  static BebeLeadingIconPalette resolve({
    required BebeColor colors,
    required BebeLeadingIconVariant variant,
  }) {
    return switch (variant) {
      BebeLeadingIconVariant.brand => BebeLeadingIconPalette(
        surface: colors.background.brandSurface,
        content: colors.icons.brandDefault,
        border: colors.border.brandAlternative,
      ),

      BebeLeadingIconVariant.accent => BebeLeadingIconPalette(
        surface: colors.background.accentSurface,
        content: colors.icons.accentDefault,
        border: colors.border.accentAlternative,
      ),

      BebeLeadingIconVariant.information => BebeLeadingIconPalette(
        surface: colors.background.infoSurface,
        content: colors.icons.infoDefault,
        border: colors.border.infoDefault,
      ),

      BebeLeadingIconVariant.success => BebeLeadingIconPalette(
        surface: colors.background.successSurface,
        content: colors.icons.successDefault,
        border: colors.border.successDefault,
      ),

      BebeLeadingIconVariant.warning => BebeLeadingIconPalette(
        surface: colors.background.warningSurface,
        content: colors.icons.warningDefault,
        border: colors.border.warningDefault,
      ),

      BebeLeadingIconVariant.error => BebeLeadingIconPalette(
        surface: colors.background.errorSurface,
        content: colors.icons.errorDefault,
        border: colors.border.errorDefault,
      ),

      BebeLeadingIconVariant.neutral => BebeLeadingIconPalette(
        surface: colors.background.neutralsActive,
        content: colors.icons.neutralDefault,
        border: colors.border.neutralDefault,
      ),
    };
  }
}
