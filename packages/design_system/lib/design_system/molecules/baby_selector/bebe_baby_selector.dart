import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../atoms/avatar/bebe_avatar.dart';

class BebeBabySelector extends StatelessWidget {
  const BebeBabySelector({
    required this.name,
    required this.ageLabel,
    required this.avatar,
    required this.isSelected,
    this.contextLabel,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String name;
  final String ageLabel;
  final BebeAvatar avatar;
  final bool isSelected;
  final String? contextLabel;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;

    final backgroundColor = isSelected
        ? colors.background.brandSurface
        : colors.background.accentSurface;

    final borderColor = isSelected
        ? colors.border.brandAlternative
        : colors.border.accentAlternative;

    final card = Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
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
        child: _BabySelectorContent(
          name: name,
          ageLabel: ageLabel,
          avatar: avatar,
          contextLabel: contextLabel,
          isSelected: isSelected,
        ),
      ),
    );

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: onPressed != null,
      selected: isSelected,
      label:
          semanticLabel ??
          '$name, $ageLabel'
              '${contextLabel == null ? '' : '. $contextLabel'}'
              '${isSelected ? '. Bebé seleccionado' : '. Cambiar a este bebé'}',
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.radius3xl),
            boxShadow: elevation.low,
          ),
          child: card,
        ),
      ),
    );
  }
}

class _BabySelectorContent extends StatelessWidget {
  const _BabySelectorContent({
    required this.name,
    required this.ageLabel,
    required this.avatar,
    required this.contextLabel,
    required this.isSelected,
  });

  final String name;
  final String ageLabel;
  final BebeAvatar avatar;
  final String? contextLabel;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    final nameColor = colors.text.neutralTitle;

    final ageColor = isSelected
        ? colors.text.brandDefault
        : colors.text.accentDefault;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.spacingXl,
        vertical: spacing.spacingL,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
          SizedBox(width: spacing.spacingL),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: typography.styles.title.md.semibold.copyWith(
                          color: nameColor,
                        ),
                      ),
                      TextSpan(
                        text: ' · $ageLabel',
                        style: typography.styles.body.md.regular.copyWith(
                          color: ageColor,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (contextLabel != null &&
                    contextLabel!.trim().isNotEmpty) ...[
                  SizedBox(height: spacing.spacingS),
                  Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 16,
                        color: colors.icons.neutralAlternative,
                      ),
                      SizedBox(width: spacing.spacingS),
                      Expanded(
                        child: Text(
                          contextLabel!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: typography.styles.body.sm.regular.copyWith(
                            color: colors.text.neutralBody,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: spacing.spacingM),
          Icon(
            isSelected
                ? Icons.keyboard_arrow_down_rounded
                : Icons.chevron_right_rounded,
            size: 20,
            color: isSelected
                ? colors.icons.accentDefault
                : colors.icons.neutralAlternative,
          ),
        ],
      ),
    );
  }
}
