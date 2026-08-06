import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Standard multi-line field for notes and observations.
class BebeNotesField extends StatelessWidget {
  const BebeNotesField({
    required this.label,
    this.controller,
    this.hintText = 'Escribe algo…',
    this.maxLength = 200,
    this.compact = false,
    this.optional = true,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String hintText;
  final int maxLength;
  final bool compact;
  final bool optional;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return BebeFormField(
      label: label,
      optional: optional,
      compactLabel: compact,
      child: BebeTextField(
        controller: controller,
        hintText: hintText,
        minLines: compact ? 2 : 3,
        maxLines: compact ? 4 : 5,
        maxLength: maxLength,
        dense: compact,
        enabled: enabled,
        errorText: errorText,
        onChanged: onChanged,
        semanticLabel: semanticLabel ?? label,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
