import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Visual data for one item in [BebeRegisterCategorySelector].
class BebeRegisterCategoryItem<T> {
  const BebeRegisterCategoryItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.variant,
    this.semanticLabel,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget icon;
  final BebeCategoryActionTileVariant variant;
  final String? semanticLabel;
  final bool enabled;
}

/// Horizontal, controlled selector for register event categories.
class BebeRegisterCategorySelector<T> extends StatelessWidget {
  const BebeRegisterCategorySelector({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.semanticLabel = 'Categoría del registro',
    this.contentPadding = EdgeInsets.zero,
    super.key,
  });

  final List<BebeRegisterCategoryItem<T>> items;
  final T selectedValue;
  final ValueChanged<T>? onChanged;
  final String semanticLabel;

  /// Insets that scroll together with the categories instead of reducing the
  /// horizontal viewport.
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    assert(
      items.isNotEmpty,
      'BebeRegisterCategorySelector requires at least one item.',
    );
    assert(
      items.any((item) => item.value == selectedValue),
      'selectedValue must match one of the provided items.',
    );

    final spacing = context.theme.spacing;
    final gap = spacing.spacingM;
    const minimumFittedTileWidth = 48.0;
    const scrolledTileWidth = 96.0;

    return Semantics(
      container: true,
      label: semanticLabel,
      explicitChildNodes: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedPadding = contentPadding.resolve(
            Directionality.of(context),
          );
          final availableWidth =
              constraints.maxWidth -
              resolvedPadding.left -
              resolvedPadding.right;
          final totalGap = gap * (items.length - 1);
          final fittedWidth = (availableWidth - totalGap) / items.length;
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final fits =
              fittedWidth >= minimumFittedTileWidth && textScale <= 1.3;
          final tileWidth = fits ? fittedWidth : scrolledTileWidth;

          final row = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < items.length; index++) ...[
                SizedBox(
                  width: tileWidth,
                  child: BebeCategoryActionTile(
                    variant: items[index].variant,
                    label: items[index].label,
                    icon: items[index].icon,
                    compact: true,
                    isSelected: items[index].value == selectedValue,
                    enabled: items[index].enabled,
                    semanticLabel: items[index].semanticLabel,
                    onPressed: onChanged == null || !items[index].enabled
                        ? null
                        : () => onChanged!(items[index].value),
                  ),
                ),
                if (index < items.length - 1) SizedBox(width: gap),
              ],
            ],
          );

          if (fits) {
            return Padding(padding: contentPadding, child: row);
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: contentPadding,
            child: row,
          );
        },
      ),
    );
  }
}
