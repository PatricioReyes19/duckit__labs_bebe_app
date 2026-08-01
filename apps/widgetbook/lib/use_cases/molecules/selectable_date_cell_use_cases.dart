import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Estados',
  type: BebeSelectableDateCell,
  path: '[Molecules]/Selection',
)
Widget selectableDateCellStates(
  BuildContext context,
) {
  return UseCaseFrame(
    width: 420,
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 72,
          child: BebeSelectableDateCell(
            label: 'Lun',
            value: '19',
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 72,
          child: BebeSelectableDateCell(
            label: 'Mar',
            value: '20',
            isToday: true,
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 72,
          child: BebeSelectableDateCell(
            label: 'Mié',
            value: '21',
            isSelected: true,
            onPressed: () {},
          ),
        ),
        const SizedBox(
          width: 72,
          child: BebeSelectableDateCell(
            label: 'Jue',
            value: '22',
            enabled: false,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Indicadores',
  type: BebeSelectableDateCell,
  path: '[Molecules]/Selection',
)
Widget selectableDateCellIndicators(
  BuildContext context,
) {
  return UseCaseFrame(
    width: 420,
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 72,
          child: BebeSelectableDateCell(
            label: 'Vie',
            value: '23',
            indicators: const [
              BebeIndicatorDot(
                variant: IndicatorDotVariant.brand,
              ),
            ],
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 72,
          child: BebeSelectableDateCell(
            label: 'Sáb',
            value: '24',
            indicators: const [
              BebeIndicatorDot(
                variant: IndicatorDotVariant.brand,
              ),
              BebeIndicatorDot(
                variant: IndicatorDotVariant.accent,
              ),
            ],
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 72,
          child: BebeSelectableDateCell(
            label: 'Dom',
            value: '25',
            isSelected: true,
            indicators: const [
              BebeIndicatorDot(
                variant: IndicatorDotVariant.warning,
              ),
            ],
            onPressed: () {},
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Variantes visuales',
  type: BebeSelectableDateCell,
  path: '[Molecules]/Selection',
)
Widget selectableDateCellVariants(
  BuildContext context,
) {
  return UseCaseFrame(
    width: 420,
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 84,
          child: BebeSelectableDateCell(
            label: 'Neutral',
            value: '19',
            variant: BebeSelectableDateCellVariant.neutral,
            isSelected: true,
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 84,
          child: BebeSelectableDateCell(
            label: 'Brand',
            value: '20',
            variant: BebeSelectableDateCellVariant.brand,
            isSelected: true,
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 84,
          child: BebeSelectableDateCell(
            label: 'Accent',
            value: '21',
            variant: BebeSelectableDateCellVariant.accent,
            isSelected: true,
            onPressed: () {},
          ),
        ),
      ],
    ),
  );
}
