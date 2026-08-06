import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeStatePanelVariant { success, empty, error, offline, information }

/// Reusable result/empty/offline composition extracted from the mockups.
class BebeStatePanel extends StatelessWidget {
  const BebeStatePanel({
    required this.title,
    required this.description,
    this.variant = BebeStatePanelVariant.information,
    this.illustration,
    this.status,
    this.details,
    this.primaryActionLabel,
    this.onPrimaryActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryActionPressed,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String description;
  final BebeStatePanelVariant variant;
  final Widget? illustration;
  final Widget? status;
  final Widget? details;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryActionPressed;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionPressed;
  final String? semanticLabel;

  static const double _maximumWidth = 560;
  static const double _horizontalActionsBreakpoint = 420;
  static const double _maximumHorizontalTextScale = 1.3;
  static const double _fallbackIconContainerSize = 112;
  static const double _fallbackIconSize = 52;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final palette = _StatePanelPalette.resolve(colors, variant);
    final primaryLabel = _normalize(primaryActionLabel);
    final secondaryLabel = _normalize(secondaryActionLabel);

    final visual = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maximumWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            child:
                illustration ??
                SizedBox.square(
                  dimension: _fallbackIconContainerSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.iconSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      palette.icon,
                      size: _fallbackIconSize,
                      color: palette.iconContent,
                    ),
                  ),
                ),
          ),
          SizedBox(height: spacing.spacing2xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.typography.styles.title.lg.bold.copyWith(
              color: palette.title,
            ),
          ),
          SizedBox(height: spacing.spacingM),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.typography.styles.body.md.regular.copyWith(
              color: colors.text.neutralBody,
            ),
          ),
          if (status != null) ...[
            SizedBox(height: spacing.spacingL),
            Align(child: status!),
          ],
          if (details != null) ...[
            SizedBox(height: spacing.spacing2xl),
            details!,
          ],
          if (primaryLabel != null || secondaryLabel != null) ...[
            SizedBox(height: spacing.spacing2xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = MediaQuery.textScalerOf(context).scale(1);
                final horizontal =
                    constraints.maxWidth >= _horizontalActionsBreakpoint &&
                    scale <= _maximumHorizontalTextScale &&
                    primaryLabel != null &&
                    secondaryLabel != null;

                if (horizontal) {
                  return Row(
                    children: [
                      Expanded(
                        child: BebeButton(
                          label: secondaryLabel,
                          onPressed: onSecondaryActionPressed,
                          variant: BebeButtonVariant.secondary,
                        ),
                      ),
                      SizedBox(width: spacing.spacingM),
                      Expanded(
                        child: BebeButton(
                          label: primaryLabel,
                          onPressed: onPrimaryActionPressed,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (primaryLabel != null)
                      BebeButton(
                        label: primaryLabel,
                        onPressed: onPrimaryActionPressed,
                      ),
                    if (primaryLabel != null && secondaryLabel != null)
                      SizedBox(height: spacing.spacingM),
                    if (secondaryLabel != null)
                      BebeButton(
                        label: secondaryLabel,
                        onPressed: onSecondaryActionPressed,
                        variant: BebeButtonVariant.secondary,
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      liveRegion:
          variant == BebeStatePanelVariant.success ||
          variant == BebeStatePanelVariant.error,
      label: semanticLabel ?? '$title. $description',
      child: Center(child: visual),
    );
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

class _StatePanelPalette {
  const _StatePanelPalette({
    required this.iconSurface,
    required this.iconContent,
    required this.title,
    required this.icon,
  });

  final Color iconSurface;
  final Color iconContent;
  final Color title;
  final IconData icon;

  static _StatePanelPalette resolve(
    BebeColor colors,
    BebeStatePanelVariant variant,
  ) {
    return switch (variant) {
      BebeStatePanelVariant.success => _StatePanelPalette(
        iconSurface: colors.background.successSurface,
        iconContent: colors.icons.successDefault,
        title: colors.text.brandDefault,
        icon: Icons.check_rounded,
      ),
      BebeStatePanelVariant.empty => _StatePanelPalette(
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
        title: colors.text.neutralTitle,
        icon: Icons.inbox_outlined,
      ),
      BebeStatePanelVariant.error => _StatePanelPalette(
        iconSurface: colors.background.errorSurface,
        iconContent: colors.icons.errorDefault,
        title: colors.text.errorDefault,
        icon: Icons.error_outline_rounded,
      ),
      BebeStatePanelVariant.offline => _StatePanelPalette(
        iconSurface: colors.background.warningSurface,
        iconContent: colors.icons.warningDefault,
        title: colors.text.warningDefault,
        icon: Icons.cloud_off_outlined,
      ),
      BebeStatePanelVariant.information => _StatePanelPalette(
        iconSurface: colors.background.infoSurface,
        iconContent: colors.icons.infoDefault,
        title: colors.text.brandDefault,
        icon: Icons.info_outline_rounded,
      ),
    };
  }
}
