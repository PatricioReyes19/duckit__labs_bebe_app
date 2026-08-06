import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeMetadataItemVariant {
  neutral,
  brand,
  accent,
  information,
  warning,
  success,
}

enum BebeMetadataItemSize { small, medium }

class BebeMetadataItem extends StatelessWidget {
  const BebeMetadataItem({
    required this.icon,
    required this.label,
    this.variant = BebeMetadataItemVariant.neutral,
    this.size = BebeMetadataItemSize.small,
    this.maxLines,
    this.semanticLabel,
    super.key,
  });

  final Widget icon;
  final String label;
  final BebeMetadataItemVariant variant;
  final BebeMetadataItemSize size;
  final int? maxLines;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;

    final contentColor = _resolveContentColor(theme.colors, variant);

    final iconSize = switch (size) {
      BebeMetadataItemSize.small => 16.0,
      BebeMetadataItemSize.medium => 20.0,
    };

    final textStyle = switch (size) {
      BebeMetadataItemSize.small => typography.styles.caption.md.regular,
      BebeMetadataItemSize.medium => typography.styles.body.sm.regular,
    };

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme(
          data: IconThemeData(color: contentColor, size: iconSize),
          child: icon,
        ),
        SizedBox(width: spacing.spacingS),
        Flexible(
          child: Text(
            label,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
            style: textStyle.copyWith(color: contentColor),
          ),
        ),
      ],
    );

    return Semantics(
      label: semanticLabel ?? label,
      child: ExcludeSemantics(child: content),
    );
  }

  Color _resolveContentColor(
    BebeColor colors,
    BebeMetadataItemVariant variant,
  ) {
    return switch (variant) {
      BebeMetadataItemVariant.neutral => colors.text.neutralBody,
      BebeMetadataItemVariant.brand => colors.text.brandDefault,
      BebeMetadataItemVariant.accent => colors.text.accentDefault,
      BebeMetadataItemVariant.information => colors.text.infoDefault,
      BebeMetadataItemVariant.warning => colors.text.warningDefault,
      BebeMetadataItemVariant.success => colors.text.successDefault,
    };
  }
}
