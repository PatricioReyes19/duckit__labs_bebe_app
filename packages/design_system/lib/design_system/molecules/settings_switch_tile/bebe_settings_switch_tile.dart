import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeSettingsSwitchTile extends StatelessWidget {
  const BebeSettingsSwitchTile({
    required this.title,
    required this.value,
    this.description,
    this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final bool value;
  final String? description;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  bool get _isEnabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    final effectiveTitle = title.trim();
    final effectiveDescription = _normalizeText(description);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final visual = Padding(
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
                    color: _isEnabled
                        ? colors.text.neutralTitle
                        : colors.text.neutralDisabled,
                  ),
                ),
                if (effectiveDescription != null) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    effectiveDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.styles.body.sm.regular.copyWith(
                      color: _isEnabled
                          ? colors.text.neutralBody
                          : colors.text.neutralDisabled,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: spacing.spacingM),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );

    return Semantics(
      container: true,
      toggled: value,
      enabled: _isEnabled,
      label:
          effectiveSemanticLabel ??
          [
            effectiveTitle,
            if (effectiveDescription != null) effectiveDescription,
          ].join('. '),
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
