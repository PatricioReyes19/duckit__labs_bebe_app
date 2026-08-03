import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppPrimaryNavigationAction {
  const AppPrimaryNavigationAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.expandedIcon,
    this.isExpanded = false,
    this.isLoading = false,
    this.isOffline = false,
    this.semanticLabel,
  }) : assert(label.length > 0, 'label must not be empty.');

  final String label;
  final Widget icon;
  final Widget? expandedIcon;
  final VoidCallback onPressed;
  final bool isExpanded;
  final bool isLoading;
  final bool isOffline;
  final String? semanticLabel;
}
