import 'package:flutter/material.dart';

enum BebeIconButtonVariant { standard, subtle, filled }

class BebeIconButton extends StatelessWidget {
  const BebeIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.variant = BebeIconButtonVariant.standard,
    this.isSelected = false,
    this.tooltip,
    super.key,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final BebeIconButtonVariant variant;
  final bool isSelected;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final background = switch (variant) {
      BebeIconButtonVariant.standard => Colors.transparent,
      BebeIconButtonVariant.subtle => colors.primaryContainer,
      BebeIconButtonVariant.filled => colors.primary,
    };

    final foreground = switch (variant) {
      BebeIconButtonVariant.filled => colors.onPrimary,
      _ => isSelected ? colors.primary : colors.onSurfaceVariant,
    };

    final button = Semantics(
      button: true,
      selected: isSelected,
      enabled: onPressed != null,
      label: semanticLabel,
      child: IconButton(
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledForegroundColor: colors.onSurface.withValues(alpha: .38),
          shape: const CircleBorder(),
        ),
        icon: icon,
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
