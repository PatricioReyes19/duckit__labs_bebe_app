import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeUpcomingHealthCardPalette {
  const BebeUpcomingHealthCardPalette({
    required this.surface,
    required this.border,
    required this.leadingIconVariant,
    required this.chevronVariant,
    required this.divider,
  });

  final Color surface;
  final Color border;
  final BebeLeadingIconVariant leadingIconVariant;
  final BebeCardChevronVariant chevronVariant;
  final Color divider;

  static BebeUpcomingHealthCardPalette resolve({
    required BebeColor colors,
    required BebeUpcomingHealthCardVariant variant,
  }) {
    return switch (variant) {
      BebeUpcomingHealthCardVariant.brand => BebeUpcomingHealthCardPalette(
        surface: colors.background.brandSurface,
        border: colors.border.brandAlternative,
        leadingIconVariant: BebeLeadingIconVariant.brand,
        chevronVariant: BebeCardChevronVariant.brand,
        divider: colors.border.brandAlternative,
      ),

      BebeUpcomingHealthCardVariant.accent => BebeUpcomingHealthCardPalette(
        surface: colors.background.accentSurface,
        border: colors.border.accentAlternative,
        leadingIconVariant: BebeLeadingIconVariant.accent,
        chevronVariant: BebeCardChevronVariant.accent,
        divider: colors.border.accentAlternative,
      ),

      BebeUpcomingHealthCardVariant.information =>
        BebeUpcomingHealthCardPalette(
          surface: colors.background.infoSurface,
          border: colors.border.infoDefault,
          leadingIconVariant: BebeLeadingIconVariant.information,
          chevronVariant: BebeCardChevronVariant.information,
          divider: colors.border.infoDefault,
        ),

      BebeUpcomingHealthCardVariant.warning => BebeUpcomingHealthCardPalette(
        surface: colors.background.warningSurface,
        border: colors.border.warningDefault,
        leadingIconVariant: BebeLeadingIconVariant.warning,
        chevronVariant: BebeCardChevronVariant.neutral,
        divider: colors.border.warningDefault,
      ),

      BebeUpcomingHealthCardVariant.neutral => BebeUpcomingHealthCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.neutralDefault,
        leadingIconVariant: BebeLeadingIconVariant.neutral,
        chevronVariant: BebeCardChevronVariant.neutral,
        divider: colors.border.neutralDefault,
      ),
    };
  }
}
