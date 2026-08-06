import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeTimelineEntry {
  const BebeTimelineEntry({
    required this.timeLabel,
    required this.title,
    required this.icon,
    this.description,
    this.metadata,
    this.status,
    this.variant = BebeLeadingIconVariant.neutral,
    this.onPressed,
    this.semanticLabel,
  });

  final String timeLabel;
  final String title;
  final Widget icon;
  final String? description;
  final Widget? metadata;
  final Widget? status;
  final BebeLeadingIconVariant variant;
  final VoidCallback? onPressed;
  final String? semanticLabel;
}

/// Timeline organism used by daily history and clinical activity screens.
class BebeTimeline extends StatelessWidget {
  const BebeTimeline({
    required this.entries,
    this.semanticLabel = 'Línea de tiempo',
    super.key,
  }) : assert(entries.length > 0);

  final List<BebeTimelineEntry> entries;
  final String semanticLabel;

  static const double _compactBreakpoint = 360;
  static const double _maximumWideTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final compact =
              constraints.maxWidth < _compactBreakpoint ||
              scale > _maximumWideTextScale;

          return Column(
            children: [
              for (var index = 0; index < entries.length; index++)
                _TimelineEntryView(
                  entry: entries[index],
                  compact: compact,
                  isFirst: index == 0,
                  isLast: index == entries.length - 1,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineEntryView extends StatelessWidget {
  const _TimelineEntryView({
    required this.entry,
    required this.compact,
    required this.isFirst,
    required this.isLast,
  });

  final BebeTimelineEntry entry;
  final bool compact;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact)
            SizedBox(
              width: 64,
              child: Padding(
                padding: EdgeInsets.only(top: spacing.spacingM),
                child: Text(
                  entry.timeLabel,
                  textAlign: TextAlign.right,
                  style: context.theme.typography.styles.label.sm.semibold
                      .copyWith(color: context.theme.colors.text.neutralBody),
                ),
              ),
            ),
          if (!compact) SizedBox(width: spacing.spacingM),
          SizedBox(
            width: 48,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isFirst)
                  Positioned(top: 0, bottom: 24, child: _TimelineLine()),
                if (!isLast)
                  Positioned(top: 24, bottom: 0, child: _TimelineLine()),
                Padding(
                  padding: EdgeInsets.only(top: spacing.spacingXs),
                  child: BebeLeadingIcon(
                    icon: entry.icon,
                    variant: entry.variant,
                    size: BebeLeadingIconSize.medium,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.spacingM),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : spacing.spacingL),
              child: _TimelineCard(entry: entry, showTime: compact),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2,
      child: ColoredBox(color: context.theme.colors.border.neutralDefault),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.entry, required this.showTime});

  final BebeTimelineEntry entry;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = BorderRadius.circular(theme.borderRadius.radius3xl);
    final description = _normalize(entry.description);

    final content = Padding(
      padding: EdgeInsets.all(spacing.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTime) ...[
                  Text(
                    entry.timeLabel,
                    style: theme.typography.styles.label.sm.semibold.copyWith(
                      color: theme.colors.text.brandDefault,
                    ),
                  ),
                  SizedBox(height: spacing.spacingXs),
                ],
                Text(
                  entry.title,
                  style: theme.typography.styles.title.sm.semibold.copyWith(
                    color: theme.colors.text.neutralTitle,
                  ),
                ),
                if (description != null) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    description,
                    style: theme.typography.styles.body.sm.regular.copyWith(
                      color: theme.colors.text.neutralBody,
                    ),
                  ),
                ],
                if (entry.metadata != null) ...[
                  SizedBox(height: spacing.spacingS),
                  entry.metadata!,
                ],
              ],
            ),
          ),
          if (entry.status != null) ...[
            SizedBox(width: spacing.spacingS),
            Flexible(child: entry.status!),
          ],
          if (entry.onPressed != null) ...[
            SizedBox(width: spacing.spacingS),
            const BebeCardChevron(),
          ],
        ],
      ),
    );

    final card = Material(
      color: theme.colors.background.neutralsSurface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: theme.colors.border.neutralDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: entry.onPressed, child: content),
    );

    return Semantics(
      container: true,
      button: entry.onPressed != null,
      enabled: entry.onPressed != null,
      label:
          entry.semanticLabel ??
          [entry.timeLabel, entry.title, ?description].join('. '),
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: theme.elevation.low,
          ),
          child: card,
        ),
      ),
    );
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
