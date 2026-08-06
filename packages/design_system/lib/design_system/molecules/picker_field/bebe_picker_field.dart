import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Visual kinds available to [BebePickerField].
enum BebePickerFieldKind { date, time, duration, selection }

/// A controlled field that requests a date, time, duration or list selection.
///
/// It never opens a picker itself; [onPressed] delegates that behavior to the
/// consuming feature.
class BebePickerField extends StatelessWidget {
  const BebePickerField({
    required this.label,
    required this.value,
    required this.kind,
    required this.onPressed,
    this.optional = false,
    this.placeholder,
    this.errorText,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final String value;
  final BebePickerFieldKind kind;
  final VoidCallback? onPressed;
  final bool optional;
  final String? placeholder;
  final String? errorText;
  final bool enabled;
  final String? semanticLabel;

  IconData get _leadingIcon => switch (kind) {
    BebePickerFieldKind.date => Icons.calendar_today_outlined,
    BebePickerFieldKind.time ||
    BebePickerFieldKind.duration => Icons.schedule_outlined,
    BebePickerFieldKind.selection => Icons.tune_rounded,
  };

  bool get _showsChevron => switch (kind) {
    BebePickerFieldKind.duration || BebePickerFieldKind.selection => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final displayValue = value.trim().isEmpty
        ? placeholder ?? 'Seleccionar'
        : value;
    final interactive = enabled && onPressed != null;

    final field = Semantics(
      button: true,
      enabled: interactive,
      label: semanticLabel ?? label,
      value: displayValue,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: BebeButtonSize.medium.height,
        ),
        child: Material(
          color: enabled
              ? colors.background.neutralsSurface
              : colors.background.neutralsDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: theme.borderRadius.l,
            side: BorderSide(
              color: errorText == null
                  ? colors.border.neutralDefault
                  : colors.border.errorDefault,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: interactive ? onPressed : null,
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.spacingXl,
                vertical: spacing.spacingL,
              ),
              child: Row(
                children: [
                  Icon(
                    _leadingIcon,
                    size: BebeIconSize.sm.value,
                    color: enabled
                        ? colors.icons.neutralAlternative
                        : colors.icons.neutralDisabled,
                  ),
                  SizedBox(width: spacing.spacingL),
                  Expanded(
                    child: Text(
                      displayValue,
                      maxLines: 2,
                      style: theme.typography.styles.body.md.regular.copyWith(
                        color: value.trim().isEmpty
                            ? colors.text.neutralDisabled
                            : colors.text.neutralBody,
                      ),
                    ),
                  ),
                  if (_showsChevron) ...[
                    SizedBox(width: spacing.spacingM),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: BebeIconSize.sm.value,
                      color: colors.icons.neutralAlternative,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return BebeFormField(
      label: label,
      optional: optional,
      errorText: errorText,
      child: field,
    );
  }
}
