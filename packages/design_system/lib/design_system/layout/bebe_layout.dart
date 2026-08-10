import 'package:flutter/foundation.dart';

abstract final class BebeLayout {
  static const double compactBreakpoint = 360;
  static const double mediumBreakpoint = 600;
  static const double expandedBreakpoint = 960;

  static const double compactContentMaxWidth = 520;
  static const double formContentMaxWidth = 720;
  static const double pageContentMaxWidth = 960;
}

@immutable
class BebeAdaptiveGridMetrics {
  const BebeAdaptiveGridMetrics({
    required this.columns,
    required this.itemWidth,
  });

  final int columns;
  final double itemWidth;
}
