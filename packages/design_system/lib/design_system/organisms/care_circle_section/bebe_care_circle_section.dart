import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeCareCircleSection extends StatelessWidget {
  const BebeCareCircleSection({
    required this.title,
    required this.children,
    this.trailing,
    this.emptyState,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final content = children.isEmpty
        ? emptyState ?? const SizedBox.shrink()
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.radius3xl),
              boxShadow: elevation.low,
            ),
            child: Material(
              color: colors.background.neutralsSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius.radius3xl),
                side: BorderSide(color: colors.border.neutralDefault),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var index = 0; index < children.length; index++) ...[
                    children[index],
                    if (index < children.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colors.border.neutralDefault,
                      ),
                  ],
                ],
              ),
            ),
          );
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(title: title.trim(), trailing: trailing),
          SizedBox(height: spacing.spacingL),
          content,
        ],
      ),
    );
  }
}
