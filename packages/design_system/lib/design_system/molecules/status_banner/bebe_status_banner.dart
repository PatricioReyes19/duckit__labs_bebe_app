import 'package:flutter/material.dart';

enum BebeStatusBannerType {
  neutral,
  information,
  success,
  warning,
  error,
  syncing,
  offline,
}

class BebeStatusBanner extends StatelessWidget {
  const BebeStatusBanner({
    required this.title,
    required this.type,
    this.description,
    this.leading,
    this.trailing,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String? description;
  final BebeStatusBannerType type;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final background = switch (type) {
      BebeStatusBannerType.success => colors.tertiaryContainer,
      BebeStatusBannerType.warning => colors.secondaryContainer,
      BebeStatusBannerType.error => colors.errorContainer,
      BebeStatusBannerType.information ||
      BebeStatusBannerType.syncing => colors.primaryContainer,
      BebeStatusBannerType.offline => colors.surfaceContainerHighest,
      BebeStatusBannerType.neutral => colors.surface,
    };

    final foreground = switch (type) {
      BebeStatusBannerType.success => colors.onTertiaryContainer,
      BebeStatusBannerType.warning => colors.onSecondaryContainer,
      BebeStatusBannerType.error => colors.onErrorContainer,
      BebeStatusBannerType.information ||
      BebeStatusBannerType.syncing => colors.onPrimaryContainer,
      BebeStatusBannerType.offline ||
      BebeStatusBannerType.neutral => colors.onSurface,
    };

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(color: foreground),
              child: leading!,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: foreground),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );

    return Semantics(
      button: onPressed != null,
      label:
          semanticLabel ?? [title, description].whereType<String>().join('. '),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: foreground.withValues(alpha: .18)),
        ),
        clipBehavior: Clip.antiAlias,
        child: onPressed == null
            ? body
            : InkWell(onTap: onPressed, child: body),
      ),
    );
  }
}
