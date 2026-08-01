import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeInfoBannerPalette {
  const BebeInfoBannerPalette({
    required this.surface,
    required this.border,
    required this.content,
    required this.iconSurface,
    required this.iconContent,
  });

  final Color surface;
  final Color border;
  final Color content;
  final Color iconSurface;
  final Color iconContent;

  static BebeInfoBannerPalette resolve({
    required BebeColor colors,
    required BebeInfoBannerVariant variant,
  }) {
    return switch (variant) {
      BebeInfoBannerVariant.neutral => BebeInfoBannerPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.accentAlternative,
        content: colors.text.neutralBody,
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
      ),
      BebeInfoBannerVariant.brand => BebeInfoBannerPalette(
        surface: colors.background.brandSurface,
        border: colors.border.brandAlternative,
        content: colors.text.brandDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.brandDefault,
      ),
      BebeInfoBannerVariant.accent => BebeInfoBannerPalette(
        surface: colors.background.accentSurface,
        border: colors.border.accentAlternative,
        content: colors.text.accentDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.icons.accentDefault,
      ),
      BebeInfoBannerVariant.information => BebeInfoBannerPalette(
        surface: colors.background.infoSurface,
        border: colors.border.infoDefault,
        content: colors.text.infoDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.infoDefault,
      ),
      BebeInfoBannerVariant.success => BebeInfoBannerPalette(
        surface: colors.background.successSurface,
        border: colors.border.successDefault,
        content: colors.text.successDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.successDefault,
      ),
      BebeInfoBannerVariant.warning => BebeInfoBannerPalette(
        surface: colors.background.warningSurface,
        border: colors.border.warningDefault,
        content: colors.text.warningDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.warningDefault,
      ),
    };
  }
}
