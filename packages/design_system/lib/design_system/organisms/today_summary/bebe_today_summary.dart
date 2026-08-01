import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeTodayMetricData {
  const BebeTodayMetricData({
    required this.type,
    required this.label,
    required this.value,
    required this.unit,
    required this.lastLabel,
    required this.lastValue,
    required this.icon,
    this.semanticLabel,
  });

  final BebeTodayMetricType type;
  final String label;
  final String value;
  final String unit;
  final String lastLabel;
  final String lastValue;
  final Widget icon;
  final String? semanticLabel;
}

class BebeTodaySummary extends StatelessWidget {
  const BebeTodaySummary({
    required this.items,
    this.title = 'Resumen de hoy',
    this.actionLabel = 'Ver más',
    this.onViewMorePressed,
    super.key,
  });

  final List<BebeTodayMetricData> items;
  final String title;
  final String actionLabel;
  final VoidCallback? onViewMorePressed;

  static const int _maximumInlineItems = 3;
  static const double _minimumInlineCardWidth = 96;
  static const double _carouselCardWidth = 116;
  static const double _carouselHeight = 168;

  @override
  Widget build(BuildContext context) {
    assert(items.isNotEmpty, 'BebeTodaySummary requires at least one item.');

    final spacing = context.theme.spacing;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BebeTitleSection(
            title: title,
            actionLabel: actionLabel,
            onActionPressed: onViewMorePressed,
          ),
          SizedBox(height: spacing.spacingXl),
          LayoutBuilder(
            builder: (context, constraints) {
              final inlineCount = items.length.clamp(1, _maximumInlineItems);

              final totalGap = spacing.spacingL * (inlineCount - 1);

              final availableWidth = constraints.maxWidth - totalGap;

              final inlineCardWidth = availableWidth / inlineCount;

              final shouldUseCarousel =
                  items.length > _maximumInlineItems ||
                  inlineCardWidth < _minimumInlineCardWidth;

              if (shouldUseCarousel) {
                return _TodayMetricsCarousel(items: items);
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    Expanded(child: _buildMetricCard(items[index])),
                    if (index < items.length - 1)
                      SizedBox(width: spacing.spacingL),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BebeTodayMetricData item) {
    return BebeMetricCard(
      variant: _mapVariant(item.type),
      label: item.label,
      value: item.value,
      unit: item.unit,
      supportingLabel: item.lastLabel,
      supportingValue: item.lastValue,
      icon: item.icon,
      semanticLabel: item.semanticLabel,
    );
  }

  BebeMetricCardVariant _mapVariant(BebeTodayMetricType type) {
    return switch (type) {
      BebeTodayMetricType.feeding => BebeMetricCardVariant.feeding,
      BebeTodayMetricType.sleep => BebeMetricCardVariant.sleep,
      BebeTodayMetricType.diaper => BebeMetricCardVariant.diaper,
    };
  }
}

class _TodayMetricsCarousel extends StatelessWidget {
  const _TodayMetricsCarousel({required this.items});

  final List<BebeTodayMetricData> items;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return SizedBox(
      height: BebeTodaySummary._carouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) {
          return SizedBox(width: spacing.spacingL);
        },
        itemBuilder: (context, index) {
          final item = items[index];

          return SizedBox(
            width: BebeTodaySummary._carouselCardWidth,
            child: BebeMetricCard(
              variant: _mapVariant(item.type),
              label: item.label,
              value: item.value,
              unit: item.unit,
              supportingLabel: item.lastLabel,
              supportingValue: item.lastValue,
              icon: item.icon,
              semanticLabel: item.semanticLabel,
            ),
          );
        },
      ),
    );
  }

  BebeMetricCardVariant _mapVariant(BebeTodayMetricType type) {
    return switch (type) {
      BebeTodayMetricType.feeding => BebeMetricCardVariant.feeding,
      BebeTodayMetricType.sleep => BebeMetricCardVariant.sleep,
      BebeTodayMetricType.diaper => BebeMetricCardVariant.diaper,
    };
  }
}
