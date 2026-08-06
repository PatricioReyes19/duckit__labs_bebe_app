import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeBabyProfileCard extends StatelessWidget {
  const BebeBabyProfileCard({
    required this.name,
    required this.avatar,
    this.supportingText,
    this.isActive = false,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final String name;
  final Widget avatar;
  final String? supportingText;
  final bool isActive;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  static const double _avatarSize = 64;
  static const double _chevronSize = 22;
  bool get _isInteractive => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;
    final effectiveName = name.trim();
    final effectiveSupportingText = _normalizeText(supportingText);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);
    final borderColor = isActive
        ? colors.border.brandAlternative
        : colors.border.neutralDefault;
    final cardRadius = BorderRadius.circular(radius.radius3xl);

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        return _BabyProfileCardContent(
          name: effectiveName,
          supportingText: effectiveSupportingText,
          avatar: avatar,
          isActive: isActive,
          interactive: _isInteractive,
          compact: constraints.maxWidth < 220 || textScale > 1.3,
        );
      },
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

    final visualCard = SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: cardRadius,
          boxShadow: elevation.low,
        ),
        child: Material(
          color: colors.background.neutralsSurface,
          shape: RoundedRectangleBorder(
            borderRadius: cardRadius,
            side: BorderSide(color: borderColor, width: isActive ? 2 : 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: materialContent,
        ),
      ),
    );

    final resolvedSemanticLabel =
        effectiveSemanticLabel ??
        [
          effectiveName,
          ?effectiveSupportingText,
          if (isActive) 'Bebé activo',
        ].join('. ');
    return Semantics(
      container: true,
      button: _isInteractive,
      enabled: _isInteractive ? true : null,
      selected: isActive,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: visualCard),
    );
  }

  static String? _normalizeText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

class _BabyProfileCardContent extends StatelessWidget {
  const _BabyProfileCardContent({
    required this.name,
    required this.supportingText,
    required this.avatar,
    required this.isActive,
    required this.interactive,
    required this.compact,
  });

  final String name;
  final String? supportingText;
  final Widget avatar;
  final bool isActive;
  final bool interactive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final supportingColor = isActive
        ? colors.text.brandDefault
        : colors.text.neutralBody;
    final avatarView = SizedBox.square(
      dimension: compact ? 40 : BebeBabyProfileCard._avatarSize,
      child: ClipOval(child: avatar),
    );
    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.typography.styles.title.sm.semibold.copyWith(
            color: colors.text.neutralTitle,
          ),
        ),
        if (supportingText != null) ...[
          SizedBox(height: spacing.spacingXs),
          Text(
            supportingText!,
            style: theme.typography.styles.body.sm.regular.copyWith(
              color: supportingColor,
            ),
          ),
        ],
      ],
    );
    final chevron = Icon(
      Icons.chevron_right_rounded,
      size: BebeBabyProfileCard._chevronSize,
      color: isActive
          ? colors.text.brandDefault
          : colors.icons.neutralAlternative,
    );

    return Padding(
      padding: EdgeInsets.all(compact ? spacing.spacingS : spacing.spacingL),
      child: compact
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatarView,
                SizedBox(width: spacing.spacingS),
                Expanded(child: copy),
                if (interactive) ...[
                  SizedBox(width: spacing.spacingS),
                  chevron,
                ],
              ],
            )
          : Row(
              children: [
                avatarView,
                SizedBox(width: spacing.spacingL),
                Expanded(child: copy),
                if (interactive) ...[
                  SizedBox(width: spacing.spacingM),
                  chevron,
                ],
              ],
            ),
    );
  }
}
