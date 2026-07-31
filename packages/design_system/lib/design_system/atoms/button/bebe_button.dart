import 'package:flutter/material.dart';

enum BebeButtonVariant { primary, secondary, text, destructive }

enum BebeButtonSize {
  medium(48),
  large(56);

  const BebeButtonSize(this.height);

  final double height;
}

class BebeButton extends StatelessWidget {
  const BebeButton({
    required this.label,
    required this.onPressed,
    this.variant = BebeButtonVariant.primary,
    this.size = BebeButtonSize.large,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.expand = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final BebeButtonVariant variant;
  final BebeButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool expand;
  final String? semanticLabel;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final background = switch (variant) {
      BebeButtonVariant.primary => colors.primary,
      BebeButtonVariant.secondary => colors.surface,
      BebeButtonVariant.text => Colors.transparent,
      BebeButtonVariant.destructive => colors.error,
    };

    final foreground = switch (variant) {
      BebeButtonVariant.primary => colors.onPrimary,
      BebeButtonVariant.secondary => colors.primary,
      BebeButtonVariant.text => colors.primary,
      BebeButtonVariant.destructive => colors.onError,
    };

    final border = switch (variant) {
      BebeButtonVariant.secondary => BorderSide(color: colors.primary),
      _ => BorderSide.none,
    };

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            )
          : Row(
              key: const ValueKey('content'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
    );

    final button = Semantics(
      button: true,
      enabled: _isEnabled,
      label: semanticLabel ?? label,
      child: SizedBox(
        height: size.height,
        child: FilledButton(
          onPressed: _isEnabled ? onPressed : null,
          style: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colors.surfaceContainerHighest;
              }
              return background;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colors.onSurfaceVariant;
              }
              return foreground;
            }),
            side: WidgetStatePropertyAll(border),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          child: content,
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
