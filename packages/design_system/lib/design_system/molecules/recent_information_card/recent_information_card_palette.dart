import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeRecentInformationCardPalette {
  const BebeRecentInformationCardPalette({
    required this.surface,
    required this.border,
    required this.leadingIconVariant,
    required this.chevronVariant,
  });

  final Color surface;
  final Color border;
  final BebeLeadingIconVariant leadingIconVariant;
  final BebeCardChevronVariant chevronVariant;

  static BebeRecentInformationCardPalette resolve({
    required BebeColor colors,
    required BebeRecentInformationCardVariant variant,
  }) {
    return switch (variant) {
      BebeRecentInformationCardVariant.brand =>
        BebeRecentInformationCardPalette(
          surface: colors.background.brandSurface,
          border: colors.border.brandAlternative,
          leadingIconVariant: BebeLeadingIconVariant.brand,
          chevronVariant: BebeCardChevronVariant.brand,
        ),

      BebeRecentInformationCardVariant.accent =>
        BebeRecentInformationCardPalette(
          surface: colors.background.accentSurface,
          border: colors.border.accentAlternative,
          leadingIconVariant: BebeLeadingIconVariant.accent,
          chevronVariant: BebeCardChevronVariant.accent,
        ),

      BebeRecentInformationCardVariant.information =>
        BebeRecentInformationCardPalette(
          surface: colors.background.infoSurface,
          border: colors.border.infoDefault,
          leadingIconVariant: BebeLeadingIconVariant.information,
          chevronVariant: BebeCardChevronVariant.information,
        ),

      BebeRecentInformationCardVariant.success =>
        BebeRecentInformationCardPalette(
          surface: colors.background.successSurface,
          border: colors.border.successDefault,
          leadingIconVariant: BebeLeadingIconVariant.success,
          chevronVariant: BebeCardChevronVariant.neutral,
        ),

      BebeRecentInformationCardVariant.warning =>
        BebeRecentInformationCardPalette(
          surface: colors.background.warningSurface,
          border: colors.border.warningDefault,
          leadingIconVariant: BebeLeadingIconVariant.warning,
          chevronVariant: BebeCardChevronVariant.neutral,
        ),

      BebeRecentInformationCardVariant.neutral =>
        BebeRecentInformationCardPalette(
          surface: colors.background.neutralsSurface,
          border: colors.border.neutralDefault,
          leadingIconVariant: BebeLeadingIconVariant.neutral,
          chevronVariant: BebeCardChevronVariant.neutral,
        ),
    };
  }
}
