import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppBottomNavigationDestination {
  const AppBottomNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.branchIndex,
    this.semanticLabel,
  }) : assert(label.length > 0, 'label must not be empty.'),
       assert(branchIndex >= 0, 'branchIndex must not be negative.');

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final int branchIndex;
  final String? semanticLabel;
}
