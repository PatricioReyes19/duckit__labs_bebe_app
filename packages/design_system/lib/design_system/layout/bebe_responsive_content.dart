import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Centers page content and prevents unbounded growth on large viewports.
class BebeResponsiveContent extends StatelessWidget {
  const BebeResponsiveContent({
    required this.child,
    this.maxWidth = BebeLayout.pageContentMaxWidth,
    this.alignment = Alignment.topCenter,
    super.key,
  }) : assert(maxWidth > 0);

  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
