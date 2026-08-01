import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebePageHeaderAlignment { start, center }

class BebePageHeader extends StatelessWidget {
  const BebePageHeader({
    required this.title,
    this.leading,
    this.trailing,
    this.alignment = BebePageHeaderAlignment.center,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final BebePageHeaderAlignment alignment;
  final String? semanticLabel;

  static const double _minimumActionWidth = 48;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    final header = switch (alignment) {
      BebePageHeaderAlignment.start => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            SizedBox(
              width: _minimumActionWidth,
              child: Align(alignment: Alignment.centerLeft, child: leading!),
            ),
            SizedBox(width: spacing.spacingM),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typography.styles.title.lg.bold.copyWith(
                color: colors.text.brandDefault,
              ),
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: spacing.spacingM),
            SizedBox(
              width: _minimumActionWidth,
              child: Align(alignment: Alignment.centerRight, child: trailing!),
            ),
          ],
        ],
      ),
      BebePageHeaderAlignment.center => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _minimumActionWidth,
            child: Align(alignment: Alignment.centerLeft, child: leading),
          ),
          SizedBox(width: spacing.spacingM),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: typography.styles.title.lg.bold.copyWith(
                color: colors.text.brandDefault,
              ),
            ),
          ),
          SizedBox(width: spacing.spacingM),
          SizedBox(
            width: _minimumActionWidth,
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    };

    return Semantics(
      container: true,
      header: true,
      label: semanticLabel ?? title,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: header,
        ),
      ),
    );
  }
}
