import 'package:flutter/material.dart';

enum BebeStatusType {
  neutral,
  information,
  success,
  warning,
  error,
  pending,
  offline,
  syncing,
  synced,
}

enum BebeStatusIndicatorSize {
  sm(8),
  md(12),
  lg(16);

  const BebeStatusIndicatorSize(this.value);

  final double value;
}

class BebeStatusIndicator extends StatelessWidget {
  const BebeStatusIndicator({
    required this.type,
    this.size = BebeStatusIndicatorSize.md,
    this.semanticLabel,
    super.key,
  });

  final BebeStatusType type;
  final BebeStatusIndicatorSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final color = switch (type) {
      BebeStatusType.success || BebeStatusType.synced => colors.tertiary,
      BebeStatusType.warning || BebeStatusType.pending => colors.secondary,
      BebeStatusType.error => colors.error,
      BebeStatusType.information || BebeStatusType.syncing => colors.primary,
      BebeStatusType.offline => colors.onSurfaceVariant,
      BebeStatusType.neutral => colors.outline,
    };

    return Semantics(
      label: semanticLabel,
      child: Container(
        width: size.value,
        height: size.value,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
