import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeFilterChipPalette {
  const BebeFilterChipPalette({
    required this.surface,
    required this.selectedSurface,
    required this.content,
    required this.selectedContent,
    required this.border,
  });

  final Color surface;
  final Color selectedSurface;
  final Color content;
  final Color selectedContent;
  final Color border;

  static BebeFilterChipPalette resolve({
    required BebeColor colors,
    required BebeFilterChipVariant variant,
  }) {
    return switch (variant) {
      BebeFilterChipVariant.neutral => BebeFilterChipPalette(
        surface: colors.background.neutralsSurface,
        selectedSurface: colors.background.neutralsActive,
        content: colors.text.neutralBody,
        selectedContent: colors.text.neutralTitle,
        border: colors.border.accentAlternative,
      ),
      BebeFilterChipVariant.brand => BebeFilterChipPalette(
        surface: colors.background.brandSurface,
        selectedSurface: colors.background.brandDefault,
        content: colors.text.brandDefault,
        selectedContent: colors.background.neutralsSurface,
        border: colors.border.brandAlternative,
      ),
      BebeFilterChipVariant.accent => BebeFilterChipPalette(
        surface: colors.background.accentSurface,
        selectedSurface: colors.background.accentDefault,
        content: colors.text.accentDefault,
        selectedContent: colors.background.neutralsSurface,
        border: colors.border.accentAlternative,
      ),
      BebeFilterChipVariant.information => BebeFilterChipPalette(
        surface: colors.background.infoSurface,
        selectedSurface: colors.background.infoDefault,
        content: colors.text.infoDefault,
        selectedContent: colors.background.neutralsSurface,
        border: colors.border.infoDefault,
      ),
      BebeFilterChipVariant.success => BebeFilterChipPalette(
        surface: colors.background.successSurface,
        selectedSurface: colors.background.successDefault,
        content: colors.text.successDefault,
        selectedContent: colors.background.neutralsSurface,
        border: colors.border.successDefault,
      ),
      BebeFilterChipVariant.warning => BebeFilterChipPalette(
        surface: colors.background.warningSurface,
        selectedSurface: colors.background.warningDefault,
        content: colors.text.warningDefault,
        selectedContent: colors.background.neutralsSurface,
        border: colors.border.warningDefault,
      ),
    };
  }
}
