import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeAccountSummary extends StatelessWidget {
  const BebeAccountSummary({
    required this.name,
    required this.avatar,
    this.email,
    this.status,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String name;
  final Widget avatar;
  final String? email;
  final Widget? status;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _avatarSize = 64;
  static const double _chevronSize = 22;

  bool get _isInteractive => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;

    final effectiveEmail = email?.trim();
    final effectiveSemanticLabel = semanticLabel?.trim();
    final cardRadius = BorderRadius.circular(radius.radius3xl);

    final content = Padding(
      padding: EdgeInsets.all(spacing.spacingL),
      child: Row(
        children: [
          SizedBox.square(
            dimension: _avatarSize,
            child: ClipOval(child: avatar),
          ),
          SizedBox(width: spacing.spacingL),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.styles.title.md.semibold.copyWith(
                    color: colors.text.neutralTitle,
                  ),
                ),
                if (effectiveEmail != null && effectiveEmail.isNotEmpty) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    effectiveEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.styles.body.sm.regular.copyWith(
                      color: colors.text.neutralBody,
                    ),
                  ),
                ],
                if (status != null) ...[
                  SizedBox(height: spacing.spacingS),
                  status!,
                ],
              ],
            ),
          ),
          if (_isInteractive) ...[
            SizedBox(width: spacing.spacingM),
            Icon(
              Icons.chevron_right_rounded,
              size: _chevronSize,
              color: colors.icons.neutralAlternative,
            ),
          ],
        ],
      ),
    );

    final materialContent = _isInteractive
        ? InkWell(
            onTap: onPressed,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return overlays.interactionPressed;
              }
              if (states.contains(WidgetState.hovered)) {
                return overlays.interactionHover;
              }
              if (states.contains(WidgetState.focused)) {
                return overlays.interactionFocus;
              }
              return null;
            }),
            child: content,
          )
        : content;

    final visual = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        boxShadow: elevation.low,
      ),
      child: Material(
        color: colors.background.neutralsSurface,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: colors.border.neutralDefault),
        ),
        clipBehavior: Clip.antiAlias,
        child: materialContent,
      ),
    );

    final resolvedLabel =
        (effectiveSemanticLabel == null || effectiveSemanticLabel.isEmpty)
        ? [
            name.trim(),
            if (effectiveEmail != null && effectiveEmail.isNotEmpty)
              effectiveEmail,
          ].join('. ')
        : effectiveSemanticLabel;

    if (_isInteractive) {
      return Semantics(
        container: true,
        button: true,
        enabled: true,
        label: resolvedLabel,
        child: ExcludeSemantics(child: visual),
      );
    }

    return Semantics(
      container: true,
      label: resolvedLabel,
      child: ExcludeSemantics(child: visual),
    );
  }
}
