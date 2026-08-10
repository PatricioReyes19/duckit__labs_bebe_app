import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeRatingSelector extends StatelessWidget {
  const BebeRatingSelector({
    required this.value,
    this.onChanged,
    this.maximumRating = 5,
    this.label,
    this.valueLabel,
    this.semanticLabel = 'Calificación',
    super.key,
  }) : assert(maximumRating > 0),
       assert(value >= 0),
       assert(value <= maximumRating);

  final int value;
  final ValueChanged<int>? onChanged;
  final int maximumRating;
  final String? label;
  final String? valueLabel;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final normalizedLabel = _normalize(label);
    final normalizedValueLabel = _normalize(valueLabel);

    return Semantics(
      container: true,
      label: '$semanticLabel. $value de $maximumRating estrellas',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (normalizedLabel != null) ...[
            Text(
              normalizedLabel,
              textAlign: TextAlign.center,
              style: theme.typography.styles.title.sm.semibold.copyWith(
                color: theme.colors.text.neutralTitle,
              ),
            ),
            SizedBox(height: spacing.spacingM),
          ],
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (var index = 1; index <= maximumRating; index++)
                BebeRatingStar(
                  selected: index <= value,
                  semanticLabel: '$index de $maximumRating estrellas',
                  onPressed: onChanged == null ? null : () => onChanged!(index),
                ),
            ],
          ),
          if (normalizedValueLabel != null) ...[
            SizedBox(height: spacing.spacingS),
            Text(
              normalizedValueLabel,
              textAlign: TextAlign.center,
              style: theme.typography.styles.label.md.semibold.copyWith(
                color: theme.colors.text.brandDefault,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
