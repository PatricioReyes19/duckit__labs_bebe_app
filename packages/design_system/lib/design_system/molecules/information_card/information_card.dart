import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeInformationContent extends StatelessWidget {
  const BebeInformationContent({
    required this.title,
    this.description,
    this.metadata,
    this.maxTitleLines = 2,
    this.maxDescriptionLines = 3,
    super.key,
  });

  final String title;
  final String? description;
  final Widget? metadata;
  final int maxTitleLines;
  final int maxDescriptionLines;

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
