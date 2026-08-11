import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// A visual option displayed by [BebeSegmentedSelector].
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

/// A controlled, single-selection segmented control.
///
/// The selected value is owned by the consuming feature. This component only
/// renders selection and forwards changes.
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
    assert(
      items.any((item) => item.value == selectedValue),
      'selectedValue must match one of the provided items.',
    );

    final theme = context.theme;
    final colors = theme.colors;
    final spacing = theme.spacing;

    final segments = items
        .map((item) {
          final selected = item.value == selectedValue;
          return ButtonSegment<T>(
            value: item.value,
            enabled: item.enabled,
            icon: item.icon,
            label: Semantics(
              label: item.semanticLabel ?? item.label,
              selected: selected,
              child: Text(
                item.label,
                maxLines: allowWrap ? 2 : 1,
                softWrap: allowWrap,
                overflow: allowWrap
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.typography.styles.label.md.regular,
              ),
            ),
          );
        })
        .toList(growable: false);

    return Semantics(
      container: true,
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
        expandedInsets: EdgeInsets.zero,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(48, BebeButtonSize.medium.height),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: spacing.spacingM,
              vertical: spacing.spacingM,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.background.brandSurface;
            }
            if (states.contains(WidgetState.disabled)) {
              return colors.background.neutralsDisabled;
            }
            return colors.background.neutralsSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.text.brandDefault;
            }
            if (states.contains(WidgetState.disabled)) {
              return colors.text.neutralDisabled;
            }
            return colors.text.neutralBody;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? colors.border.brandDefault
                : colors.border.neutralDefault;
            return BorderSide(color: color);
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: theme.borderRadius.l),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return theme.overlays.interactionFocus;
            }
            if (states.contains(WidgetState.hovered)) {
              return theme.overlays.interactionHover;
            }
            if (states.contains(WidgetState.pressed)) {
              return theme.overlays.interactionPressed;
            }
            return null;
          }),
        ),
      ),
    );
  }
}
