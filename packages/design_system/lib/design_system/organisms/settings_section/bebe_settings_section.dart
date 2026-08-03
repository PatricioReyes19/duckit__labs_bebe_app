import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeSettingsSection extends StatelessWidget {
  const BebeSettingsSection({
    required this.title,
    required this.children,
    this.description,
    this.trailing,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;

    final effectiveDescription = description?.trim();

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(title: title.trim(), trailing: trailing),
          if (effectiveDescription != null &&
              effectiveDescription.isNotEmpty) ...[
            SizedBox(height: spacing.spacingXs),
            Text(
              effectiveDescription,
              style: theme.typography.styles.body.sm.regular.copyWith(
                color: colors.text.neutralBody,
              ),
            ),
          ],
          SizedBox(height: spacing.spacingL),
          DecoratedBox(
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
          ),
        ],
      ),
    );
  }
}
