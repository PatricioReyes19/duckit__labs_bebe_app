import 'package:design_system/design_system.dart';
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
    this.footer,
    this.onPressed,
    this.compact = false,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String? description;
  final BebeStatusBannerType type;
  final Widget? leading;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onPressed;
  final bool compact;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spacing = context.theme.spacing;
    final borderRadius = context.theme.borderRadius;

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
      padding: compact
          ? EdgeInsets.symmetric(
              horizontal: spacing.spacingL,
              vertical: spacing.spacingXs,
            )
          : EdgeInsets.all(spacing.spacingL),
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(color: foreground),
              child: leading!,
            ),
            SizedBox(width: spacing.spacingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: compact
                      ? context.theme.typography.styles.label.lg.semibold
                            .copyWith(color: foreground)
                      : Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                ),
                if (description != null) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    description!,
                    style: compact
                        ? context.theme.typography.styles.body.sm.regular
                              .copyWith(color: foreground)
                        : Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: foreground),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: spacing.spacingM),
            trailing!,
          ],
        ],
      ),
    );

    final interactiveBody = onPressed == null
        ? body
        : InkWell(onTap: onPressed, child: body);
    final content = footer == null
        ? interactiveBody
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              interactiveBody,
              Divider(
                height: 1,
                thickness: 1,
                color: foreground.withValues(alpha: .14),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.spacingS,
                  vertical: spacing.spacingXs,
                ),
                child: footer,
              ),
            ],
          );

    return Semantics(
      button: onPressed != null,
      label:
          semanticLabel ?? [title, description].whereType<String>().join('. '),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.radius2xl),
          side: BorderSide(color: foreground.withValues(alpha: .18)),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
