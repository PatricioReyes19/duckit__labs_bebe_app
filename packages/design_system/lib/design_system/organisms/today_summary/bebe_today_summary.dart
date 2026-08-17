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
    this.contentPadding = EdgeInsets.zero,
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

  /// Insets that scroll with the cards instead of reducing their viewport.
  final EdgeInsetsGeometry contentPadding;

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
          Padding(
            padding: contentPadding,
            child: BebeTitleSection(
              title: title,
              actionLabel: effectiveActionLabel,
              onActionPressed: effectiveAction,
            ),
          ),
          SizedBox(height: spacing.spacingL),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final resolvedPadding = contentPadding.resolve(
                Directionality.of(context),
              );

              final inlineCount = items.length
                  .clamp(1, _maximumInlineItems)
                  .toInt();

              final totalSpacing = spacing.spacingL * (inlineCount - 1);

              final availableWidth =
                  constraints.maxWidth -
                  resolvedPadding.left -
                  resolvedPadding.right -
                  totalSpacing;
              final inlineCardWidth = availableWidth / inlineCount;

              final shouldUseHorizontalList =
                  items.length > _maximumInlineItems ||
                  inlineCardWidth < _minimumInlineCardWidth ||
                  textScale > _maximumInlineTextScale;

              if (shouldUseHorizontalList) {
                return _TodayMetricsHorizontalList(
                  items: items,
                  contentPadding: contentPadding,
                );
              }

              return _TodayMetricsInlineRow(
                items: items,
                contentPadding: contentPadding,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayMetricsInlineRow extends StatelessWidget {
  const _TodayMetricsInlineRow({
    required this.items,
    required this.contentPadding,
  });

  final List<BebeTodayMetricData> items;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Padding(
      padding: contentPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(child: _TodayMetricItem(data: items[index])),
            if (index < items.length - 1) SizedBox(width: spacing.spacingL),
          ],
        ],
      ),
    );
  }
}

class _TodayMetricsHorizontalList extends StatelessWidget {
  const _TodayMetricsHorizontalList({
    required this.items,
    required this.contentPadding,
  });

  final List<BebeTodayMetricData> items;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: contentPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}

class _TodayMetricItem extends StatelessWidget {
  const _TodayMetricItem({required this.data});

  final BebeTodayMetricData data;

  @override
  Widget build(BuildContext context) {
    return BebeCompactMetricCard(
      variant: data.variant,
      label: data.label,
      icon: data.icon,
      value: data.value,
      unit: data.unit,
      supportingText: '${data.lastLabel}: ${data.lastValue}',
      trend: data.actionLabel == null
          ? null
          : _TodayMetricAction(
              label: data.actionLabel!,
              isLoading: data.isActionLoading,
              onPressed: data.onActionPressed,
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

class _TodayMetricAction extends StatelessWidget {
  const _TodayMetricAction({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.stop_rounded, size: 18),
        label: Text(isLoading ? 'Deteniendo…' : label),
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
    );
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
    this.actionLabel,
    this.onActionPressed,
    this.isActionLoading = false,
    this.semanticLabel,
  }) : assert(
         onPressed == null || onActionPressed == null,
         'A metric cannot open details and expose an inline action.',
       );

  final BebeMetricCardVariant variant;
  final String label;
  final String value;
  final String? unit;
  final String lastLabel;
  final String lastValue;
  final Widget icon;
  final VoidCallback? onPressed;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool isActionLoading;
  final String? semanticLabel;
}

/// Loading representation owned by [BebeTodaySummary].
class BebeTodaySummarySkeleton extends StatelessWidget {
  const BebeTodaySummarySkeleton({
    this.itemCount = 3,
    this.contentPadding = EdgeInsets.zero,
    super.key,
  });

  final int itemCount;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.spacingL,
      children: [
        Padding(
          padding: contentPadding,
          child: const BebeSkeleton.line(width: 152, height: 18),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: contentPadding,
          child: Row(
            spacing: spacing.spacingL,
            children: List.generate(
              itemCount,
              (_) => const BebeSkeleton(width: 120, height: 132),
            ),
          ),
        ),
      ],
    );
  }
}
