import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class BebeProgressStep {
  const BebeProgressStep({required this.label, this.semanticLabel});

  final String label;
  final String? semanticLabel;
}

class BebeProgressSteps extends StatelessWidget {
  const BebeProgressSteps({
    required this.steps,
    required this.currentIndex,
    this.onStepPressed,
    this.semanticLabel = 'Progreso del formulario',
    super.key,
  }) : assert(steps.length > 1),
       assert(currentIndex >= 0),
       assert(currentIndex < steps.length);

  final List<BebeProgressStep> steps;
  final int currentIndex;
  final ValueChanged<int>? onStepPressed;
  final String semanticLabel;

  static const double _verticalBreakpoint = 320;
  static const double _maximumHorizontalTextScale = 1.4;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$semanticLabel. Paso ${currentIndex + 1} de ${steps.length}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final useVertical =
              constraints.maxWidth < _verticalBreakpoint ||
              scale > _maximumHorizontalTextScale;

          return useVertical
              ? _VerticalProgressSteps(
                  steps: steps,
                  currentIndex: currentIndex,
                  onStepPressed: onStepPressed,
                )
              : _HorizontalProgressSteps(
                  steps: steps,
                  currentIndex: currentIndex,
                  onStepPressed: onStepPressed,
                );
        },
      ),
    );
  }
}

class _HorizontalProgressSteps extends StatelessWidget {
  const _HorizontalProgressSteps({
    required this.steps,
    required this.currentIndex,
    required this.onStepPressed,
  });

  final List<BebeProgressStep> steps;
  final int currentIndex;
  final ValueChanged<int>? onStepPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final colors = context.theme.colors;

    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < steps.length; index++)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: index == 0
                          ? const SizedBox.shrink()
                          : Divider(
                              thickness: 2,
                              color: index <= currentIndex
                                  ? colors.border.brandDefault
                                  : colors.border.neutralDefault,
                            ),
                    ),
                    _ProgressStepMarker(
                      index: index,
                      total: steps.length,
                      step: steps[index],
                      currentIndex: currentIndex,
                      onPressed: onStepPressed == null
                          ? null
                          : () => onStepPressed!(index),
                    ),
                    Expanded(
                      child: index == steps.length - 1
                          ? const SizedBox.shrink()
                          : Divider(
                              thickness: 2,
                              color: index < currentIndex
                                  ? colors.border.brandDefault
                                  : colors.border.neutralDefault,
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: spacing.spacingS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < steps.length; index++)
              Expanded(
                child: Text(
                  steps[index].label,
                  textAlign: TextAlign.center,
                  style: context.theme.typography.styles.label.sm.semibold
                      .copyWith(
                        color: index == currentIndex
                            ? colors.text.brandDefault
                            : colors.text.neutralBody,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _VerticalProgressSteps extends StatelessWidget {
  const _VerticalProgressSteps({
    required this.steps,
    required this.currentIndex,
    required this.onStepPressed,
  });

  final List<BebeProgressStep> steps;
  final int currentIndex;
  final ValueChanged<int>? onStepPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final colors = context.theme.colors;

    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      _ProgressStepMarker(
                        index: index,
                        total: steps.length,
                        step: steps[index],
                        currentIndex: currentIndex,
                        onPressed: onStepPressed == null
                            ? null
                            : () => onStepPressed!(index),
                      ),
                      if (index != steps.length - 1)
                        Expanded(
                          child: VerticalDivider(
                            thickness: 2,
                            color: index < currentIndex
                                ? colors.border.brandDefault
                                : colors.border.neutralDefault,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.spacingM),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: spacing.spacingM,
                      bottom: spacing.spacingXl,
                    ),
                    child: Text(
                      steps[index].label,
                      style: context.theme.typography.styles.label.md.semibold
                          .copyWith(
                            color: index == currentIndex
                                ? colors.text.brandDefault
                                : colors.text.neutralBody,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ProgressStepMarker extends StatelessWidget {
  const _ProgressStepMarker({
    required this.index,
    required this.total,
    required this.step,
    required this.currentIndex,
    required this.onPressed,
  });

  final int index;
  final int total;
  final BebeProgressStep step;
  final int currentIndex;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final isComplete = index < currentIndex;
    final isCurrent = index == currentIndex;
    final status = isComplete
        ? 'completado'
        : isCurrent
        ? 'actual'
        : 'pendiente';
    final label =
        step.semanticLabel ??
        'Paso ${index + 1} de $total, ${step.label}, $status';
    final foreground = isComplete || isCurrent
        ? colors.onPrimary.neutralDefault
        : colors.text.neutralBody;
    final background = isComplete || isCurrent
        ? colors.background.brandDefault
        : colors.background.neutralsSurface;

    final marker = Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCurrent || isComplete
                ? colors.border.brandDefault
                : colors.border.neutralDefault,
          ),
        ),
        alignment: Alignment.center,
        child: isComplete
            ? Icon(Icons.check_rounded, size: 18, color: foreground)
            : Text(
                '${index + 1}',
                style: theme.typography.styles.label.sm.bold.copyWith(
                  color: foreground,
                ),
              ),
      ),
    );

    return Semantics(
      button: onPressed != null,
      selected: isCurrent,
      label: label,
      child: SizedBox.square(
        dimension: 48,
        child: onPressed == null
            ? ExcludeSemantics(child: marker)
            : InkResponse(
                onTap: onPressed,
                radius: 24,
                child: ExcludeSemantics(child: marker),
              ),
      ),
    );
  }
}
