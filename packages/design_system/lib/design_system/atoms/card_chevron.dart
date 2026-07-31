import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeCardChevronVariant { neutral, brand, accent, information }

class BebeCardChevron extends StatelessWidget {
  const BebeCardChevron({
    this.variant = BebeCardChevronVariant.neutral,
    this.semanticLabel,
    super.key,
  });

  final BebeCardChevronVariant variant;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final color = switch (variant) {
      BebeCardChevronVariant.neutral => colors.icons.neutralAlternative,
      BebeCardChevronVariant.brand => colors.icons.brandDefault,
      BebeCardChevronVariant.accent => colors.icons.accentDefault,
      BebeCardChevronVariant.information => colors.icons.infoDefault,
    };

    final icon = Icon(Icons.chevron_right_rounded, size: 24, color: color);

    final label = semanticLabel?.trim();

    if (label == null || label.isEmpty) {
      return ExcludeSemantics(child: icon);
    }

    return Semantics(
      label: label,
      child: ExcludeSemantics(child: icon),
    );
  }
}
