import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeUpcomingHealthStatus { success, information, attention }

enum BebeUpcomingHealthType { control, vaccine, exam, appointment, other }

class BebeUpcomingHealthData {
  const BebeUpcomingHealthData({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.icon,
    this.type = BebeUpcomingHealthType.control,
    this.caregiverLabel,
    this.semanticLabel,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final Widget icon;

  /// Tipo funcional del evento.
  final BebeUpcomingHealthType type;

  final String? caregiverLabel;
  final String? semanticLabel;
}

class BebeUpcomingHealthSection extends StatelessWidget {
  const BebeUpcomingHealthSection({
    required this.data,
    this.title = 'Próxima atención de salud',
    this.viewAgendaLabel = 'Ver agenda',
    this.openHealthLabel = 'Ir a Salud',
    this.viewAgendaIcon = const Icon(Icons.calendar_month_outlined),
    this.openHealthIcon = const Icon(Icons.health_and_safety_outlined),
    this.isEmpty = false,
    this.emptyTitle = 'No tienes controles próximos',
    this.emptyDescription = 'Agenda al día',
    this.titleActionLabel,
    this.onTitleActionPressed,
    this.onCardPressed,
    this.onViewAgendaPressed,
    this.onOpenHealthPressed,
    super.key,
  });

  final BebeUpcomingHealthData data;
  final String title;

  final String viewAgendaLabel;
  final String openHealthLabel;

  final Widget viewAgendaIcon;
  final Widget openHealthIcon;
  final bool isEmpty;
  final String emptyTitle;
  final String emptyDescription;
  final String? titleActionLabel;
  final VoidCallback? onTitleActionPressed;

  final VoidCallback? onCardPressed;
  final VoidCallback? onViewAgendaPressed;
  final VoidCallback? onOpenHealthPressed;

  bool get _hasFooterActions =>
      onViewAgendaPressed != null && onOpenHealthPressed != null;

  @override
  Widget build(BuildContext context) {
    assert(
      (onViewAgendaPressed == null && onOpenHealthPressed == null) ||
          (onViewAgendaPressed != null && onOpenHealthPressed != null),
      'BebeUpcomingHealthSection requires both footer callbacks '
      'or neither of them.',
    );

    final theme = context.theme;
    final spacing = theme.spacing;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(
            title: title,
            actionLabel: titleActionLabel,
            onActionPressed: onTitleActionPressed,
          ),
          SizedBox(height: isEmpty ? spacing.spacingM : spacing.spacingXl),
          if (isEmpty)
            _UpcomingHealthEmptyCard(
              title: emptyTitle,
              description: emptyDescription,
              onPressed: onCardPressed,
            )
          else
            BebeUpcomingHealthCard(
              title: data.title,
              dateLabel: data.dateLabel,
              timeLabel: data.timeLabel,
              caregiverLabel: data.caregiverLabel,
              icon: data.icon,
              variant: data.type.toCardVariant(),
              semanticLabel: data.semanticLabel,
              onPressed: onCardPressed,
              footer: _hasFooterActions
                  ? BebeUpcomingHealthActions(
                      viewAgendaLabel: viewAgendaLabel,
                      openHealthLabel: openHealthLabel,
                      viewAgendaIcon: viewAgendaIcon,
                      openHealthIcon: openHealthIcon,
                      onViewAgendaPressed: onViewAgendaPressed!,
                      onOpenHealthPressed: onOpenHealthPressed!,
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

class _UpcomingHealthEmptyCard extends StatelessWidget {
  const _UpcomingHealthEmptyCard({
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final String title;
  final String description;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = BorderRadius.circular(theme.borderRadius.radius3xl);
    return Semantics(
      button: onPressed != null,
      label: '$title. $description',
      child: Material(
        color: theme.colors.background.neutralsSurface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: theme.colors.border.neutralDefault),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.spacingL,
                vertical: theme.spacing.spacingM,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    color: theme.colors.icons.brandDefault,
                  ),
                  SizedBox(width: theme.spacing.spacingM),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.typography.styles.label.lg.semibold
                              .copyWith(color: theme.colors.text.neutralTitle),
                        ),
                        SizedBox(height: theme.spacing.spacingXs),
                        Text(
                          description,
                          style: theme.typography.styles.body.sm.regular
                              .copyWith(color: theme.colors.text.neutralBody),
                        ),
                      ],
                    ),
                  ),
                  if (onPressed != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colors.icons.brandDefault,
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

extension BebeUpcomingHealthTypeMapper on BebeUpcomingHealthType {
  BebeUpcomingHealthCardVariant toCardVariant() {
    return switch (this) {
      BebeUpcomingHealthType.control => BebeUpcomingHealthCardVariant.brand,

      BebeUpcomingHealthType.vaccine => BebeUpcomingHealthCardVariant.accent,

      BebeUpcomingHealthType.exam => BebeUpcomingHealthCardVariant.information,

      BebeUpcomingHealthType.appointment => BebeUpcomingHealthCardVariant.brand,

      BebeUpcomingHealthType.other => BebeUpcomingHealthCardVariant.neutral,
    };
  }
}

/// Loading representation owned by [BebeUpcomingHealthSection].
class BebeUpcomingHealthSectionSkeleton extends StatelessWidget {
  const BebeUpcomingHealthSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.spacingXl,
      children: [
        const BebeSkeleton.line(width: 210, height: 18),
        BebeSkeleton(
          height: 156,
          borderRadius: BorderRadius.circular(
            context.theme.borderRadius.radius3xl,
          ),
        ),
      ],
    );
  }
}
