import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeAgendaEventCard extends StatelessWidget {
  const BebeAgendaEventCard({
    required this.time,
    required this.icon,
    required this.title,
    this.description,
    this.variant = BebeAgendaEventCardVariant.neutral,
    this.caregiver,
    this.status,
    this.syncIndicator,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final Widget time;
  final Widget icon;
  final String title;
  final String? description;
  final BebeAgendaEventCardVariant variant;
  final Widget? caregiver;
  final Widget? status;
  final Widget? syncIndicator;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _compactBreakpoint = 360;
  static const double _leadingContainerSize = 44;
  static const double _leadingIconSize = 20;
  static const double _chevronIconSize = 20;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final colors = theme.colors;
    final overlays = theme.overlays;

    final palette = _AgendaEventCardPalette.resolve(
      colors: colors,
      variant: variant,
    );

    final material = Material(
      color: colors.background.neutralsSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: BorderSide(color: colors.border.accentAlternative),
      ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _compactBreakpoint) {
              return _CompactAgendaEventLayout(
                time: time,
                icon: icon,
                title: title,
                description: description,
                caregiver: caregiver,
                status: status,
                syncIndicator: syncIndicator,
                palette: palette,
                showChevron: onPressed != null,
              );
            }

            return _HorizontalAgendaEventLayout(
              time: time,
              icon: icon,
              title: title,
              description: description,
              caregiver: caregiver,
              status: status,
              syncIndicator: syncIndicator,
              palette: palette,
              showChevron: onPressed != null,
            );
          },
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
            if (description != null && description!.trim().isNotEmpty)
              description!.trim(),
          ].join('. '),
      child: ExcludeSemantics(
        child: SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.radius3xl),
              boxShadow: elevation.low,
            ),
            child: material,
          ),
        ),
      ),
    );
  }
}

class _HorizontalAgendaEventLayout extends StatelessWidget {
  const _HorizontalAgendaEventLayout({
    required this.time,
    required this.icon,
    required this.title,
    required this.description,
    required this.caregiver,
    required this.status,
    required this.syncIndicator,
    required this.palette,
    required this.showChevron,
  });

  final Widget time;
  final Widget icon;
  final String title;
  final String? description;
  final Widget? caregiver;
  final Widget? status;
  final Widget? syncIndicator;
  final _AgendaEventCardPalette palette;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.spacingL,
        vertical: spacing.spacingL,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 2, child: time),
          SizedBox(width: spacing.spacingM),
          _AgendaEventLeading(icon: icon, palette: palette),
          SizedBox(width: spacing.spacingM),
          Expanded(
            flex: 6,
            child: BebeInformationContent(
              title: title,
              description: description,
            ),
          ),
          if (status != null) ...[
            SizedBox(width: spacing.spacingM),
            Flexible(flex: 3, child: status!),
          ],
          if (syncIndicator != null) ...[
            SizedBox(width: spacing.spacingM),
            Flexible(flex: 3, child: syncIndicator!),
          ],
          if (caregiver != null) ...[
            SizedBox(width: spacing.spacingM),
            Flexible(flex: 3, child: caregiver!),
          ],
          if (showChevron) ...[
            SizedBox(width: spacing.spacingS),
            _AgendaEventChevron(color: palette.chevronColor),
          ],
        ],
      ),
    );
  }
}

class _CompactAgendaEventLayout extends StatelessWidget {
  const _CompactAgendaEventLayout({
    required this.time,
    required this.icon,
    required this.title,
    required this.description,
    required this.caregiver,
    required this.status,
    required this.syncIndicator,
    required this.palette,
    required this.showChevron,
  });

  final Widget time;
  final Widget icon;
  final String title;
  final String? description;
  final Widget? caregiver;
  final Widget? status;
  final Widget? syncIndicator;
  final _AgendaEventCardPalette palette;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: time),
              const Spacer(),
              if (showChevron) _AgendaEventChevron(color: palette.chevronColor),
            ],
          ),
          SizedBox(height: spacing.spacingM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AgendaEventLeading(icon: icon, palette: palette),
              SizedBox(width: spacing.spacingM),
              Expanded(
                child: BebeInformationContent(
                  title: title,
                  description: description,
                ),
              ),
            ],
          ),
          if (status != null || syncIndicator != null || caregiver != null) ...[
            SizedBox(height: spacing.spacingM),
            Wrap(
              spacing: spacing.spacingS,
              runSpacing: spacing.spacingS,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (status != null) status!,
                if (syncIndicator != null) syncIndicator!,
                if (caregiver != null) caregiver!,
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AgendaEventLeading extends StatelessWidget {
  const _AgendaEventLeading({required this.icon, required this.palette});

  final Widget icon;
  final _AgendaEventCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: BebeAgendaEventCard._leadingContainerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.iconSurface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: BebeAgendaEventCard._leadingIconSize,
              color: palette.iconColor,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class _AgendaEventChevron extends StatelessWidget {
  const _AgendaEventChevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: BebeAgendaEventCard._chevronIconSize,
      color: color,
    );
  }
}

class _AgendaEventCardPalette {
  const _AgendaEventCardPalette({
    required this.iconSurface,
    required this.iconColor,
    required this.chevronColor,
  });

  final Color iconSurface;
  final Color iconColor;
  final Color chevronColor;

  static _AgendaEventCardPalette resolve({
    required BebeColor colors,
    required BebeAgendaEventCardVariant variant,
  }) {
    return switch (variant) {
      BebeAgendaEventCardVariant.neutral => _AgendaEventCardPalette(
        iconSurface: colors.background.neutralsActive,
        iconColor: colors.icons.neutralAlternative,
        chevronColor: colors.icons.neutralAlternative,
      ),
      BebeAgendaEventCardVariant.brand => _AgendaEventCardPalette(
        iconSurface: colors.background.brandSurface,
        iconColor: colors.text.brandDefault,
        chevronColor: colors.text.brandDefault,
      ),
      BebeAgendaEventCardVariant.accent => _AgendaEventCardPalette(
        iconSurface: colors.background.accentSurface,
        iconColor: colors.icons.accentDefault,
        chevronColor: colors.icons.accentDefault,
      ),
      BebeAgendaEventCardVariant.information => _AgendaEventCardPalette(
        iconSurface: colors.background.infoSurface,
        iconColor: colors.text.infoDefault,
        chevronColor: colors.text.brandDefault,
      ),
      BebeAgendaEventCardVariant.warning => _AgendaEventCardPalette(
        iconSurface: colors.background.warningSurface,
        iconColor: colors.text.warningDefault,
        chevronColor: colors.text.brandDefault,
      ),
      BebeAgendaEventCardVariant.success => _AgendaEventCardPalette(
        iconSurface: colors.background.successSurface,
        iconColor: colors.text.successDefault,
        chevronColor: colors.text.brandDefault,
      ),
    };
  }
}
