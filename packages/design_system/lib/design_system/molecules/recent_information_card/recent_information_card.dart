import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'recent_information_card_palette.dart';

class BebeRecentInformationCard extends StatelessWidget {
  const BebeRecentInformationCard({
    required this.title,
    required this.dateLabel,
    required this.description,
    required this.icon,
    this.variant = BebeRecentInformationCardVariant.information,
    this.status,
    this.onPressed,
    this.semanticLabel,
    this.maxTitleLines = 2,
    this.maxDescriptionLines = 3,
    super.key,
  });

  final String title;
  final String dateLabel;
  final String description;
  final Widget icon;

  final BebeRecentInformationCardVariant variant;

  final Widget? status;

  final VoidCallback? onPressed;
  final String? semanticLabel;
  final int maxTitleLines;
  final int maxDescriptionLines;

  static const double _compactBreakpoint = 520;

  @override
  Widget build(BuildContext context) {
    assert(maxTitleLines > 0, 'maxTitleLines must be greater than zero.');
    assert(
      maxDescriptionLines > 0,
      'maxDescriptionLines must be greater than zero.',
    );

    final theme = context.theme;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;

    final palette = BebeRecentInformationCardPalette.resolve(
      colors: colors,
      variant: variant,
    );

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: onPressed != null,
      label: semanticLabel ?? '$title. $dateLabel. $description.',
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius.x3l,
            side: BorderSide(color: palette.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
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
                  final isCompact = constraints.maxWidth < _compactBreakpoint;

                  return isCompact
                      ? _CompactRecentInformationCardContent(
                          title: title,
                          dateLabel: dateLabel,
                          description: description,
                          icon: icon,
                          status: status,
                          palette: palette,
                          showChevron: onPressed != null,
                          maxTitleLines: maxTitleLines,
                          maxDescriptionLines: maxDescriptionLines,
                        )
                      : _WideRecentInformationCardContent(
                          title: title,
                          dateLabel: dateLabel,
                          description: description,
                          icon: icon,
                          status: status,
                          palette: palette,
                          showChevron: onPressed != null,
                          maxTitleLines: maxTitleLines,
                          maxDescriptionLines: maxDescriptionLines,
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactRecentInformationCardContent extends StatelessWidget {
  const _CompactRecentInformationCardContent({
    required this.title,
    required this.dateLabel,
    required this.description,
    required this.icon,
    required this.status,
    required this.palette,
    required this.showChevron,
    required this.maxTitleLines,
    required this.maxDescriptionLines,
  });

  final String title;
  final String dateLabel;
  final String description;
  final Widget icon;
  final Widget? status;
  final BebeRecentInformationCardPalette palette;
  final bool showChevron;
  final int maxTitleLines;
  final int maxDescriptionLines;

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
              maxDescriptionLines: maxDescriptionLines,
              metadata: BebeMetadataItem(
                icon: const Icon(Icons.calendar_today_outlined),
                label: dateLabel,
              ),
              description: description,
              supporting: status == null
                  ? null
                  : Align(alignment: Alignment.centerLeft, child: status!),
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

class _WideRecentInformationCardContent extends StatelessWidget {
  const _WideRecentInformationCardContent({
    required this.title,
    required this.dateLabel,
    required this.description,
    required this.icon,
    required this.status,
    required this.palette,
    required this.showChevron,
    required this.maxTitleLines,
    required this.maxDescriptionLines,
  });

  final String title;
  final String dateLabel;
  final String description;
  final Widget icon;
  final Widget? status;
  final BebeRecentInformationCardPalette palette;
  final bool showChevron;
  final int maxTitleLines;
  final int maxDescriptionLines;

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
              maxDescriptionLines: maxDescriptionLines,
              metadata: BebeMetadataItem(
                icon: const Icon(Icons.calendar_today_outlined),
                label: dateLabel,
              ),
              description: description,
            ),
          ),
          if (status != null) ...[SizedBox(width: spacing.spacingL), status!],
          if (showChevron) ...[
            SizedBox(width: spacing.spacingM),
            BebeCardChevron(variant: palette.chevronVariant),
          ],
        ],
      ),
    );
  }
}
