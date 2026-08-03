import 'package:flutter/widgets.dart';

@immutable
class AppLayoutTabConfig {
  const AppLayoutTabConfig({
    required this.id,
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.branchIndex,
    this.enabled = true,
    this.order = 0,
    this.semanticLabel,
  });

  final String id;
  final String label;
  final String route;
  final Widget icon;
  final Widget selectedIcon;
  final int branchIndex;
  final bool enabled;
  final int order;
  final String? semanticLabel;
}
