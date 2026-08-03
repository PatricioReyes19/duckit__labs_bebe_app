import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeSettingsValueTile extends StatelessWidget {
  const BebeSettingsValueTile({
    required this.title,
    required this.value,
    this.description,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String value;
  final String? description;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _chevronSize = 20;

  bool get _isInteractive => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final overlays = theme.overlays;

    final effectiveTitle = title.trim();
    final effectiveValue = value.trim();
    final effectiveDescription = _normalizeText(description);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.spacingL,
        vertical: spacing.spacingM,
      ),
      child: Row(
        children: [
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
          SizedBox(width: spacing.spacingM),
          Flexible(
            child: Text(
              effectiveValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.typography.styles.body.sm.regular.copyWith(
                color: colors.text.neutralBody,
              ),
            ),
          ),
          if (_isInteractive) ...[
            SizedBox(width: spacing.spacingS),
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
          effectiveValue,
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
