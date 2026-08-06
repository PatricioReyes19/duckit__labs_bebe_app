import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'infor_banner_palette.dart';

class BebeInfoBanner extends StatelessWidget {
  const BebeInfoBanner({
    required this.title,
    required this.description,
    required this.icon,
    this.variant = BebeInfoBannerVariant.information,
    this.action,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String description;
  final Widget icon;

  /// Slot controlado. Puede recibir BebeInlineAction,
  /// un botón secundario u otra acción compatible.
  final Widget? action;

  final BebeInfoBannerVariant variant;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;

    final palette = BebeInfoBannerPalette.resolve(
      colors: theme.colors,
      variant: variant,
    );

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(radius.radius3xl),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.spacingXl),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useVerticalLayout = constraints.maxWidth < 520;

            if (useVerticalLayout) {
              return _CompactInfoBannerContent(
                title: title,
                description: description,
                icon: icon,
                action: action,
                palette: palette,
              );
            }

            return _WideInfoBannerContent(
              title: title,
              description: description,
              icon: icon,
              action: action,
              palette: palette,
            );
          },
        ),
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel ?? '$title. $description.',
      child: SizedBox(width: double.infinity, child: content),
    );
  }
}

class _WideInfoBannerContent extends StatelessWidget {
  const _WideInfoBannerContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
    required this.palette,
  });

  final String title;
  final String description;
  final Widget icon;
  final Widget? action;
  final BebeInfoBannerPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.iconSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(size: 18, color: palette.iconContent),
                child: icon,
              ),
            ),
          ),
        ),
        SizedBox(width: spacing.spacingL),
        Expanded(
          child: _InfoBannerText(
            title: title,
            description: description,
            contentColor: palette.content,
          ),
        ),
        if (action != null) ...[SizedBox(width: spacing.spacingL), action!],
      ],
    );
  }
}

class _CompactInfoBannerContent extends StatelessWidget {
  const _CompactInfoBannerContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
    required this.palette,
  });

  final String title;
  final String description;
  final Widget icon;
  final Widget? action;
  final BebeInfoBannerPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.iconSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(size: 18, color: palette.iconContent),
                    child: icon,
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing.spacingL),
            Expanded(
              child: _InfoBannerText(
                title: title,
                description: description,
                contentColor: palette.content,
              ),
            ),
          ],
        ),
        if (action != null) ...[
          SizedBox(height: spacing.spacingL),
          Align(alignment: Alignment.centerRight, child: action!),
        ],
      ],
    );
  }
}

class _InfoBannerText extends StatelessWidget {
  const _InfoBannerText({
    required this.title,
    required this.description,
    required this.contentColor,
  });

  final String title;
  final String description;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: typography.styles.title.sm.semibold.copyWith(
            color: colors.text.neutralTitle,
          ),
        ),
        SizedBox(height: spacing.spacingS),
        Text(
          description,
          style: typography.styles.body.sm.regular.copyWith(
            color: colors.text.neutralBody,
          ),
        ),
      ],
    );
  }
}
