import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

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

    final content = RadioGroup<BebeThemeModeOption>(
      groupValue: value,
      onChanged: _handleChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadioListTile<BebeThemeModeOption>(
            value: BebeThemeModeOption.system,
            title: Text(systemLabel.trim()),
            contentPadding: EdgeInsets.symmetric(horizontal: spacing.spacingL),
          ),
          RadioListTile<BebeThemeModeOption>(
            value: BebeThemeModeOption.light,
            title: Text(lightLabel.trim()),
            contentPadding: EdgeInsets.symmetric(horizontal: spacing.spacingL),
          ),
          RadioListTile<BebeThemeModeOption>(
            value: BebeThemeModeOption.dark,
            title: Text(darkLabel.trim()),
            contentPadding: EdgeInsets.symmetric(horizontal: spacing.spacingL),
          ),
        ],
      ),
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
