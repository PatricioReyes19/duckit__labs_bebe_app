import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeInAppSnackbarVariant {
  neutral,
  information,
  syncing,
  success,
  warning,
  error,
  offline,
}

/// Notificación transitoria que vive dentro del [ScaffoldMessenger] de la app.
///
/// La superficie conserva transparencia para que se perciba el contexto de la
/// pantalla y usa los colores semánticos del Design System.
class BebeInAppSnackbar extends StatelessWidget {
  const BebeInAppSnackbar({
    required this.message,
    this.variant = BebeInAppSnackbarVariant.information,
    this.title,
    this.icon,
    this.actionLabel,
    this.onActionPressed,
    this.showCloseIcon = true,
    super.key,
  });

  final String message;
  final String? title;
  final BebeInAppSnackbarVariant variant;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool showCloseIcon;

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    String? title,
    BebeInAppSnackbarVariant variant = BebeInAppSnackbarVariant.information,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration? duration,
    bool clearPrevious = true,
  }) => showOn(
    ScaffoldMessenger.of(context),
    message: message,
    title: title,
    variant: variant,
    icon: icon,
    actionLabel: actionLabel,
    onActionPressed: onActionPressed,
    duration: duration,
    clearPrevious: clearPrevious,
  );

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showOn(
    ScaffoldMessengerState messenger, {
    required String message,
    String? title,
    BebeInAppSnackbarVariant variant = BebeInAppSnackbarVariant.information,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration? duration,
    bool clearPrevious = true,
  }) {
    if (clearPrevious) messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      snackBar(
        message: message,
        title: title,
        variant: variant,
        icon: icon,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        duration: duration,
      ),
    );
  }

  static SnackBar snackBar({
    required String message,
    String? title,
    BebeInAppSnackbarVariant variant = BebeInAppSnackbarVariant.information,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration? duration,
  }) => SnackBar(
    content: BebeInAppSnackbar(
      message: message,
      title: title,
      variant: variant,
      icon: icon,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    behavior: SnackBarBehavior.floating,
    dismissDirection: DismissDirection.horizontal,
    duration:
        duration ??
        (variant == BebeInAppSnackbarVariant.error
            ? const Duration(seconds: 6)
            : const Duration(seconds: 4)),
  );

  @override
  Widget build(BuildContext context) {
    final palette = _SnackbarPalette.resolve(context, variant);
    final normalizedTitle = title?.trim();
    final normalizedAction = actionLabel?.trim();
    final messenger = ScaffoldMessenger.maybeOf(context);

    return Semantics(
      container: true,
      liveRegion: true,
      label: [
        if (normalizedTitle?.isNotEmpty ?? false) normalizedTitle,
        message,
      ].whereType<String>().join('. '),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            key: const Key('bebe-in-app-snackbar-surface'),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: palette.iconSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? palette.icon,
                      key: const Key('bebe-in-app-snackbar-icon'),
                      size: 22,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (normalizedTitle?.isNotEmpty ?? false) ...[
                          Text(
                            normalizedTitle!,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: palette.foreground,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          message,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: palette.foreground),
                        ),
                        if (normalizedAction?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () {
                              messenger?.hideCurrentSnackBar();
                              onActionPressed?.call();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: palette.accent,
                              minimumSize: const Size(44, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              normalizedAction!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showCloseIcon)
                    IconButton(
                      tooltip: 'Cerrar notificación',
                      onPressed: messenger?.hideCurrentSnackBar,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: palette.foreground.withValues(alpha: 0.72),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnackbarPalette {
  const _SnackbarPalette({
    required this.accent,
    required this.foreground,
    required this.surface,
    required this.iconSurface,
    required this.border,
    required this.icon,
  });

  final Color accent;
  final Color foreground;
  final Color surface;
  final Color iconSurface;
  final Color border;
  final IconData icon;

  static _SnackbarPalette resolve(
    BuildContext context,
    BebeInAppSnackbarVariant variant,
  ) {
    final material = Theme.of(context);
    final tokens = material.extension<BebeColor>();
    final (accent, foreground, border, icon) = switch (variant) {
      BebeInAppSnackbarVariant.information => (
        tokens?.background.infoDefault ?? Colors.blue.shade600,
        tokens?.text.infoDefault ?? material.colorScheme.onSurface,
        tokens?.border.infoDefault ?? Colors.blue.shade200,
        Icons.info_outline_rounded,
      ),
      BebeInAppSnackbarVariant.syncing => (
        tokens?.background.infoDefault ?? Colors.blue.shade600,
        tokens?.text.infoDefault ?? material.colorScheme.onSurface,
        tokens?.border.infoDefault ?? Colors.blue.shade200,
        Icons.sync_rounded,
      ),
      BebeInAppSnackbarVariant.success => (
        tokens?.background.successDefault ?? Colors.green.shade600,
        tokens?.text.successDefault ?? material.colorScheme.onSurface,
        tokens?.border.successDefault ?? Colors.green.shade200,
        Icons.check_circle_outline_rounded,
      ),
      BebeInAppSnackbarVariant.warning => (
        tokens?.background.warningDefault ?? Colors.orange.shade600,
        tokens?.text.warningDefault ?? material.colorScheme.onSurface,
        tokens?.border.warningDefault ?? Colors.orange.shade200,
        Icons.warning_amber_rounded,
      ),
      BebeInAppSnackbarVariant.error => (
        tokens?.background.errorDefault ?? Colors.red.shade600,
        tokens?.text.errorDefault ?? material.colorScheme.error,
        tokens?.border.errorDefault ?? Colors.red.shade200,
        Icons.error_outline_rounded,
      ),
      BebeInAppSnackbarVariant.offline => (
        material.colorScheme.onSurfaceVariant,
        material.colorScheme.onSurface,
        material.colorScheme.outlineVariant,
        Icons.cloud_off_outlined,
      ),
      BebeInAppSnackbarVariant.neutral => (
        material.colorScheme.onSurfaceVariant,
        material.colorScheme.onSurface,
        material.colorScheme.outlineVariant,
        Icons.notifications_none_rounded,
      ),
    };
    final baseSurface = material.colorScheme.surface.withValues(alpha: 0.88);
    return _SnackbarPalette(
      accent: accent,
      foreground: foreground,
      surface: Color.alphaBlend(accent.withValues(alpha: 0.15), baseSurface),
      iconSurface: accent.withValues(alpha: 0.14),
      border: Color.alphaBlend(
        accent.withValues(alpha: 0.42),
        border.withValues(alpha: 0.28),
      ),
      icon: icon,
    );
  }
}
