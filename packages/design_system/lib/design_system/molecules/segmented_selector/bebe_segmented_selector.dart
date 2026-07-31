import 'package:flutter/material.dart';

class BebeSegmentedItem<T> {
  const BebeSegmentedItem({
    required this.value,
    required this.label,
    this.icon,
    this.semanticLabel,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? icon;
  final String? semanticLabel;
  final bool enabled;
}

class BebeSegmentedSelector<T> extends StatelessWidget {
  const BebeSegmentedSelector({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.allowWrap = false,
    this.semanticLabel,
    super.key,
  });

  final List<BebeSegmentedItem<T>> items;
  final T selectedValue;
  final ValueChanged<T>? onChanged;
  final bool allowWrap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(
      items.isNotEmpty,
      'BebeSegmentedSelector requires at least one item.',
    );

    final segments = items
        .map((item) {
          return ButtonSegment<T>(
            value: item.value,
            enabled: item.enabled,
            icon: item.icon,
            label: Text(
              item.label,
              maxLines: allowWrap ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          );
        })
        .toList(growable: false);

    return Semantics(
      label: semanticLabel,
      child: SegmentedButton<T>(
        segments: segments,
        selected: <T>{selectedValue},
        onSelectionChanged: onChanged == null
            ? null
            : (selection) {
                if (selection.isNotEmpty) {
                  onChanged!(selection.first);
                }
              },
        showSelectedIcon: false,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 48)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
