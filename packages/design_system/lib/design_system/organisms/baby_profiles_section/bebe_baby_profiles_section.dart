import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeBabyProfilesSection extends StatelessWidget {
  BebeBabyProfilesSection({
    required this.title,
    required this.children,
    this.trailing,
    this.minimumItemWidth = 240,
    this.maximumColumnCount = 2,
    super.key,
  }) : assert(title.trim().isNotEmpty, 'title must not be empty.'),
       assert(
         children.isNotEmpty,
         'BebeBabyProfilesSection requires at least one child.',
       ),
       assert(
         minimumItemWidth > 0,
         'minimumItemWidth must be greater than zero.',
       ),
       assert(
         maximumColumnCount > 0,
         'maximumColumnCount must be greater than zero.',
       );

  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final double minimumItemWidth;
  final int maximumColumnCount;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(title: title.trim(), trailing: trailing),
          SizedBox(height: spacing.spacingL),
          BebeAdaptiveGrid(
            minimumItemWidth: minimumItemWidth,
            maximumColumnCount: maximumColumnCount,
            children: children,
          ),
        ],
      ),
    );
  }
}
