import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Composiciones',
  type: BebeTimeBlock,
  path: '[Molecules]/Information',
)
Widget bebeTimeBlockCompositions(BuildContext context) {
  return const UseCaseFrame(
    child: Wrap(
      spacing: 32,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        BebeTimeBlock(
          timeLabel: '10:30',
        ),
        BebeTimeBlock(
          timeLabel: '10:30',
          periodLabel: 'AM',
        ),
        BebeTimeBlock(
          dateLabel: 'Vie, 23 may',
          timeLabel: '09:00',
          periodLabel: 'AM',
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Variantes',
  type: BebeTimeBlock,
  path: '[Molecules]/Information',
)
Widget bebeTimeBlockVariants(BuildContext context) {
  return const UseCaseFrame(
    child: Wrap(
      spacing: 32,
      runSpacing: 32,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        _TimeBlockSample(
          label: 'Neutral',
          child: BebeTimeBlock(
            timeLabel: '10:30',
            periodLabel: 'AM',
            variant: BebeTimeBlockVariant.neutral,
          ),
        ),
        _TimeBlockSample(
          label: 'Brand',
          child: BebeTimeBlock(
            timeLabel: '10:30',
            periodLabel: 'AM',
            variant: BebeTimeBlockVariant.brand,
          ),
        ),
        _TimeBlockSample(
          label: 'Accent',
          child: BebeTimeBlock(
            timeLabel: '10:30',
            periodLabel: 'AM',
            variant: BebeTimeBlockVariant.accent,
          ),
        ),
        _TimeBlockSample(
          label: 'Información',
          child: BebeTimeBlock(
            timeLabel: '10:30',
            periodLabel: 'AM',
            variant: BebeTimeBlockVariant.information,
          ),
        ),
        _TimeBlockSample(
          label: 'Advertencia',
          child: BebeTimeBlock(
            timeLabel: '10:30',
            periodLabel: 'AM',
            variant: BebeTimeBlockVariant.warning,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Tamaños y alineación',
  type: BebeTimeBlock,
  path: '[Molecules]/Information',
)
Widget bebeTimeBlockSizes(BuildContext context) {
  return const UseCaseFrame(
    width: 480,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BebeTimeBlock(
            dateLabel: 'Hoy',
            timeLabel: '10:30',
            periodLabel: 'AM',
            size: BebeTimeBlockSize.small,
            alignment: BebeTimeBlockAlignment.start,
          ),
        ),
        Expanded(
          child: BebeTimeBlock(
            dateLabel: 'Hoy',
            timeLabel: '10:30',
            periodLabel: 'AM',
            size: BebeTimeBlockSize.medium,
            alignment: BebeTimeBlockAlignment.center,
          ),
        ),
        Expanded(
          child: BebeTimeBlock(
            dateLabel: 'Hoy',
            timeLabel: '10:30',
            periodLabel: 'AM',
            alignment: BebeTimeBlockAlignment.end,
          ),
        ),
      ],
    ),
  );
}

class _TimeBlockSample extends StatelessWidget {
  const _TimeBlockSample({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(height: spacing.spacingS),
        Text(label),
      ],
    );
  }
}
