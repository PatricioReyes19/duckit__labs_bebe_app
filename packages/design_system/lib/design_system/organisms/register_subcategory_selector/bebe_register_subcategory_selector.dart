import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Prominent segmented selector used below the register category row.
///
/// Unlike a compact form field, this selector gives the domain icon and label
/// equal visual weight and keeps every option visible on common phone widths.
class BebeRegisterSubcategorySelector<T> extends StatelessWidget {
  const BebeRegisterSubcategorySelector({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  }) : assert(items.length > 0);

  final List<BebeSegmentedItem<T>> items;
  final T selectedValue;
  final ValueChanged<T>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(
      items.any((item) => item.value == selectedValue),
      'selectedValue must match one of the provided items.',
    );

    final theme = context.theme;
    final colors = theme.colors;

    return Semantics(
      container: true,
      label: semanticLabel,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background.neutralsSurface,
          borderRadius: theme.borderRadius.xl,
          border: Border.all(color: colors.border.neutralDefault),
          boxShadow: theme.elevation.low,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: _RegisterSubcategorySegment<T>(
                    item: items[index],
                    selected: items[index].value == selectedValue,
                    showDivider: index > 0,
                    borderRadius: _segmentBorderRadius(
                      theme.borderRadius.xl,
                      index: index,
                      itemCount: items.length,
                    ),
                    onPressed: onChanged == null || !items[index].enabled
                        ? null
                        : () => onChanged!(items[index].value),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius _segmentBorderRadius(
    BorderRadius outerRadius, {
    required int index,
    required int itemCount,
  }) {
    final isFirst = index == 0;
    final isLast = index == itemCount - 1;

    return BorderRadius.only(
      topLeft: isFirst ? outerRadius.topLeft : Radius.zero,
      bottomLeft: isFirst ? outerRadius.bottomLeft : Radius.zero,
      topRight: isLast ? outerRadius.topRight : Radius.zero,
      bottomRight: isLast ? outerRadius.bottomRight : Radius.zero,
    );
  }
}

class _RegisterSubcategorySegment<T> extends StatelessWidget {
  const _RegisterSubcategorySegment({
    required this.item,
    required this.selected,
    required this.showDivider,
    required this.borderRadius,
    required this.onPressed,
  });

  final BebeSegmentedItem<T> item;
  final bool selected;
  final bool showDivider;
  final BorderRadius borderRadius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final foreground = selected
        ? colors.text.brandDefault
        : colors.text.neutralBody;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      selected: selected,
      label: item.semanticLabel ?? item.label,
      child: Container(
        decoration: BoxDecoration(
          border: showDivider && !selected
              ? Border(left: BorderSide(color: colors.border.neutralDefault))
              : null,
        ),
        child: Material(
          color: selected ? colors.background.brandSurface : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: selected
                ? BorderSide(color: colors.border.brandDefault, width: 1.5)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.spacingS,
                  vertical: spacing.spacingS + spacing.spacingXs,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) ...[
                      IconTheme(
                        data: IconThemeData(color: foreground, size: 22),
                        child: item.icon!,
                      ),
                      SizedBox(height: spacing.spacingS),
                    ],
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: theme.typography.styles.label.md.regular.copyWith(
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
