import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BebéApp's base text input.
///
/// Labels, helper text and errors are visual inputs. Validation remains in the
/// consuming feature.
class BebeTextField extends StatelessWidget {
  const BebeTextField({
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.leading,
    this.trailing,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.dense = false,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? leading;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int maxLines;
  final int? maxLength;
  final bool dense;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: radius.l,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Semantics(
      textField: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        minLines: obscureText ? 1 : minLines,
        maxLines: obscureText ? 1 : maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        style: theme.typography.styles.body.md.regular.copyWith(
          color: colors.text.neutralBody,
        ),
        decoration: InputDecoration(
          isDense: dense,
          labelText: label,
          labelStyle: theme.typography.styles.label.md.regular.copyWith(
            color: colors.text.neutralLabel,
          ),
          hintText: hintText,
          hintStyle: theme.typography.styles.body.md.regular.copyWith(
            color: colors.text.neutralDisabled,
          ),
          helperText: helperText,
          helperStyle: theme.typography.styles.body.sm.regular.copyWith(
            color: colors.text.neutralCaption,
          ),
          errorText: errorText,
          errorStyle: theme.typography.styles.body.sm.regular.copyWith(
            color: colors.text.errorDefault,
          ),
          prefixIcon: leading,
          suffixIcon: trailing,
          filled: true,
          fillColor: enabled
              ? colors.background.neutralsSurface
              : colors.background.neutralsDisabled,
          border: border(colors.border.neutralDefault),
          enabledBorder: border(colors.border.neutralDefault),
          disabledBorder: border(colors.border.neutralDisabled),
          focusedBorder: border(colors.border.brandFocus, width: 2),
          errorBorder: border(colors.border.errorDefault),
          focusedErrorBorder: border(colors.border.errorDefault, width: 2),
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.spacingXl,
            vertical: dense ? spacing.spacingM : spacing.spacingL,
          ),
          counterStyle: theme.typography.styles.body.sm.regular.copyWith(
            color: colors.text.neutralCaption,
          ),
        ),
      ),
    );
  }
}
