import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeAgendaEventCardPalette {
  const BebeAgendaEventCardPalette({
    required this.surface,
    required this.border,
    required this.iconSurface,
    required this.iconContent,
    required this.chevronContent,
  });

  final Color surface;
  final Color border;
  final Color iconSurface;
  final Color iconContent;
  final Color chevronContent;

  static BebeAgendaEventCardPalette resolve({
    required BebeColor colors,
    required BebeAgendaEventCardVariant variant,
  }) {
    return switch (variant) {
      BebeAgendaEventCardVariant.neutral => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.neutralDefault,
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
        chevronContent: colors.icons.neutralAlternative,
      ),

      BebeAgendaEventCardVariant.brand => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.brandAlternative,
        iconSurface: colors.background.brandSurface,
        iconContent: colors.text.brandDefault,
        chevronContent: colors.text.brandDefault,
      ),

      BebeAgendaEventCardVariant.accent => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.accentAlternative,
        iconSurface: colors.background.accentSurface,
        iconContent: colors.icons.accentDefault,
        chevronContent: colors.icons.accentDefault,
      ),

      BebeAgendaEventCardVariant.information => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.infoDefault,
        iconSurface: colors.background.infoSurface,
        iconContent: colors.text.infoDefault,
        chevronContent: colors.text.infoDefault,
      ),

      BebeAgendaEventCardVariant.warning => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.warningDefault,
        iconSurface: colors.background.warningSurface,
        iconContent: colors.text.warningDefault,
        chevronContent: colors.icons.neutralAlternative,
      ),

      BebeAgendaEventCardVariant.success => BebeAgendaEventCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.successDefault,
        iconSurface: colors.background.successSurface,
        iconContent: colors.text.successDefault,
        chevronContent: colors.icons.neutralAlternative,
      ),
    };
  }
}
