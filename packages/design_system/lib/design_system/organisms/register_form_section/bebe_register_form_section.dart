import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Surface used to group the controls of one register form.
class BebeRegisterFormSection extends StatelessWidget {
  const BebeRegisterFormSection({
    required this.child,
    this.semanticLabel = 'Formulario de registro',
    super.key,
  });

  final Widget child;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background.neutralsSurface,
          borderRadius: theme.borderRadius.x3l,
          border: Border.all(color: theme.colors.border.neutralDefault),
          boxShadow: theme.elevation.low,
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.spacingXl),
          child: child,
        ),
      ),
    );
  }
}
