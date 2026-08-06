import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeDetailSummaryItem {
  const BebeDetailSummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    this.supportingText,
    this.semanticLabel,
  });

  final Widget icon;
  final String label;
  final String value;
  final String? supportingText;
  final String? semanticLabel;
}

class BebeDetailSummaryCard extends StatelessWidget {
  const BebeDetailSummaryCard({
    required this.items,
    this.semanticLabel = 'Información de la consulta',
    super.key,
  }) : assert(
         items.length > 0,
         'BebeDetailSummaryCard requires at least one item.',
       );

  final List<BebeDetailSummaryItem> items;
  final String semanticLabel;

  static const double _leadingContainerSize = 40;
  static const double _leadingIconSize = 20;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = theme.borderRadius;
    final colors = theme.colors;
    final elevation = theme.elevation;

    final card = Material(
      color: colors.background.neutralsSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: BorderSide(color: colors.border.accentAlternative),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _BebeDetailSummaryRow(item: items[index]),
            if (index != items.length - 1) _BebeDetailSummaryDivider(),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.radius3xl),
            boxShadow: elevation.low,
          ),
          child: card,
        ),
      ),
    );
  }
}

class _BebeDetailSummaryRow extends StatelessWidget {
  const _BebeDetailSummaryRow({required this.item});

  final BebeDetailSummaryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;
    final radius = theme.borderRadius;

    final effectiveSupportingText = item.supportingText?.trim();

    return Semantics(
      label:
          item.semanticLabel ??
          [
            item.label,
            item.value,
            if (effectiveSupportingText != null &&
                effectiveSupportingText.isNotEmpty)
              effectiveSupportingText,
          ].join('. '),
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.spacingL,
            vertical: spacing.spacingM,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: BebeDetailSummaryCard._leadingContainerSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.background.neutralsSurface,
                    borderRadius: BorderRadius.circular(radius.radius3xl),
                    border: Border.all(color: colors.border.accentAlternative),
                  ),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        size: BebeDetailSummaryCard._leadingIconSize,
                        color: colors.icons.neutralAlternative,
                      ),
                      child: item.icon,
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing.spacingL),
              Expanded(
                child: Text(
                  item.label,
                  style: typography.styles.body.md.regular.copyWith(
                    color: colors.text.neutralBody,
                  ),
                ),
              ),
              SizedBox(width: spacing.spacingM),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.value,
                      textAlign: TextAlign.end,
                      style: typography.styles.label.md.semibold.copyWith(
                        color: colors.text.neutralTitle,
                      ),
                    ),
                    if (effectiveSupportingText != null &&
                        effectiveSupportingText.isNotEmpty) ...[
                      SizedBox(height: spacing.spacingXs),
                      Text(
                        effectiveSupportingText,
                        textAlign: TextAlign.end,
                        style: typography.styles.body.sm.regular.copyWith(
                          color: colors.text.neutralBody,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BebeDetailSummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.spacingL),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colors.border.accentAlternative,
      ),
    );
  }
}
