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
      surface: colors.clinical.feedingSurface,
      iconSurface: colors.clinical.feedingAccent.withValues(
        alpha: context.theme.overlays.interactionSelected.a,
      ),
      content: colors.clinical.feedingContent,
      border: colors.clinical.feedingAccent,
    ),
    BebeCategoryActionTileVariant.sleep => BebeCategoryPalette(
      surface: colors.clinical.sleepSurface,
      iconSurface: colors.clinical.sleepAccent.withValues(
        alpha: context.theme.overlays.interactionSelected.a,
      ),
      content: colors.clinical.sleepContent,
      border: colors.clinical.sleepAccent,
    ),
    BebeCategoryActionTileVariant.diaper => BebeCategoryPalette(
      surface: colors.clinical.diaperSurface,
      iconSurface: colors.clinical.diaperAccent.withValues(
        alpha: context.theme.overlays.interactionSelected.a,
      ),
      content: colors.clinical.diaperContent,
      border: colors.clinical.diaperAccent,
    ),
    BebeCategoryActionTileVariant.observation => BebeCategoryPalette(
      surface: colors.clinical.observationSurface,
      iconSurface: colors.clinical.observationAccent.withValues(
        alpha: context.theme.overlays.interactionSelected.a,
      ),
      content: colors.clinical.observationContent,
      border: colors.clinical.observationAccent,
    ),
    BebeCategoryActionTileVariant.medication => BebeCategoryPalette(
      surface: colors.clinical.medicationSurface,
      iconSurface: colors.clinical.medicationAccent.withValues(
        alpha: context.theme.overlays.interactionSelected.a,
      ),
      content: colors.clinical.medicationContent,
      border: colors.clinical.medicationAccent,
    ),
    BebeCategoryActionTileVariant.measurement => BebeCategoryPalette(
      surface: colors.clinical.measurementSurface,
      iconSurface: colors.clinical.measurementAccent.withValues(
        alpha: context.theme.overlays.interactionSelected.a,
      ),
      content: colors.clinical.measurementContent,
      border: colors.clinical.measurementAccent,
    ),
  };
}
