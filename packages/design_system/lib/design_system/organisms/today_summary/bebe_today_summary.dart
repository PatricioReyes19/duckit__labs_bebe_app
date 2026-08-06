import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeTodaySummary extends StatelessWidget {
  const BebeTodaySummary({
    required this.items,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
    this.historyActionLabel = 'Ver historial',
    this.onHistoryPressed,
    super.key,
  }) : assert(
         onActionPressed == null || onHistoryPressed == null,
         'Use onHistoryPressed or onActionPressed, not both.',
       );

  final List<BebeTodayMetricData> items;
  final String title;

  /// Texto de la acción opcional del encabezado.
  ///
  /// Debe proporcionarse junto con [onActionPressed].
  final String? actionLabel;

  /// Acción opcional del encabezado.
  ///
  /// Debe proporcionarse junto con [actionLabel].
  final VoidCallback? onActionPressed;

  /// Acción específica para abrir el detalle completo del día.
  ///
  /// La feature mantiene el control de la navegación mediante este callback.
  final VoidCallback? onHistoryPressed;

  /// Etiqueta mostrada cuando [onHistoryPressed] está disponible.
  final String historyActionLabel;

  static const int _maximumInlineItems = 3;

  /// Ancho mínimo que necesita una métrica para conservar el layout inline.
  // Mantiene las tres métricas visibles en los anchos móviles de referencia
  // (375–430 px) y cambia a carrusel en pantallas realmente estrechas.
  static const double _minimumInlineCardWidth = 96;

  /// Ancho estructural utilizado por las cards de la lista horizontal.
  static const double _horizontalCardWidth = 120;

  /// Altura reservada para el patrón compacto de Today Summary.
  static const double _maximumInlineTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final effectiveAction = onHistoryPressed ?? onActionPressed;
    final effectiveActionLabel = onHistoryPressed != null
        ? historyActionLabel
        : actionLabel ?? (onActionPressed == null ? null : historyActionLabel);

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(
            title: title,
            actionLabel: effectiveActionLabel,
            onActionPressed: effectiveAction,
          ),
          SizedBox(height: spacing.spacingL),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);

              final inlineCount = items.length
                  .clamp(1, _maximumInlineItems)
                  .toInt();

              final totalSpacing = spacing.spacingL * (inlineCount - 1);

              final availableWidth = constraints.maxWidth - totalSpacing;
              final inlineCardWidth = availableWidth / inlineCount;

              final shouldUseHorizontalList =
                  items.length > _maximumInlineItems ||
                  inlineCardWidth < _minimumInlineCardWidth ||
                  textScale > _maximumInlineTextScale;

              if (shouldUseHorizontalList) {
                return _TodayMetricsHorizontalList(items: items);
              }

              return _TodayMetricsInlineRow(items: items);
            },
          ),
        ],
      ),
    );
  }
}

class _TodayMetricsInlineRow extends StatelessWidget {
  const _TodayMetricsInlineRow({required this.items});

  final List<BebeTodayMetricData> items;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              SizedBox(
                width: BebeTodaySummary._horizontalCardWidth,
                child: _TodayMetricItem(data: items[index]),
              ),
              if (index < items.length - 1) SizedBox(width: spacing.spacingL),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayMetricsHorizontalList extends StatelessWidget {
  const _TodayMetricsHorizontalList({required this.items});

  final List<BebeTodayMetricData> items;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              SizedBox(
                width: BebeTodaySummary._horizontalCardWidth,
                child: _TodayMetricItem(data: items[index]),
              ),
              if (index < items.length - 1) SizedBox(width: spacing.spacingL),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayMetricItem extends StatelessWidget {
  const _TodayMetricItem({required this.data});

  final BebeTodayMetricData data;

  @override
  Widget build(BuildContext context) {
    return BebeMetricCard(
      variant: data.variant,
      label: data.label,
      icon: data.icon,
      value: data.value,
      unit: data.unit,
      supporting: _TodayMetricSupporting(
        variant: data.variant,
        label: data.lastLabel,
        value: data.lastValue,
      ),
      onPressed: data.onPressed,
      semanticLabel:
          data.semanticLabel ??
          '${data.label}. '
              '${data.value}'
              '${data.unit == null ? '' : ' ${data.unit}'}. '
              '${data.lastLabel}. '
              '${data.lastValue}.',
    );
  }
}

class _TodayMetricSupporting extends StatelessWidget {
  const _TodayMetricSupporting({
    required this.variant,
    required this.label,
    required this.value,
  });

  final BebeMetricCardVariant variant;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final colors = theme.colors;

    final contentColor = _resolveContentColor(colors);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.styles.body.sm.regular.copyWith(
            color: colors.text.neutralBody,
          ),
        ),
        SizedBox(height: spacing.spacingXs),
        Text(
          value,
          style: typography.styles.label.lg.semibold.copyWith(
            color: contentColor,
          ),
        ),
      ],
    );
  }

  Color _resolveContentColor(BebeColor colors) {
    return switch (variant) {
      BebeMetricCardVariant.feeding ||
      BebeMetricCardVariant.brand => colors.text.brandDefault,

      BebeMetricCardVariant.sleep ||
      BebeMetricCardVariant.accent => colors.text.accentDefault,

      BebeMetricCardVariant.diaper ||
      BebeMetricCardVariant.warning => colors.text.warningDefault,

      BebeMetricCardVariant.neutral => colors.text.neutralTitle,

      BebeMetricCardVariant.information => colors.text.infoDefault,

      BebeMetricCardVariant.success => colors.text.successDefault,
    };
  }
}

/// Modelo visual utilizado por [BebeTodaySummary].
///
/// Representa una métrica breve del día actual. No contiene entidades,
/// reglas de negocio, navegación ni estado de la feature.
class BebeTodayMetricData {
  const BebeTodayMetricData({
    required this.variant,
    required this.label,
    required this.value,
    required this.lastLabel,
    required this.lastValue,
    required this.icon,
    this.unit,
    this.onPressed,
    this.semanticLabel,
  });

  final BebeMetricCardVariant variant;
  final String label;
  final String value;
  final String? unit;
  final String lastLabel;
  final String lastValue;
  final Widget icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
}
