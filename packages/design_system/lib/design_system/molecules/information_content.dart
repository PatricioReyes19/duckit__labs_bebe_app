import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeInformationContent extends StatelessWidget {
  const BebeInformationContent({
    required this.title,
    this.description,
    this.metadata,
    this.supporting,
    this.maxTitleLines = 2,
    this.maxDescriptionLines = 3,
    super.key,
  });

  final String title;
  final String? description;

  /// Puede contener uno o más BebeMetadataItem.
  final Widget? metadata;

  /// Contenido adicional inferior, como cuidador,
  /// ubicación u otra información secundaria.
  final Widget? supporting;

  final int maxTitleLines;
  final int maxDescriptionLines;

  @override
  Widget build(BuildContext context) {
    assert(maxTitleLines > 0, 'maxTitleLines must be greater than zero.');

    assert(
      maxDescriptionLines > 0,
      'maxDescriptionLines must be greater than zero.',
    );

    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    final effectiveDescription = description?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: maxTitleLines,
          overflow: TextOverflow.ellipsis,
          style: typography.styles.title.sm.semibold.copyWith(
            color: colors.text.neutralTitle,
          ),
        ),
        if (metadata != null) ...[
          SizedBox(height: spacing.spacingS),
          metadata!,
        ],
        if (effectiveDescription != null &&
            effectiveDescription.isNotEmpty) ...[
          SizedBox(height: spacing.spacingS),
          Text(
            effectiveDescription,
            maxLines: maxDescriptionLines,
            overflow: TextOverflow.ellipsis,
            style: typography.styles.body.sm.regular.copyWith(
              color: colors.text.neutralBody,
            ),
          ),
        ],
        if (supporting != null) ...[
          SizedBox(height: spacing.spacingS),
          supporting!,
        ],
      ],
    );
  }
}
