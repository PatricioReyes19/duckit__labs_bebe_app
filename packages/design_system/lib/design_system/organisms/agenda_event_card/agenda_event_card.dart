import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'event_card_palette.dart';

class BebeAgendaEventCard extends StatelessWidget {
  const BebeAgendaEventCard({
    required this.time,
    required this.icon,
    required this.title,
    this.description,
    this.variant = BebeAgendaEventCardVariant.neutral,
    this.layout = BebeAgendaEventCardLayout.responsive,
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
  final BebeAgendaEventCardLayout layout;
  final Widget? caregiver;
  final Widget? status;
  final Widget? syncIndicator;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _compactBreakpoint = 360;
  static const double _leadingContainerSize = 44;
  static const double _leadingIconSize = 20;
  static const double _chevronSlotWidth = 24;
  static const double _chevronIconSize = 20;

  bool get _isInteractive => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;
    final colors = theme.colors;

    final effectiveTitle = title.trim();
    final effectiveDescription = _normalizeText(description);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final palette = BebeAgendaEventCardPalette.resolve(
      colors: colors,
      variant: variant,
    );

    final borderRadius = BorderRadius.circular(radius.radius3xl);

    final content = switch (layout) {
      BebeAgendaEventCardLayout.carousel => _CarouselAgendaEventLayout(
        time: time,
        icon: icon,
        title: effectiveTitle,
        description: effectiveDescription,
        caregiver: caregiver,
        status: status,
        syncIndicator: syncIndicator,
        palette: palette,
        showChevron: _isInteractive,
      ),

      BebeAgendaEventCardLayout.responsive => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _compactBreakpoint) {
            return _CompactAgendaEventLayout(
              time: time,
              icon: icon,
              title: effectiveTitle,
              description: effectiveDescription,
              caregiver: caregiver,
              status: status,
              syncIndicator: syncIndicator,
              palette: palette,
              showChevron: _isInteractive,
            );
          }

          return _HorizontalAgendaEventLayout(
            time: time,
            icon: icon,
            title: effectiveTitle,
            description: effectiveDescription,
            caregiver: caregiver,
            status: status,
            syncIndicator: syncIndicator,
            palette: palette,
            showChevron: _isInteractive,
          );
        },
      ),
    };

    final materialContent = _isInteractive
        ? InkWell(
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
            child: content,
          )
        : content;

    final visualCard = SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: elevation.low,
        ),
        child: Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: palette.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: materialContent,
        ),
      ),
    );

    final generatedSemanticLabel = [
      effectiveTitle,
      ?effectiveDescription,
    ].join('. ');

    final resolvedSemanticLabel =
        effectiveSemanticLabel ?? generatedSemanticLabel;

    if (_isInteractive) {
      return Semantics(
        container: true,
        button: true,
        enabled: true,
        label: resolvedSemanticLabel,
        child: ExcludeSemantics(child: visualCard),
      );
    }

    return Semantics(
      container: true,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: visualCard),
    );
  }

  static String? _normalizeText(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
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
  final BebeAgendaEventCardPalette palette;
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
            _AgendaEventChevron(color: palette.chevronContent),
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
  final BebeAgendaEventCardPalette palette;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: time),
              if (showChevron) ...[
                const Spacer(),
                _AgendaEventChevron(color: palette.chevronContent),
              ],
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
              if (status != null ||
                  syncIndicator != null ||
                  caregiver != null) ...[
                SizedBox(width: spacing.spacingM),
                Wrap(
                  spacing: spacing.spacingS,
                  runSpacing: spacing.spacingS,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [?status, ?syncIndicator, ?caregiver],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CarouselAgendaEventLayout extends StatelessWidget {
  const _CarouselAgendaEventLayout({
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
  final BebeAgendaEventCardPalette palette;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AgendaEventLeading(icon: icon, palette: palette),
              SizedBox(width: spacing.spacingM),
              Expanded(
                child: BebeInformationContent(
                  title: title,
                  description: description,
                ),
              ),
              if (showChevron) ...[
                SizedBox(width: spacing.spacingS),
                _AgendaEventChevron(color: palette.chevronContent),
              ],
            ],
          ),
          SizedBox(height: spacing.spacingM),
          Wrap(
            spacing: spacing.spacingM,
            runSpacing: spacing.spacingS,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [time, ?status, ?syncIndicator, ?caregiver],
          ),
        ],
      ),
    );
  }
}

class _AgendaEventLeading extends StatelessWidget {
  const _AgendaEventLeading({required this.icon, required this.palette});

  final Widget icon;
  final BebeAgendaEventCardPalette palette;

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
              color: palette.iconContent,
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
    return SizedBox(
      width: BebeAgendaEventCard._chevronSlotWidth,
      child: Align(
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.chevron_right_rounded,
          size: BebeAgendaEventCard._chevronIconSize,
          color: color,
        ),
      ),
    );
  }
}
