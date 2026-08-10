import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeSegmentedFormField<T> extends StatelessWidget {
  const BebeSegmentedFormField({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.optional = false,
    this.allowWrap = false,
    this.errorText,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final List<BebeSegmentedItem<T>> items;
  final T selectedValue;
  final ValueChanged<T>? onChanged;
  final bool optional;
  final bool allowWrap;
  final String? errorText;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return BebeFormField(
      label: label,
      optional: optional,
      errorText: errorText,
      child: BebeSegmentedSelector<T>(
        items: items,
        selectedValue: selectedValue,
        onChanged: onChanged,
        allowWrap: allowWrap,
        semanticLabel: semanticLabel ?? label,
      ),
    );
  }
}
