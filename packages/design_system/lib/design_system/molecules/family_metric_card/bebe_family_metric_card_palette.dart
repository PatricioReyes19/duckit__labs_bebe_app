import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeFamilyMetricCardPalette {
  const BebeFamilyMetricCardPalette({
    required this.surface,
    required this.border,
    required this.iconSurface,
    required this.iconContent,
    required this.value,
    required this.label,
    required this.chevron,
  });

  final Color surface;
  final Color border;
  final Color iconSurface;
  final Color iconContent;
  final Color value;
  final Color label;
  final Color chevron;

  static BebeFamilyMetricCardPalette resolve({
    required BebeColor colors,
    required BebeFamilyMetricCardVariant variant,
  }) {
    return switch (variant) {
      BebeFamilyMetricCardVariant.neutral => BebeFamilyMetricCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.neutralDefault,
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
        value: colors.text.neutralTitle,
        label: colors.text.neutralBody,
        chevron: colors.icons.neutralAlternative,
      ),
      BebeFamilyMetricCardVariant.brand => BebeFamilyMetricCardPalette(
        surface: colors.background.brandSurface,
        border: colors.border.brandAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.brandDefault,
        value: colors.text.brandDefault,
        label: colors.text.neutralBody,
        chevron: colors.text.brandDefault,
      ),
      BebeFamilyMetricCardVariant.accent => BebeFamilyMetricCardPalette(
        surface: colors.background.accentSurface,
        border: colors.border.accentAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.icons.accentDefault,
        value: colors.text.accentDefault,
        label: colors.text.neutralBody,
        chevron: colors.icons.accentDefault,
      ),
      BebeFamilyMetricCardVariant.information => BebeFamilyMetricCardPalette(
        surface: colors.background.infoSurface,
        border: colors.border.infoDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.infoDefault,
        value: colors.text.infoDefault,
        label: colors.text.neutralBody,
        chevron: colors.text.infoDefault,
      ),
      BebeFamilyMetricCardVariant.warning => BebeFamilyMetricCardPalette(
        surface: colors.background.warningSurface,
        border: colors.border.warningDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.warningDefault,
        value: colors.text.warningDefault,
        label: colors.text.warningDefault,
        chevron: colors.text.warningDefault,
      ),
      BebeFamilyMetricCardVariant.success => BebeFamilyMetricCardPalette(
        surface: colors.background.successSurface,
        border: colors.border.successDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.successDefault,
        value: colors.text.successDefault,
        label: colors.text.neutralBody,
        chevron: colors.text.successDefault,
      ),
    };
  }
}
