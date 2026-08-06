import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Composes a persistent label, a field control and optional feedback.
class BebeFormField extends StatelessWidget {
  const BebeFormField({
    required this.label,
    required this.child,
    this.optional = false,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final Widget child;
  final bool optional;
  final String? helperText;
  final String? errorText;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final feedback = errorText ?? helperText;

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeFormLabel(label: label, optional: optional),
          SizedBox(height: spacing.spacingM),
          child,
          if (feedback != null && feedback.trim().isNotEmpty) ...[
            SizedBox(height: spacing.spacingS),
            Semantics(
              liveRegion: errorText != null,
              label: feedback,
              child: Text(
                feedback,
                style: theme.typography.styles.body.sm.regular.copyWith(
                  color: errorText == null
                      ? theme.colors.text.neutralCaption
                      : theme.colors.text.errorDefault,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
