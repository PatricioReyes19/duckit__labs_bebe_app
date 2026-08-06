import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeSettingsOverviewTemplate extends StatelessWidget {
  const BebeSettingsOverviewTemplate({
    required this.accountSection,
    required this.preferencesSection,
    required this.privacySection,
    this.notificationsSection,
    this.accessibilitySection,
    this.storageSection,
    this.supportSection,
    this.sessionActions,
    this.horizontalPadding,
    this.maximumContentWidth = BebeLayout.formContentMaxWidth,
    super.key,
  });

  final Widget accountSection;
  final Widget preferencesSection;
  final Widget privacySection;
  final Widget? notificationsSection;
  final Widget? accessibilitySection;
  final Widget? storageSection;
  final Widget? supportSection;
  final Widget? sessionActions;
  final double? horizontalPadding;
  final double maximumContentWidth;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final effectivePadding = horizontalPadding ?? spacing.spacingL;

    final sections = <Widget>[
      accountSection,
      preferencesSection,
      ?notificationsSection,
      ?accessibilitySection,
      privacySection,
      ?storageSection,
      ?supportSection,
      ?sessionActions,
    ];

    return ColoredBox(
      color: context.theme.colors.background.neutralsSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: spacing.spacing4xl),
        child: BebeResponsiveContent(
          maxWidth: maximumContentWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: effectivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < sections.length; index++) ...[
                  sections[index],
                  if (index < sections.length - 1)
                    SizedBox(height: spacing.spacingXl),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
