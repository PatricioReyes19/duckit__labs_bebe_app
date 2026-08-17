import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeQuickActionData {
  const BebeQuickActionData({
    required this.id,
    required this.type,
    required this.label,
    required this.icon,
    this.semanticLabel,
  });

  final String id;
  final BebeQuickActionType type;
  final String label;
  final Widget icon;
  final String? semanticLabel;
}

class BebeQuickRegistrationActions extends StatelessWidget {
  const BebeQuickRegistrationActions({
    required this.items,
    required this.onItemPressed,
    this.title = 'Registrar ahora',
    this.helperLabel = 'Desliza para ver más',
    this.contentPadding = EdgeInsets.zero,
    super.key,
  });

  final List<BebeQuickActionData> items;
  final ValueChanged<String> onItemPressed;
  final String title;
  final String helperLabel;

  /// Insets that scroll with the actions instead of reducing their viewport.
  final EdgeInsetsGeometry contentPadding;

  static const int _maximumVisibleItems = 5;
  static const double _minimumTileWidth = 92;
  static const double _accessibleTileWidth = 112;
  static const double _maximumCompactTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    assert(
      items.isNotEmpty,
      'BebeQuickRegistrationActions requires '
      'at least one item.',
    );

    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: contentPadding,
            child: BebeTitleSection(
              title: title,
              trailing: BebeSectionHint(
                label: helperLabel,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  size: 8,
                  color: colors.icons.neutralAlternative,
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.spacingM),
          LayoutBuilder(
            builder: (context, constraints) {
              final visibleItems = items.length.clamp(1, _maximumVisibleItems);
              final resolvedPadding = contentPadding.resolve(
                Directionality.of(context),
              );
              final availableWidth =
                  constraints.maxWidth -
                  resolvedPadding.left -
                  resolvedPadding.right;

              final gap = spacing.spacingS;

              final totalSpacing = gap * (visibleItems - 1);

              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final minimumTileWidth = textScale > _maximumCompactTextScale
                  ? _accessibleTileWidth
                  : _minimumTileWidth;
              final fluidTileWidth =
                  (availableWidth - totalSpacing) / visibleItems;
              final tileWidth = math.max(minimumTileWidth, fluidTileWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: contentPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      SizedBox(
                        width: tileWidth,
                        child: _QuickRegistrationActionTile(
                          item: items[index],
                          onPressed: onItemPressed,
                        ),
                      ),
                      if (index < items.length - 1) SizedBox(width: gap),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickRegistrationActionTile extends StatelessWidget {
  const _QuickRegistrationActionTile({
    required this.item,
    required this.onPressed,
  });

  final BebeQuickActionData item;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return BebeCategoryActionTile(
      variant: item.type.toTitleVariant(),
      label: item.label,
      icon: item.icon,
      compact: true,
      semanticLabel: item.semanticLabel,
      onPressed: () => onPressed(item.id),
    );
  }
}

/// Loading representation owned by [BebeQuickRegistrationActions].
class BebeQuickRegistrationActionsSkeleton extends StatelessWidget {
  const BebeQuickRegistrationActionsSkeleton({
    this.itemCount = 5,
    this.contentPadding = EdgeInsets.zero,
    super.key,
  });

  final int itemCount;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.spacingM,
      children: [
        Padding(
          padding: contentPadding,
          child: const BebeSkeleton.line(width: 132, height: 18),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: contentPadding,
          child: Row(
            spacing: spacing.spacingS,
            children: List.generate(
              itemCount,
              (_) => const BebeSkeleton(width: 92, height: 72),
            ),
          ),
        ),
      ],
    );
  }
}
