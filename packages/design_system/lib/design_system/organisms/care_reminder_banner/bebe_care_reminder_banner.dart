import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeCareReminderBannerVariant { feeding, diaper, medication }

/// Actionable reminder shown shortly before a scheduled care event.
class BebeCareReminderBanner extends StatelessWidget {
  const BebeCareReminderBanner({
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.variant,
    required this.onCompleted,
    required this.onDismissed,
    this.onPressed,
    super.key,
  });

  final String title;
  final String description;
  final String timeLabel;
  final BebeCareReminderBannerVariant variant;
  final VoidCallback onCompleted;
  final VoidCallback onDismissed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BebeStatusBanner(
      title: title,
      description: '$description · Programado a las $timeLabel',
      type: BebeStatusBannerType.warning,
      leading: Icon(switch (variant) {
        BebeCareReminderBannerVariant.feeding => Icons.local_drink_outlined,
        BebeCareReminderBannerVariant.diaper =>
          Icons.baby_changing_station_outlined,
        BebeCareReminderBannerVariant.medication => Icons.medication_outlined,
      }),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
      footer: Wrap(
        alignment: WrapAlignment.end,
        spacing: context.theme.spacing.spacingS,
        runSpacing: context.theme.spacing.spacingXs,
        children: [
          BebeInlineAction(
            label: 'Gracias por recordar',
            icon: const Icon(Icons.notifications_off_outlined),
            onPressed: onDismissed,
            variant: BebeInlineActionVariant.neutral,
            size: BebeInlineActionSize.medium,
          ),
          BebeInlineAction(
            label: 'Ya lo hice',
            icon: const Icon(Icons.task_alt_rounded),
            onPressed: onCompleted,
            variant: BebeInlineActionVariant.success,
            size: BebeInlineActionSize.medium,
          ),
        ],
      ),
      semanticLabel: '$title. $description. Programado a las $timeLabel.',
    );
  }
}

/// Component-owned loading state so templates only need to pass `isLoading`.
class BebeCareReminderBannerSkeleton extends StatelessWidget {
  const BebeCareReminderBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Semantics(
      label: 'Cargando recordatorio',
      child: Container(
        padding: EdgeInsets.all(spacing.spacingL),
        decoration: BoxDecoration(
          color: context.theme.colors.background.neutralsSurface,
          borderRadius: BorderRadius.circular(
            context.theme.borderRadius.radius2xl,
          ),
        ),
        child: Column(
          spacing: spacing.spacingM,
          children: [
            Row(
              children: [
                const BebeSkeleton.circle(size: 32),
                SizedBox(width: spacing.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: spacing.spacingS,
                    children: const [
                      BebeSkeleton.line(width: 190, height: 14),
                      BebeSkeleton.line(height: 12),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const BebeSkeleton.line(width: 120, height: 30),
                SizedBox(width: spacing.spacingS),
                const BebeSkeleton.line(width: 88, height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
