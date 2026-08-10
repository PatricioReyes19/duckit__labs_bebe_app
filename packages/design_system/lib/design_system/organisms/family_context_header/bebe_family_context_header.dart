import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeFamilyContextHeader extends StatelessWidget {
  const BebeFamilyContextHeader({
    required this.familyName,
    required this.babyName,
    required this.avatar,
    this.babyAge,
    this.supportingText,
    this.onContextPressed,
    this.secondaryContext,
    this.settingsAction,
    this.showFamilyName = true,
    this.semanticLabel,
    super.key,
  });

  final String familyName;

  final String babyName;

  final Widget avatar;

  final String? babyAge;

  final String? supportingText;

  final VoidCallback? onContextPressed;

  final Widget? secondaryContext;

  final Widget? settingsAction;

  final bool showFamilyName;

  final String? semanticLabel;

  static const double _avatarSize = 46;
  static const double _contextChevronSize = 24;

  bool get _isInteractive => onContextPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;

    final effectiveFamilyName = familyName.trim();
    final effectiveBabyName = babyName.trim();
    final effectiveBabyAge = _normalizeText(babyAge);
    final effectiveSupportingText = _normalizeText(supportingText);
    final effectiveSemanticLabel = _normalizeText(semanticLabel);

    final cardRadius = BorderRadius.circular(radius.radius3xl);

    final content = Padding(
      padding: EdgeInsets.all(spacing.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: _avatarSize,
            child: ClipOval(
              child: FittedBox(fit: BoxFit.cover, child: avatar),
            ),
          ),
          SizedBox(width: spacing.spacingL),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showFamilyName) ...[
                  Text(
                    effectiveFamilyName,
                    style: theme.typography.styles.label.sm.semibold.copyWith(
                      color: colors.text.brandDefault,
                    ),
                  ),
                  SizedBox(height: spacing.spacingXs),
                ],
                Wrap(
                  spacing: spacing.spacingS,
                  runSpacing: spacing.spacingXs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      effectiveBabyName,
                      style: theme.typography.styles.title.md.semibold.copyWith(
                        color: colors.text.neutralTitle,
                      ),
                    ),
                    if (effectiveBabyAge != null)
                      Text(
                        '· $effectiveBabyAge',
                        style: theme.typography.styles.body.md.regular.copyWith(
                          color: colors.text.neutralBody,
                        ),
                      ),
                  ],
                ),
                if (effectiveSupportingText != null) ...[
                  SizedBox(height: spacing.spacingS),
                  Row(
                    children: [
                      Icon(
                        Icons.groups_2_outlined,
                        size: 20,
                        color: colors.icons.neutralAlternative,
                      ),
                      SizedBox(width: spacing.spacingS),
                      Expanded(
                        child: Text(
                          effectiveSupportingText,
                          style: theme.typography.styles.body.sm.regular
                              .copyWith(color: colors.text.neutralBody),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (_isInteractive) ...[
            SizedBox(width: spacing.spacingM),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: _contextChevronSize,
              color: colors.text.brandDefault,
            ),
          ],
        ],
      ),
    );

    final interactiveContent = _isInteractive
        ? InkWell(
            onTap: onContextPressed,
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

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120, minHeight: 100),
      child: DecoratedBox(
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
          child: interactiveContent,
        ),
      ),
    );

    final generatedSemanticLabel = [
      effectiveFamilyName,
      effectiveBabyName,
      ?effectiveBabyAge,
      ?effectiveSupportingText,
    ].join('. ');

    final resolvedSemanticLabel =
        effectiveSemanticLabel ?? generatedSemanticLabel;

    final primaryCard = Semantics(
      container: true,
      button: _isInteractive,
      enabled: _isInteractive ? true : null,
      label: resolvedSemanticLabel,
      hint: _isInteractive ? 'Cambiar contexto familiar' : null,
      child: ExcludeSemantics(child: card),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final stackAccessories = constraints.maxWidth < 300 || textScale > 1.3;
        final accessories = <Widget>[?secondaryContext, ?settingsAction];

        if (accessories.isEmpty) return primaryCard;

        if (stackAccessories) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primaryCard,
              for (final accessory in accessories) ...[
                SizedBox(height: spacing.spacingM),
                accessory,
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: primaryCard),
              if (secondaryContext != null) ...[
                SizedBox(width: spacing.spacingM),
                Expanded(child: secondaryContext!),
              ],
              if (settingsAction != null) ...[
                SizedBox(width: spacing.spacingM),
                Align(child: settingsAction!),
              ],
            ],
          ),
        );
      },
    );
  }

  static String? _normalizeText(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}
