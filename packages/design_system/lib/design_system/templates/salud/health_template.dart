import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeHealthOverviewTemplate extends StatelessWidget {
  const BebeHealthOverviewTemplate({
    required this.primaryActions,
    required this.upcomingHeader,
    required this.upcomingCarousel,
    this.supportAction,
    this.quickSummary,
    this.historyAction,
    this.horizontalPadding,
    this.maximumContentWidth = BebeLayout.pageContentMaxWidth,
    this.onRefresh,
    super.key,
  });

  final Widget primaryActions;

  final Future<void> Function()? onRefresh;

  final Widget upcomingHeader;

  final Widget upcomingCarousel;

  final Widget? supportAction;
  final Widget? quickSummary;
  final Widget? historyAction;

  final double? horizontalPadding;
  final double maximumContentWidth;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final effectiveHorizontalPadding = horizontalPadding ?? spacing.spacingL;

    Widget padded(Widget child) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: effectiveHorizontalPadding),
        child: child,
      );
    }

    return ColoredBox(
      color: context.theme.colors.background.neutralsSurface,
      child: SingleChildScrollView(
        physics: onRefresh != null
            ? const AlwaysScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        padding: EdgeInsets.all(spacing.spacingXs),
        child: BebeResponsiveContent(
          maxWidth: maximumContentWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              padded(primaryActions),
              if (supportAction != null) ...[
                SizedBox(height: spacing.spacingXl),
                padded(supportAction!),
              ],
              SizedBox(height: spacing.spacingXl),
              padded(upcomingHeader),
              SizedBox(height: spacing.spacingL),

              // Intencionalmente sin padding horizontal.
              upcomingCarousel,

              if (quickSummary != null) ...[
                SizedBox(height: spacing.spacingXl),
                padded(quickSummary!),
              ],
              if (historyAction != null) ...[
                SizedBox(height: spacing.spacingXl),
                padded(historyAction!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
