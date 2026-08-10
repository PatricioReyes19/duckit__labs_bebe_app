import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeRegisterActionBar extends StatelessWidget {
  const BebeRegisterActionBar({
    required this.onSavePressed,
    required this.onCancelPressed,
    this.saveLabel = 'Guardar registro',
    this.cancelLabel = 'Cancelar',
    this.isSaving = false,
    this.semanticLabel = 'Acciones del formulario',
    super.key,
  });

  final VoidCallback? onSavePressed;
  final VoidCallback? onCancelPressed;
  final String saveLabel;
  final String cancelLabel;
  final bool isSaving;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Semantics(
      container: true,
      label: semanticLabel,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeButton(
            label: saveLabel,
            onPressed: onSavePressed,
            isLoading: isSaving,
          ),
          SizedBox(height: spacing.spacingM),
          BebeButton(
            label: cancelLabel,
            onPressed: onCancelPressed,
            variant: BebeButtonVariant.text,
            size: BebeButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
