import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class MetricCardValue extends StatelessWidget {
  const MetricCardValue({super.key, required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          maxLines: 1,
          style: typography.styles.headline.md.bold.copyWith(
            color: colors.text.neutralHeadline,
          ),
        ),
        SizedBox(width: spacing.spacingS),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: spacing.spacingXs),
            child: Text(
              unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.styles.body.sm.regular.copyWith(
                color: colors.text.neutralTitle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
