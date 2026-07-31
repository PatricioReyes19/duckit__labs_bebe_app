import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeCategoryPalette {
  const BebeCategoryPalette({
    required this.surface,
    required this.iconSurface,
    required this.content,
    required this.border,
  });

  final Color surface;
  final Color iconSurface;
  final Color content;
  final Color border;
}

BebeCategoryPalette resolveCategoryPalette(
  BuildContext context,
  BebeCategoryActionTileVariant type,
) {
  final colors = context.theme.colors;

  return switch (type) {
    BebeCategoryActionTileVariant.feeding => BebeCategoryPalette(
      surface: colors.background.brandSurface,
      iconSurface: colors.background.brandDefault.withAlpha(50),
      content: colors.text.brandDefault,
      border: colors.border.brandDefault,
    ),
    BebeCategoryActionTileVariant.sleep => BebeCategoryPalette(
      surface: colors.background.accentSurface,
      iconSurface: colors.background.accentDefault.withAlpha(50),
      content: colors.text.accentDefault,
      border: colors.border.accentAlternative,
    ),
    BebeCategoryActionTileVariant.diaper => BebeCategoryPalette(
      surface: colors.background.warningSurface,
      iconSurface: colors.background.warningDefault.withAlpha(50),
      content: colors.text.warningDefault,
      border: colors.border.warningDefault,
    ),
    BebeCategoryActionTileVariant.observation => BebeCategoryPalette(
      surface: colors.background.infoSurface,
      iconSurface: colors.background.infoDefault.withAlpha(50),
      content: colors.text.infoDefault,
      border: colors.border.infoDefault,
    ),
    BebeCategoryActionTileVariant.medication => BebeCategoryPalette(
      surface: colors.background.infoSurface,
      iconSurface: colors.background.infoDefault.withAlpha(50),
      content: colors.text.infoDefault,
      border: colors.border.infoDefault,
    ),
    BebeCategoryActionTileVariant.neutral => BebeCategoryPalette(
      surface: colors.background.successSurface,
      iconSurface: colors.background.successDefault.withAlpha(50),
      content: colors.text.successDefault,
      border: colors.border.successDefault,
    ),
  };
}
