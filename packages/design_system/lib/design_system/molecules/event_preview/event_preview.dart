import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeEventPreviewVariant {
  neutral,
  brand,
  accent,
  information,
  warning,
  success,
}

class BebeEventPreview extends StatelessWidget {
  const BebeEventPreview({
    required this.title,
    required this.timeLabel,
    required this.icon,
    this.description,
    this.overline,
    this.supporting,
    this.variant = BebeEventPreviewVariant.accent,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String timeLabel;
  final Widget icon;
  final String? description;

  final Widget? overline;

  final Widget? supporting;

  final BebeEventPreviewVariant variant;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _leadingContainerSize = 52;
  static const double _leadingIconSize = 24;
  static const double _compactBreakpoint = 250;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final overlays = theme.overlays;

    final palette = _BebeEventPreviewPalette.resolve(
      context: context,
      variant: variant,
    );

    final preview = Material(
      color: Colors.transparent,
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
        child: Padding(
          padding: EdgeInsets.all(spacing.spacingM),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < _compactBreakpoint;

              if (compact) {
                return _CompactEventPreview(
                  title: title,
                  timeLabel: timeLabel,
                  icon: icon,
                  description: description,
                  overline: overline,
                  supporting: supporting,
                  palette: palette,
                  showChevron: onPressed != null,
                );
              }

              return _HorizontalEventPreview(
                title: title,
                timeLabel: timeLabel,
                icon: icon,
                description: description,
                overline: overline,
                supporting: supporting,
                palette: palette,
                showChevron: onPressed != null,
              );
            },
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: onPressed != null,
      label:
          semanticLabel ??
          [
            title,
            timeLabel,
            if (description != null && description!.trim().isNotEmpty)
              description!.trim(),
          ].join('. '),
      child: ExcludeSemantics(child: preview),
    );
  }
}

class _HorizontalEventPreview extends StatelessWidget {
  const _HorizontalEventPreview({
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.description,
    required this.overline,
    required this.supporting,
    required this.palette,
    required this.showChevron,
  });

  final String title;
  final String timeLabel;
  final Widget icon;
  final String? description;
  final Widget? overline;
  final Widget? supporting;
  final _BebeEventPreviewPalette palette;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _EventPreviewLeading(icon: icon, palette: palette),
        SizedBox(width: spacing.spacingM),
        Expanded(
          child: _EventPreviewContent(
            title: title,
            timeLabel: timeLabel,
            description: description,
            overline: overline,
            supporting: supporting,
          ),
        ),
        if (showChevron) ...[
          SizedBox(width: spacing.spacingS),
          BebeCardChevron(variant: BebeCardChevronVariant.brand),
        ],
      ],
    );
  }
}

class _CompactEventPreview extends StatelessWidget {
  const _CompactEventPreview({
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.description,
    required this.overline,
    required this.supporting,
    required this.palette,
    required this.showChevron,
  });

  final String title;
  final String timeLabel;
  final Widget icon;
  final String? description;
  final Widget? overline;
  final Widget? supporting;
  final _BebeEventPreviewPalette palette;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _EventPreviewLeading(icon: icon, palette: palette),
            const Spacer(),
            if (showChevron)
              const BebeCardChevron(variant: BebeCardChevronVariant.brand),
          ],
        ),
        SizedBox(height: spacing.spacingM),
        _EventPreviewContent(
          title: title,
          timeLabel: timeLabel,
          description: description,
          overline: overline,
          supporting: supporting,
        ),
      ],
    );
  }
}

class _EventPreviewLeading extends StatelessWidget {
  const _EventPreviewLeading({required this.icon, required this.palette});

  final Widget icon;
  final _BebeEventPreviewPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: BebeEventPreview._leadingContainerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.iconSurface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: BebeEventPreview._leadingIconSize,
              color: palette.iconContent,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class _EventPreviewContent extends StatelessWidget {
  const _EventPreviewContent({
    required this.title,
    required this.timeLabel,
    required this.description,
    required this.overline,
    required this.supporting,
  });

  final String title;
  final String timeLabel;
  final String? description;
  final Widget? overline;
  final Widget? supporting;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    final effectiveDescription = description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (overline != null) ...[
          overline!,
          SizedBox(height: spacing.spacingS),
        ],
        Text(
          timeLabel,
          maxLines: 1,
          softWrap: false,
          style: typography.styles.title.lg.semibold.copyWith(
            color: colors.text.neutralTitle,
          ),
        ),
        SizedBox(height: spacing.spacingS),
        Text(
          title,
          style: typography.styles.title.sm.semibold.copyWith(
            color: colors.text.neutralTitle,
          ),
        ),
        if (effectiveDescription != null &&
            effectiveDescription.isNotEmpty) ...[
          SizedBox(height: spacing.spacingXs),
          Text(
            effectiveDescription,
            style: typography.styles.body.sm.regular.copyWith(
              color: colors.text.neutralBody,
            ),
          ),
        ],
        if (supporting != null) ...[
          SizedBox(height: spacing.spacingM),
          supporting!,
        ],
      ],
    );
  }
}

class _BebeEventPreviewPalette {
  const _BebeEventPreviewPalette({
    required this.iconSurface,
    required this.iconContent,
  });

  final Color iconSurface;
  final Color iconContent;

  static _BebeEventPreviewPalette resolve({
    required BuildContext context,
    required BebeEventPreviewVariant variant,
  }) {
    final colors = context.theme.colors;

    return switch (variant) {
      BebeEventPreviewVariant.neutral => _BebeEventPreviewPalette(
        iconSurface: colors.background.neutralsActive,
        iconContent: colors.icons.neutralAlternative,
      ),
      BebeEventPreviewVariant.brand => _BebeEventPreviewPalette(
        iconSurface: colors.background.brandSurface,
        iconContent: colors.text.brandDefault,
      ),
      BebeEventPreviewVariant.accent => _BebeEventPreviewPalette(
        iconSurface: colors.background.accentSurface,
        iconContent: colors.icons.accentDefault,
      ),
      BebeEventPreviewVariant.information => _BebeEventPreviewPalette(
        iconSurface: colors.background.infoSurface,
        iconContent: colors.text.infoDefault,
      ),
      BebeEventPreviewVariant.warning => _BebeEventPreviewPalette(
        iconSurface: colors.background.warningSurface,
        iconContent: colors.text.warningDefault,
      ),
      BebeEventPreviewVariant.success => _BebeEventPreviewPalette(
        iconSurface: colors.background.successSurface,
        iconContent: colors.text.successDefault,
      ),
    };
  }
}
