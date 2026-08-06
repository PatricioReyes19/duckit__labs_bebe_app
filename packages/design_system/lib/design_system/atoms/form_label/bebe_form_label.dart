import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Accessible label for fields and groups of form controls.
class BebeFormLabel extends StatelessWidget {
  const BebeFormLabel({
    required this.label,
    this.optional = false,
    this.optionalLabel = 'opcional',
    this.semanticLabel,
    super.key,
  });

  final String label;
  final bool optional;
  final String optionalLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final labelStyle = theme.typography.styles.label.lg.semibold.copyWith(
      color: theme.colors.text.neutralTitle,
    );
    final optionalStyle = theme.typography.styles.body.sm.regular.copyWith(
      color: theme.colors.text.neutralCaption,
    );

    return Semantics(
      label: semanticLabel ?? '$label${optional ? ', $optionalLabel' : ''}',
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: label, style: labelStyle),
              if (optional)
                TextSpan(text: ' ($optionalLabel)', style: optionalStyle),
            ],
          ),
        ),
      ),
    );
  }
}
