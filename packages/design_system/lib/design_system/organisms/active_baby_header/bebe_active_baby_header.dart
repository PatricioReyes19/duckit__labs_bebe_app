import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeSiblingSummaryData {
  const BebeSiblingSummaryData({
    required this.name,
    required this.ageLabel,
    required this.avatar,
    this.semanticLabel,
  });

  final String name;
  final String ageLabel;
  final ImageProvider avatar;
  final String? semanticLabel;
}

class BebeActiveBabyHeader extends StatelessWidget {
  const BebeActiveBabyHeader({
    required this.name,
    required this.ageLabel,
    required this.avatar,
    required this.familyContextLabel,
    this.siblings = const <BebeSiblingSummaryData>[],
    this.onBabyPressed,
    this.onSiblingPressed,
    this.semanticLabel,
    super.key,
  });

  final String name;
  final String ageLabel;
  final ImageProvider avatar;
  final String familyContextLabel;

  final List<BebeSiblingSummaryData> siblings;

  final VoidCallback? onBabyPressed;
  final ValueChanged<BebeSiblingSummaryData>? onSiblingPressed;
  final String? semanticLabel;

  static const double _minimumInlineWidth = 312;
  static const double _minimumActiveWidth = 196;
  static const double _compactCardWidth = 112;
  static const double _compactCardBaseHeight = 105;
  static const double _maximumInlineTextScale = 1.3;
  static const double _maximumRailWidthFactor = 0.40;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    final activeSelector = BebeBabySelector(
      name: name,
      ageLabel: ageLabel,
      avatar: BebeAvatar.image(
        image: avatar,
        size: BebeAvatarSize.lg,
        semanticLabel: 'Foto de $name',
        borderColor: colors.border.brandDefault,
      ),
      contextLabel: familyContextLabel,
      isSelected: true,
      onPressed: onBabyPressed,
      semanticLabel: semanticLabel,
    );

    if (siblings.isEmpty) {
      return SizedBox(width: double.infinity, child: activeSelector);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final useStackedLayout =
            constraints.maxWidth < _minimumInlineWidth ||
            textScale > _maximumInlineTextScale;

        final compactHeight = _compactHeightFor(textScale);

        if (useStackedLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              activeSelector,
              SizedBox(height: spacing.spacingM),
              SizedBox(
                height: compactHeight,
                child: _SiblingRail(
                  siblings: siblings,
                  itemWidth: _compactCardWidth,
                  onSiblingPressed: onSiblingPressed,
                ),
              ),
            ],
          );
        }

        final siblingRailWidth = _resolveSiblingRailWidth(
          maxWidth: constraints.maxWidth,
          spacing: spacing.spacingM,
        );

        return SizedBox(
          width: double.infinity,
          height: math.max(_compactCardBaseHeight, compactHeight),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: activeSelector),
              SizedBox(width: spacing.spacingM),
              SizedBox(
                width: siblingRailWidth,
                child: _SiblingRail(
                  siblings: siblings,
                  itemWidth: _compactCardWidth,
                  onSiblingPressed: onSiblingPressed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _resolveSiblingRailWidth({
    required double maxWidth,
    required double spacing,
  }) {
    final totalContentWidth =
        siblings.length * _compactCardWidth +
        math.max(0, siblings.length - 1) * spacing;

    final availableWidth = math.max(
      _compactCardWidth,
      maxWidth - _minimumActiveWidth - spacing,
    );

    final preferredWidth = math.min(
      totalContentWidth,
      maxWidth * _maximumRailWidthFactor,
    );

    return preferredWidth.clamp(_compactCardWidth, availableWidth);
  }

  double _compactHeightFor(double textScale) {
    final normalizedScale = textScale.clamp(1.0, 1.6);
    return _compactCardBaseHeight + ((normalizedScale - 1) * 24);
  }
}

class _SiblingRail extends StatelessWidget {
  const _SiblingRail({
    required this.siblings,
    required this.itemWidth,
    required this.onSiblingPressed,
  });

  final List<BebeSiblingSummaryData> siblings;
  final double itemWidth;
  final ValueChanged<BebeSiblingSummaryData>? onSiblingPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Semantics(
      container: true,
      label: 'Otros bebés de la familia',
      explicitChildNodes: true,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        primary: false,
        padding: EdgeInsets.zero,
        itemCount: siblings.length,
        separatorBuilder: (_, _) => SizedBox(width: spacing.spacingM),
        itemBuilder: (context, index) {
          final sibling = siblings[index];

          return SizedBox(
            width: itemWidth,
            child: _BebeCompactSiblingSelector(
              data: sibling,
              onPressed: onSiblingPressed == null
                  ? null
                  : () => onSiblingPressed!(sibling),
            ),
          );
        },
      ),
    );
  }
}

class _BebeCompactSiblingSelector extends StatelessWidget {
  const _BebeCompactSiblingSelector({required this.data, this.onPressed});

  final BebeSiblingSummaryData data;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final overlays = theme.overlays;
    final typography = theme.typography;

    final card = Material(
      color: colors.background.accentSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: BorderSide(color: colors.border.accentAlternative),
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.spacingM,
            vertical: spacing.spacingS,
          ),
          child: Row(
            children: [
              BebeAvatar.image(
                image: data.avatar,
                size: BebeAvatarSize.md,
                semanticLabel: 'Foto de ${data.name}',
                borderColor: colors.border.accentDefault,
              ),
              SizedBox(width: spacing.spacingS),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.styles.body.sm.regular.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.text.neutralTitle,
                      ),
                    ),
                    SizedBox(height: spacing.spacingS),
                    Text(
                      data.ageLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.styles.body.sm.regular.copyWith(
                        color: colors.text.accentDefault,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: onPressed != null,
      enabled: onPressed != null,
      selected: false,
      label:
          data.semanticLabel ??
          '${data.name}, ${data.ageLabel}. Cambiar a este bebé',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.radius3xl),
          boxShadow: elevation.low,
        ),
        child: card,
      ),
    );
  }
}
