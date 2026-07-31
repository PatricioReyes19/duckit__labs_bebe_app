import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../atoms/avatar/bebe_avatar.dart';
import '../../molecules/baby_selector/bebe_baby_selector.dart';

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
    this.sibling,
    this.onBabyPressed,
    this.onSiblingPressed,
    this.semanticLabel,
    super.key,
  });

  final String name;
  final String ageLabel;
  final ImageProvider avatar;
  final String familyContextLabel;
  final BebeSiblingSummaryData? sibling;
  final VoidCallback? onBabyPressed;
  final VoidCallback? onSiblingPressed;
  final String? semanticLabel;

  static const int _activeFlex = 68;
  static const int _siblingFlex = 32;

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
        borderColor: colors.border.accentDefault,
      ),
      contextLabel: familyContextLabel,
      isSelected: true,
      onPressed: onBabyPressed,
      semanticLabel: semanticLabel,
    );

    final siblingData = sibling;

    if (siblingData == null) {
      return SizedBox(width: double.infinity, child: activeSelector);
    }

    final siblingSelector = BebeBabySelector(
      name: siblingData.name,
      ageLabel: siblingData.ageLabel,
      avatar: BebeAvatar.image(
        image: siblingData.avatar,
        size: BebeAvatarSize.lg,
        semanticLabel: 'Foto de ${siblingData.name}',
        borderColor: colors.border.brandDefault,
      ),
      isSelected: false,
      onPressed: onSiblingPressed,
      semanticLabel: siblingData.semanticLabel,
    );

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: _activeFlex, child: activeSelector),
          SizedBox(width: spacing.spacingM),
          Expanded(flex: _siblingFlex, child: siblingSelector),
        ],
      ),
    );
  }
}
