import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeTimeBlock extends StatelessWidget {
  const BebeTimeBlock({
    required this.timeLabel,
    this.dateLabel,
    this.periodLabel,
    this.variant = BebeTimeBlockVariant.neutral,
    this.size = BebeTimeBlockSize.medium,
    this.alignment = BebeTimeBlockAlignment.center,
    this.semanticLabel,
    super.key,
  });

  final String timeLabel;
  final String? dateLabel;
  final String? periodLabel;

  final BebeTimeBlockVariant variant;
  final BebeTimeBlockSize size;
  final BebeTimeBlockAlignment alignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    final effectiveDate = dateLabel?.trim();
    final effectivePeriod = periodLabel?.trim();

    final contentColor = switch (variant) {
      BebeTimeBlockVariant.neutral => colors.text.neutralTitle,
      BebeTimeBlockVariant.brand => colors.text.brandDefault,
      BebeTimeBlockVariant.accent => colors.text.accentDefault,
      BebeTimeBlockVariant.information => colors.text.infoDefault,
      BebeTimeBlockVariant.warning => colors.text.warningDefault,
    };

    final secondaryColor = colors.text.neutralBody;

    final timeStyle = switch (size) {
      BebeTimeBlockSize.small => typography.styles.title.sm.semibold,
      BebeTimeBlockSize.medium => typography.styles.title.md.semibold,
    };

    final secondaryStyle = switch (size) {
      BebeTimeBlockSize.small => typography.styles.label.sm.regular,
      BebeTimeBlockSize.medium => typography.styles.body.sm.regular,
    };

    final crossAxisAlignment = switch (alignment) {
      BebeTimeBlockAlignment.start => CrossAxisAlignment.start,
      BebeTimeBlockAlignment.center => CrossAxisAlignment.center,
      BebeTimeBlockAlignment.end => CrossAxisAlignment.end,
    };

    final textAlign = switch (alignment) {
      BebeTimeBlockAlignment.start => TextAlign.start,
      BebeTimeBlockAlignment.center => TextAlign.center,
      BebeTimeBlockAlignment.end => TextAlign.end,
    };

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (effectiveDate != null && effectiveDate.isNotEmpty) ...[
          Text(
            effectiveDate,
            textAlign: textAlign,
            style: secondaryStyle.copyWith(color: secondaryColor),
          ),
          SizedBox(height: spacing.spacingXs),
        ],
        Text(
          timeLabel,
          textAlign: textAlign,
          style: timeStyle.copyWith(color: contentColor),
        ),
        if (effectivePeriod != null && effectivePeriod.isNotEmpty) ...[
          SizedBox(height: spacing.spacingXs),
          Text(
            effectivePeriod,
            textAlign: textAlign,
            style: secondaryStyle.copyWith(color: secondaryColor),
          ),
        ],
      ],
    );

    final effectiveSemanticLabel =
        semanticLabel ??
        [
          if (effectiveDate != null && effectiveDate.isNotEmpty) effectiveDate,
          timeLabel,
          if (effectivePeriod != null && effectivePeriod.isNotEmpty)
            effectivePeriod,
        ].join(', ');

    return Semantics(
      label: effectiveSemanticLabel,
      child: ExcludeSemantics(child: content),
    );
  }
}
