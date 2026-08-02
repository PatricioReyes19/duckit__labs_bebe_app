import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeDetailActionCardPalette {
  const BebeDetailActionCardPalette({
    required this.surface,
    required this.border,
    required this.iconSurface,
    required this.iconContent,
    required this.title,
    required this.body,
    required this.metadata,
    required this.chevron,
  });

  final Color surface;
  final Color border;
  final Color iconSurface;
  final Color iconContent;
  final Color title;
  final Color body;
  final Color metadata;
  final Color chevron;

  static BebeDetailActionCardPalette resolve({
    required BebeColor colors,
    required BebeDetailActionCardVariant variant,
  }) {
    return switch (variant) {
      BebeDetailActionCardVariant.neutral => BebeDetailActionCardPalette(
        surface: colors.background.neutralsSurface,
        border: colors.border.neutralDefault,
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
        title: colors.text.neutralTitle,
        body: colors.text.neutralBody,
        metadata: colors.text.neutralBody,
        chevron: colors.icons.neutralAlternative,
      ),

      BebeDetailActionCardVariant.brand => BebeDetailActionCardPalette(
        surface: colors.background.brandSurface,
        border: colors.border.brandAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.brandDefault,
        title: colors.text.brandDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.brandDefault,
        chevron: colors.text.brandDefault,
      ),

      BebeDetailActionCardVariant.accent => BebeDetailActionCardPalette(
        surface: colors.background.accentSurface,
        border: colors.border.accentAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.icons.accentDefault,
        title: colors.text.accentDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.accentDefault,
        chevron: colors.icons.accentDefault,
      ),

      BebeDetailActionCardVariant.information => BebeDetailActionCardPalette(
        surface: colors.background.infoSurface,
        border: colors.border.infoDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.infoDefault,
        title: colors.text.infoDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.infoDefault,
        chevron: colors.text.infoDefault,
      ),

      BebeDetailActionCardVariant.warning => BebeDetailActionCardPalette(
        surface: colors.background.warningSurface,
        border: colors.border.warningDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.warningDefault,
        title: colors.text.warningDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.warningDefault,
        chevron: colors.text.warningDefault,
      ),

      BebeDetailActionCardVariant.success => BebeDetailActionCardPalette(
        surface: colors.background.successSurface,
        border: colors.border.successDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.successDefault,
        title: colors.text.successDefault,
        body: colors.text.neutralBody,
        metadata: colors.text.successDefault,
        chevron: colors.text.successDefault,
      ),
    };
  }
}
