import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeSettingsActionTile extends StatelessWidget {
  const BebeSettingsActionTile({
    required this.title,
    required this.icon,
    this.description,
    this.trailing,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final Widget icon;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _iconContainerSize = 44;
  static const double _iconSize = 22;
  static const double _chevronSize = 20;

  bool get _isInteractive => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final overlays = theme.overlays;

    final effectiveTitle = title.trim();
    final effectiveDescription = _normalizeText(description);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.spacingL,
        vertical: spacing.spacingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: _iconContainerSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background.neutralsActive,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(
                    size: _iconSize,
                    color: colors.icons.neutralAlternative,
                  ),
                  child: icon,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing.spacingM),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effectiveTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.styles.title.sm.semibold.copyWith(
                    color: colors.text.neutralTitle,
                  ),
                ),
                if (effectiveDescription != null) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    effectiveDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.styles.body.sm.regular.copyWith(
                      color: colors.text.neutralBody,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: spacing.spacingM),
            trailing!,
          ] else if (_isInteractive) ...[
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

    final visual = _isInteractive
        ? Material(
            color: Colors.transparent,
            child: InkWell(
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
            ),
          )
        : content;

    final resolvedSemanticLabel =
        effectiveSemanticLabel ??
        [
          effectiveTitle,
          if (effectiveDescription != null) effectiveDescription,
        ].join('. ');

    if (_isInteractive) {
      return Semantics(
        container: true,
        button: true,
        enabled: true,
        label: resolvedSemanticLabel,
        child: ExcludeSemantics(child: visual),
      );
    }

    return Semantics(
      container: true,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: visual),
    );
  }

  static String? _normalizeText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
