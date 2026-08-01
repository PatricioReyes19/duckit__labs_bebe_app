import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Variantes',
  type: BebeIndicatorDot,
  path: '[Atoms]/Indicators',
)
Widget indicatorDotVariants(BuildContext context) {
  return const UseCaseFrame(
    child: Wrap(
      spacing: 24,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _DotSample(
          label: 'Neutral',
          dot: BebeIndicatorDot(
            variant: IndicatorDotVariant.neutral,
          ),
        ),
        _DotSample(
          label: 'Brand',
          dot: BebeIndicatorDot(
            variant: IndicatorDotVariant.brand,
          ),
        ),
        _DotSample(
          label: 'Accent',
          dot: BebeIndicatorDot(
            variant: IndicatorDotVariant.accent,
          ),
        ),
        _DotSample(
          label: 'Información',
          dot: BebeIndicatorDot(
            variant: IndicatorDotVariant.information,
          ),
        ),
        _DotSample(
          label: 'Éxito',
          dot: BebeIndicatorDot(
            variant: IndicatorDotVariant.success,
          ),
        ),
        _DotSample(
          label: 'Advertencia',
          dot: BebeIndicatorDot(
            variant: IndicatorDotVariant.warning,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Tamaños',
  type: BebeIndicatorDot,
  path: '[Atoms]/Indicators',
)
Widget indicatorDotSizes(BuildContext context) {
  return const UseCaseFrame(
    child: Wrap(
      spacing: 24,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _DotSample(
          label: 'Small',
          dot: BebeIndicatorDot(
            variant: IndicatorDotVariant.brand,
            size: IndicatorDotSize.small,
          ),
        ),
        _DotSample(
          label: 'Medium',
          dot: BebeIndicatorDot(
            variant: IndicatorDotVariant.brand,
            size: IndicatorDotSize.medium,
          ),
        ),
      ],
    ),
  );
}

class _DotSample extends StatelessWidget {
  const _DotSample({
    required this.label,
    required this.dot,
  });

  final String label;
  final Widget dot;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
