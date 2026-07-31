import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'upcomming_health_card_palette.dart';

class BebeUpcomingHealthCard extends StatelessWidget {
  const BebeUpcomingHealthCard({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.icon,
    this.caregiverLabel,
    this.variant = BebeUpcomingHealthCardVariant.brand,
    this.footer,
    this.onPressed,
    this.semanticLabel,
    this.maxTitleLines = 2,
    super.key,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final Widget icon;
  final String? caregiverLabel;

  /// Variante propia de la molécula.
  final BebeUpcomingHealthCardVariant variant;

  /// Slot abierto. Puede recibir BebeUpcomingHealthActions
  /// u otro footer compatible.
  final Widget? footer;

  final VoidCallback? onPressed;
  final String? semanticLabel;
  final int maxTitleLines;

  static const double _compactBreakpoint = 520;

  @override
  Widget build(BuildContext context) {
    assert(maxTitleLines > 0, 'maxTitleLines must be greater than zero.');

    final theme = context.theme;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;

    final palette = BebeUpcomingHealthCardPalette.resolve(
      colors: colors,
      variant: variant,
    );

    final effectiveCaregiver = caregiverLabel?.trim();

    final semanticsParts = <String>[
      title,
      dateLabel,
      timeLabel,
      if (effectiveCaregiver != null && effectiveCaregiver.isNotEmpty)
        effectiveCaregiver,
    ];

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: onPressed != null,
      label: semanticLabel ?? semanticsParts.join('. '),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius.x3l,
            side: BorderSide(color: palette.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onPressed,
                overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return overlays.interactionPressed;
                  }

                  if (states.contains(WidgetState.hovered)) {
                    return overlays.interactionHover;
                  }

                  if (states.contains(WidgetState.focused)) {
                    return overlays.interactionFocus;
                  }

                  return null;
                }),
                child: DecoratedBox(
                  decoration: BoxDecoration(boxShadow: elevation.low),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact =
                          constraints.maxWidth < _compactBreakpoint;

                      return isCompact
                          ? _CompactUpcomingHealthCardContent(
                              title: title,
                              dateLabel: dateLabel,
                              timeLabel: timeLabel,
                              caregiverLabel: effectiveCaregiver,
                              icon: icon,
                              palette: palette,
                              showChevron: onPressed != null,
                              maxTitleLines: maxTitleLines,
                            )
                          : _WideUpcomingHealthCardContent(
                              title: title,
                              dateLabel: dateLabel,
                              timeLabel: timeLabel,
                              caregiverLabel: effectiveCaregiver,
                              icon: icon,
                              palette: palette,
                              showChevron: onPressed != null,
                              maxTitleLines: maxTitleLines,
                            );
                    },
                  ),
                ),
              ),
              if (footer != null) ...[
                Divider(height: 1, thickness: 1, color: palette.divider),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactUpcomingHealthCardContent extends StatelessWidget {
  const _CompactUpcomingHealthCardContent({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.caregiverLabel,
    required this.icon,
    required this.palette,
    required this.showChevron,
    required this.maxTitleLines,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final String? caregiverLabel;
  final Widget icon;
  final BebeUpcomingHealthCardPalette palette;
  final bool showChevron;
  final int maxTitleLines;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.spacingXl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BebeLeadingIcon(
            icon: icon,
            variant: palette.leadingIconVariant,
            size: BebeLeadingIconSize.medium,
          ),
          SizedBox(width: spacing.spacingL),
          Expanded(
            child: BebeInformationContent(
              title: title,
              maxTitleLines: maxTitleLines,
              metadata: Wrap(
                spacing: spacing.spacingM,
                runSpacing: spacing.spacingS,
                children: [
                  BebeMetadataItem(
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: dateLabel,
                  ),
                  BebeMetadataItem(
                    icon: const Icon(Icons.schedule_outlined),
                    label: timeLabel,
                  ),
                ],
              ),
              supporting: caregiverLabel == null || caregiverLabel!.isEmpty
                  ? null
                  : BebeMetadataItem(
                      icon: const Icon(Icons.person_outline),
                      label: caregiverLabel!,
                      variant: BebeMetadataItemVariant.brand,
                    ),
            ),
          ),
          if (showChevron) ...[
            SizedBox(width: spacing.spacingS),
            BebeCardChevron(variant: palette.chevronVariant),
          ],
        ],
      ),
    );
  }
}

class _WideUpcomingHealthCardContent extends StatelessWidget {
  const _WideUpcomingHealthCardContent({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.caregiverLabel,
    required this.icon,
    required this.palette,
    required this.showChevron,
    required this.maxTitleLines,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final String? caregiverLabel;
  final Widget icon;
  final BebeUpcomingHealthCardPalette palette;
  final bool showChevron;
  final int maxTitleLines;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.spacing2xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BebeLeadingIcon(
            icon: icon,
            variant: palette.leadingIconVariant,
            size: BebeLeadingIconSize.medium,
          ),
          SizedBox(width: spacing.spacingXl),
          Expanded(
            child: BebeInformationContent(
              title: title,
              maxTitleLines: maxTitleLines,
              metadata: Wrap(
                spacing: spacing.spacingL,
                runSpacing: spacing.spacingS,
                children: [
                  BebeMetadataItem(
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: dateLabel,
                  ),
                  BebeMetadataItem(
                    icon: const Icon(Icons.schedule_outlined),
                    label: timeLabel,
                  ),
                  if (caregiverLabel != null && caregiverLabel!.isNotEmpty)
                    BebeMetadataItem(
                      icon: const Icon(Icons.person_outline),
                      label: caregiverLabel!,
                      variant: BebeMetadataItemVariant.brand,
                    ),
                ],
              ),
            ),
          ),
          if (showChevron) ...[
            SizedBox(width: spacing.spacingM),
            BebeCardChevron(variant: palette.chevronVariant),
          ],
        ],
      ),
    );
  }
}
