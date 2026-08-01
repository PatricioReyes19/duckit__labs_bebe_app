import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeAgendaSupportBannerVariant { brand, information, warning }

class BebeAgendaSupportBanner extends StatelessWidget {
  const BebeAgendaSupportBanner({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onActionPressed,
    this.variant = BebeAgendaSupportBannerVariant.brand,
    this.actionIcon,
    this.semanticLabel,
    super.key,
  });

  final Widget icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onActionPressed;
  final BebeAgendaSupportBannerVariant variant;

  /// Icono opcional ubicado después del texto de acción.
  ///
  /// Su tamaño será controlado por el banner.
  final Widget? actionIcon;

  final String? semanticLabel;

  static const double _horizontalBreakpoint = 360;
  static const double _maximumHorizontalTextScale = 1.3;

  static const double _leadingContainerSize = 44;
  static const double _leadingIconSize = 22;
  static const double _actionIconSize = 18;

  static const double _minimumActionHeight = 44;
  static const double _minimumActionWidth = 44;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;

    final palette = _AgendaSupportBannerPalette.resolve(
      context: context,
      variant: variant,
    );

    final textScaler = MediaQuery.textScalerOf(context);

    final banner = Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.spacingL,
          vertical: spacing.spacingM,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useHorizontalLayout =
                constraints.maxWidth >= _horizontalBreakpoint &&
                textScaler.scale(1) <= _maximumHorizontalTextScale;

            if (!useHorizontalLayout) {
              return _AgendaSupportBannerVerticalLayout(
                icon: icon,
                title: title,
                description: description,
                actionLabel: actionLabel,
                actionIcon: actionIcon,
                onActionPressed: onActionPressed,
                palette: palette,
              );
            }

            return _AgendaSupportBannerHorizontalLayout(
              icon: icon,
              title: title,
              description: description,
              actionLabel: actionLabel,
              actionIcon: actionIcon,
              onActionPressed: onActionPressed,
              palette: palette,
            );
          },
        ),
      ),
    );

    final effectiveSemanticLabel =
        semanticLabel ?? [title, description, actionLabel].join('. ');

    return Semantics(
      container: true,
      label: effectiveSemanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(width: double.infinity, child: banner),
      ),
    );
  }
}

class _AgendaSupportBannerHorizontalLayout extends StatelessWidget {
  const _AgendaSupportBannerHorizontalLayout({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.actionIcon,
    required this.onActionPressed,
    required this.palette,
  });

  final Widget icon;
  final String title;
  final String description;
  final String actionLabel;
  final Widget? actionIcon;
  final VoidCallback? onActionPressed;
  final _AgendaSupportBannerPalette palette;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _AgendaSupportBannerLeading(icon: icon, palette: palette),
        SizedBox(width: spacing.spacingM),
        Expanded(
          child: _AgendaSupportBannerContent(
            title: title,
            description: description,
            palette: palette,
          ),
        ),
        SizedBox(width: spacing.spacingM),
        Flexible(
          child: _AgendaSupportBannerAction(
            label: actionLabel,
            icon: actionIcon,
            onPressed: onActionPressed,
            palette: palette,
          ),
        ),
      ],
    );
  }
}

class _AgendaSupportBannerVerticalLayout extends StatelessWidget {
  const _AgendaSupportBannerVerticalLayout({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.actionIcon,
    required this.onActionPressed,
    required this.palette,
  });

  final Widget icon;
  final String title;
  final String description;
  final String actionLabel;
  final Widget? actionIcon;
  final VoidCallback? onActionPressed;
  final _AgendaSupportBannerPalette palette;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AgendaSupportBannerLeading(icon: icon, palette: palette),
            SizedBox(width: spacing.spacingM),
            Expanded(
              child: _AgendaSupportBannerContent(
                title: title,
                description: description,
                palette: palette,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.spacingM),
        Align(
          alignment: Alignment.centerRight,
          child: _AgendaSupportBannerAction(
            label: actionLabel,
            icon: actionIcon,
            onPressed: onActionPressed,
            palette: palette,
          ),
        ),
      ],
    );
  }
}

class _AgendaSupportBannerLeading extends StatelessWidget {
  const _AgendaSupportBannerLeading({
    required this.icon,
    required this.palette,
  });

  final Widget icon;
  final _AgendaSupportBannerPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: BebeAgendaSupportBanner._leadingContainerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.iconSurface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: BebeAgendaSupportBanner._leadingIconSize,
              color: palette.iconContent,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class _AgendaSupportBannerContent extends StatelessWidget {
  const _AgendaSupportBannerContent({
    required this.title,
    required this.description,
    required this.palette,
  });

  final String? title;
  final String description;
  final _AgendaSupportBannerPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;

    final effectiveTitle = title?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (effectiveTitle != null && effectiveTitle.isNotEmpty) ...[
          Text(
            effectiveTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typography.styles.label.md.semibold.copyWith(
              color: palette.title,
            ),
          ),
          SizedBox(height: spacing.spacingXs),
        ],
        Text(
          description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: typography.styles.body.sm.regular.copyWith(
            color: palette.body,
          ),
        ),
      ],
    );
  }
}

class _AgendaSupportBannerAction extends StatelessWidget {
  const _AgendaSupportBannerAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.palette,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final _AgendaSupportBannerPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final overlays = theme.overlays;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(theme.borderRadius.radiusFull),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return overlays.interactionPressed;
            }

            if (states.contains(WidgetState.hovered)) {
              return overlays.interactionHover;
            }

            if (states.contains(WidgetState.focused)) {
              return overlays.interactionFocus;
            }

            return null;
          }),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: BebeAgendaSupportBanner._minimumActionWidth,
              minHeight: BebeAgendaSupportBanner._minimumActionHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.spacingM,
                vertical: spacing.spacingS,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.styles.label.sm.semibold.copyWith(
                        color: palette.action,
                      ),
                    ),
                  ),
                  if (icon != null) ...[
                    SizedBox(width: spacing.spacingXs),
                    IconTheme(
                      data: IconThemeData(
                        size: BebeAgendaSupportBanner._actionIconSize,
                        color: palette.action,
                      ),
                      child: icon!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AgendaSupportBannerPalette {
  const _AgendaSupportBannerPalette({
    required this.surface,
    required this.border,
    required this.iconSurface,
    required this.iconContent,
    required this.title,
    required this.body,
    required this.action,
  });

  final Color surface;
  final Color border;
  final Color iconSurface;
  final Color iconContent;
  final Color title;
  final Color body;
  final Color action;

  static _AgendaSupportBannerPalette resolve({
    required BuildContext context,
    required BebeAgendaSupportBannerVariant variant,
  }) {
    final colors = context.theme.colors;

    return switch (variant) {
      BebeAgendaSupportBannerVariant.brand => _AgendaSupportBannerPalette(
        surface: colors.background.brandSurface,
        border: colors.border.brandAlternative,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.brandDefault,
        title: colors.text.neutralTitle,
        body: colors.text.neutralBody,
        action: colors.text.brandDefault,
      ),
      BebeAgendaSupportBannerVariant.information => _AgendaSupportBannerPalette(
        surface: colors.background.infoSurface,
        border: colors.border.infoDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.infoDefault,
        title: colors.text.neutralTitle,
        body: colors.text.neutralBody,
        action: colors.text.infoDefault,
      ),
      BebeAgendaSupportBannerVariant.warning => _AgendaSupportBannerPalette(
        surface: colors.background.warningSurface,
        border: colors.border.warningDefault,
        iconSurface: colors.background.neutralsSurface,
        iconContent: colors.text.warningDefault,
        title: colors.text.neutralTitle,
        body: colors.text.neutralBody,
        action: colors.text.warningDefault,
      ),
    };
  }
}
