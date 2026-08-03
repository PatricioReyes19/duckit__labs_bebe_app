import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'bebe_theme_mode_option.dart';

class BebeThemeModeSelector extends StatelessWidget {
  const BebeThemeModeSelector({
    required this.value,
    required this.onChanged,
    required this.systemLabel,
    required this.lightLabel,
    required this.darkLabel,
    this.semanticLabel,
    super.key,
  });
  final BebeThemeModeOption value;
  final ValueChanged<BebeThemeModeOption> onChanged;
  final String systemLabel;
  final String lightLabel;
  final String darkLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RadioListTile<BebeThemeModeOption>(
          value: BebeThemeModeOption.system,
          groupValue: value,
          onChanged: _handleChanged,
          title: Text(systemLabel.trim()),
          contentPadding: EdgeInsets.symmetric(horizontal: spacing.spacingL),
        ),
        RadioListTile<BebeThemeModeOption>(
          value: BebeThemeModeOption.light,
          groupValue: value,
          onChanged: _handleChanged,
          title: Text(lightLabel.trim()),
          contentPadding: EdgeInsets.symmetric(horizontal: spacing.spacingL),
        ),
        RadioListTile<BebeThemeModeOption>(
          value: BebeThemeModeOption.dark,
          groupValue: value,
          onChanged: _handleChanged,
          title: Text(darkLabel.trim()),
          contentPadding: EdgeInsets.symmetric(horizontal: spacing.spacingL),
        ),
      ],
    );

    final normalizedLabel = semanticLabel?.trim();

    if (normalizedLabel == null || normalizedLabel.isEmpty) {
      return content;
    }

    return Semantics(container: true, label: normalizedLabel, child: content);
  }

  void _handleChanged(BebeThemeModeOption? next) {
    if (next != null) {
      onChanged(next);
    }
  }
}
