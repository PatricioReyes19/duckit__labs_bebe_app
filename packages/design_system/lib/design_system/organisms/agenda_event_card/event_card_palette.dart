import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeAgendaEventCardPalette {
  const BebeAgendaEventCardPalette({
    required this.surface,
    required this.border,
    required this.leadingIconVariant,
    required this.chevronVariant,
  });

  final Color surface;
  final Color border;
  final BebeLeadingIconVariant leadingIconVariant;
  final BebeCardChevronVariant chevronVariant;

  static BebeAgendaEventCardPalette resolve({
    required BebeColor colors,
    required BebeAgendaEventCardVariant variant,
  }) {
    return switch (variant) {
      BebeAgendaEventCardVariant.neutral => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.accentAlternative,
        leadingIconVariant: BebeLeadingIconVariant.neutral,
        chevronVariant: BebeCardChevronVariant.neutral,
      ),
      BebeAgendaEventCardVariant.brand => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.brandAlternative,
        leadingIconVariant: BebeLeadingIconVariant.brand,
        chevronVariant: BebeCardChevronVariant.brand,
      ),
      BebeAgendaEventCardVariant.accent => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.accentAlternative,
        leadingIconVariant: BebeLeadingIconVariant.accent,
        chevronVariant: BebeCardChevronVariant.accent,
      ),
      BebeAgendaEventCardVariant.information => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.infoDefault,
        leadingIconVariant: BebeLeadingIconVariant.information,
        chevronVariant: BebeCardChevronVariant.information,
      ),
      BebeAgendaEventCardVariant.warning => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.warningDefault,
        leadingIconVariant: BebeLeadingIconVariant.warning,
        chevronVariant: BebeCardChevronVariant.neutral,
      ),
      BebeAgendaEventCardVariant.success => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.successDefault,
        leadingIconVariant: BebeLeadingIconVariant.success,
        chevronVariant: BebeCardChevronVariant.neutral,
      ),
    };
  }
}
