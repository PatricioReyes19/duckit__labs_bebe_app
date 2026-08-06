import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeFamilyOverviewTemplate extends StatelessWidget {
  const BebeFamilyOverviewTemplate({
    required this.familyContext,
    required this.familySummary,
    required this.babiesSection,
    required this.careCircleSection,
    this.familyActions,
    this.horizontalPadding,
    this.maximumContentWidth = BebeLayout.pageContentMaxWidth,
    super.key,
  });

  final Widget familyContext;
  final Widget familySummary;
  final Widget babiesSection;
  final Widget careCircleSection;
  final Widget? familyActions;
  final double? horizontalPadding;
  final double maximumContentWidth;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final effectiveHorizontalPadding = horizontalPadding ?? spacing.spacingL;
    return ColoredBox(
      color: context.theme.colors.background.neutralsSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          spacing.spacingS,
          spacing.spacingS,
          spacing.spacingS,
          spacing.spacing4xl,
        ),
        child: BebeResponsiveContent(
          maxWidth: maximumContentWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: effectiveHorizontalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                familyContext,
                SizedBox(height: spacing.spacingXl),
                familySummary,
                SizedBox(height: spacing.spacingXl),
                babiesSection,
                SizedBox(height: spacing.spacingXl),
                careCircleSection,
                if (familyActions != null) ...[
                  SizedBox(height: spacing.spacingXl),
                  familyActions!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
