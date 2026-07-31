import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeSelectableDateCellPalette {
  const BebeSelectableDateCellPalette({
    required this.surface,
    required this.selectedSurface,
    required this.label,
    required this.value,
    required this.selectedContent,
    required this.disabledContent,
    required this.border,
  });

  final Color surface;
  final Color selectedSurface;
  final Color label;
  final Color value;
  final Color selectedContent;
  final Color disabledContent;
  final Color border;

  static BebeSelectableDateCellPalette resolve({
    required BebeColor colors,
    required BebeSelectableDateCellVariant variant,
  }) {
    return switch (variant) {
      BebeSelectableDateCellVariant.neutral => BebeSelectableDateCellPalette(
        surface: colors.background.neutralsSurface,
        selectedSurface: colors.background.neutralsActive,
        label: colors.text.neutralBody,
        value: colors.text.neutralTitle,
        selectedContent: colors.text.neutralTitle,
        disabledContent: colors.text.neutralDisabled,
        border: colors.border.accentAlternative,
      ),
      BebeSelectableDateCellVariant.brand => BebeSelectableDateCellPalette(
        surface: colors.background.neutralsSurface,
        selectedSurface: colors.background.brandDefault,
        label: colors.text.neutralBody,
        value: colors.text.neutralTitle,
        selectedContent: colors.background.neutralsSurface,
        disabledContent: colors.text.neutralDisabled,
        border: colors.border.brandAlternative,
      ),
      BebeSelectableDateCellVariant.accent => BebeSelectableDateCellPalette(
        surface: colors.background.neutralsSurface,
        selectedSurface: colors.background.accentDefault,
        label: colors.text.neutralBody,
        value: colors.text.neutralTitle,
        selectedContent: colors.background.neutralsSurface,
        disabledContent: colors.text.neutralDisabled,
        border: colors.border.accentAlternative,
      ),
    };
  }
}
