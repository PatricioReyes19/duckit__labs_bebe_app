import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'bebe_care_circle_member_status.dart';

class BebeCareCircleMemberRow extends StatelessWidget {
  const BebeCareCircleMemberRow({
    required this.name,
    required this.avatar,
    required this.role,
    this.accessDescription,
    this.status = BebeCareCircleMemberStatus.active,
    this.onPressed,
    this.trailing,
    this.semanticLabel,
    super.key,
  });

  final String name;
  final Widget avatar;
  final String role;
  final String? accessDescription;
  final BebeCareCircleMemberStatus status;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final String? semanticLabel;

  static const double _avatarSize = 48;
  static const double _chevronSize = 22;
  bool get _isInteractive => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final overlays = theme.overlays;
    final effectiveName = name.trim();
    final effectiveRole = role.trim();
    final effectiveAccessDescription = _normalizeText(accessDescription);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);
    final roleColors = _resolveRoleColors(colors);

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.spacingL,
        vertical: spacing.spacingM,
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: _avatarSize,
            child: ClipOval(child: avatar),
          ),
          SizedBox(width: spacing.spacingM),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: spacing.spacingS,
                  runSpacing: spacing.spacingXs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      effectiveName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.styles.title.sm.semibold.copyWith(
                        color: colors.text.neutralTitle,
                      ),
                    ),
                    DecoratedBox(
                      decoration: ShapeDecoration(
                        color: roleColors.background,
                        shape: const StadiumBorder(),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.spacingS,
                          vertical: spacing.spacingXs,
                        ),
                        child: Text(
                          effectiveRole,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.styles.label.sm.semibold
                              .copyWith(color: roleColors.foreground),
                        ),
                      ),
                    ),
                  ],
                ),
                if (effectiveAccessDescription != null) ...[
                  SizedBox(height: spacing.spacingXs),
                  Text(
                    effectiveAccessDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.styles.body.sm.regular.copyWith(
                      color: _resolveDescriptionColor(colors),
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

    final visualContent = _isInteractive
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
          effectiveName,
          effectiveRole,
          ?effectiveAccessDescription,
          _statusSemanticText,
        ].join('. ');
    return Semantics(
      container: true,
      button: _isInteractive,
      enabled: _isInteractive ? true : null,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: visualContent),
    );
  }

  ({Color background, Color foreground}) _resolveRoleColors(BebeColor colors) {
    return switch (status) {
      BebeCareCircleMemberStatus.active => (
        background: colors.background.brandSurface,
        foreground: colors.text.brandDefault,
      ),
      BebeCareCircleMemberStatus.pending => (
        background: colors.background.warningSurface,
        foreground: colors.text.warningDefault,
      ),
      BebeCareCircleMemberStatus.suspended => (
        background: colors.background.neutralsDisabled,
        foreground: colors.text.neutralDisabled,
      ),
    };
  }

  Color _resolveDescriptionColor(BebeColor colors) {
    return switch (status) {
      BebeCareCircleMemberStatus.active => colors.text.neutralBody,
      BebeCareCircleMemberStatus.pending => colors.text.warningDefault,
      BebeCareCircleMemberStatus.suspended => colors.text.neutralDisabled,
    };
  }

  String get _statusSemanticText => switch (status) {
    BebeCareCircleMemberStatus.active => 'Acceso activo',
    BebeCareCircleMemberStatus.pending => 'Invitación pendiente',
    BebeCareCircleMemberStatus.suspended => 'Acceso suspendido',
  };

  static String? _normalizeText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
