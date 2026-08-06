import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeTitleSection extends StatelessWidget {
  const BebeTitleSection({
    required this.title,
    this.description,
    this.actionLabel,
    this.onActionPressed,
    this.trailing,
    this.trailingIcon = Icons.chevron_right_rounded,
    this.maxTitleLines,
    this.maxDescriptionLines,
    super.key,
  });

  final String title;
  final String? description;

  final String? actionLabel;
  final VoidCallback? onActionPressed;

  final Widget? trailing;

  final IconData trailingIcon;

  /// Optional visual limits for exceptional dense surfaces.
  ///
  /// They default to null so section copy can grow with its content.
  final int? maxTitleLines;
  final int? maxDescriptionLines;

  static const double _minimumTouchTarget = 44;
  static const double _actionIconSize = 20;

  bool get _showDescription =>
      description != null && description!.trim().isNotEmpty;

  bool get _showAction => actionLabel != null && actionLabel!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    assert(
      trailing == null || !_showAction,
      'BebeTitleSection cannot receive trailing and actionLabel '
      'at the same time.',
    );

    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    final copy = Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: maxTitleLines,
            overflow: maxTitleLines == null ? null : TextOverflow.ellipsis,
            style: typography.styles.title.lg.semibold.copyWith(
              color: colors.text.neutralTitle,
            ),
          ),
          if (_showDescription) ...[
            SizedBox(height: spacing.spacingS),
            Text(
              description!,
              maxLines: maxDescriptionLines,
              overflow: maxDescriptionLines == null
                  ? null
                  : TextOverflow.ellipsis,
              style: typography.styles.body.md.regular.copyWith(
                color: colors.text.neutralBody,
              ),
            ),
          ],
        ],
      ),
    );

    final accessory =
        trailing ??
        (_showAction
            ? _TitleSectionAction(
                label: actionLabel!,
                icon: trailingIcon,
                onPressed: onActionPressed,
              )
            : null);

    return Semantics(
      container: true,
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final stackContent = constraints.maxWidth < 360 || textScale > 1.3;

            if (accessory == null) return copy;

            if (stackContent) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: copy),
                  SizedBox(width: spacing.spacingM),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: accessory,
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: copy),
                SizedBox(width: spacing.spacingL),
                Flexible(child: accessory),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TitleSectionAction extends StatelessWidget {
  const _TitleSectionAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;
    final overlays = theme.overlays;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(
              BebeTitleSection._minimumTouchTarget,
              BebeTitleSection._minimumTouchTarget,
            ),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: spacing.spacingS,
              vertical: spacing.spacingM,
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.text.neutralDisabled;
            }

            return colors.text.brandDefault;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
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
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: spacing.spacingS,
          children: [
            Text(label, style: typography.styles.label.lg.semibold),
            Icon(icon, size: BebeTitleSection._actionIconSize),
          ],
        ),
      ),
    );
  }
}
