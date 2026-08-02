import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class MetricCardValue extends StatelessWidget {
  const MetricCardValue({required this.value, this.unit, super.key});

  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    final effectiveUnit = unit?.trim();

    return Wrap(
      spacing: spacing.spacingS,
      runSpacing: spacing.spacingXs,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typography.styles.headline.md.bold.copyWith(
            color: colors.text.neutralHeadline,
          ),
        ),
        if (effectiveUnit != null && effectiveUnit.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.spacingXs),
            child: Text(
              effectiveUnit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.styles.body.sm.regular.copyWith(
                color: colors.text.neutralBody,
              ),
            ),
          ),
      ],
    );
  }
}
