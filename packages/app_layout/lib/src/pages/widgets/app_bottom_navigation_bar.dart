import 'package:app_layout/src/app_layout_theme.dart';
import 'package:flutter/material.dart';

import 'app_bottom_navigation_destination.dart';
import 'app_primary_navigation_action.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.destinations,
    required this.selectedBranchIndex,
    required this.onDestinationSelected,
    required this.primaryAction,
    this.height = 76,
    this.primaryActionSize = 58,
    super.key,
  }) : assert(
         destinations.length == 4,
         'The centered mobile layout requires exactly four destinations.',
       ),
       assert(height >= 64, 'height must be at least 64.'),
       assert(
         primaryActionSize >= 48,
         'primaryActionSize must be at least 48.',
       );

  final List<AppBottomNavigationDestination> destinations;
  final int selectedBranchIndex;
  final ValueChanged<int> onDestinationSelected;
  final AppPrimaryNavigationAction primaryAction;
  final double height;
  final double primaryActionSize;

  @override
  Widget build(BuildContext context) {
    final layoutTheme = AppLayoutTheme.of(context);
    final leftDestinations = destinations.take(2);
    final rightDestinations = destinations.skip(2);

    return Material(
      color: layoutTheme.surfaceColor,
      elevation: 12,
      shadowColor: layoutTheme.shadowColor,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 2),
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final destination in leftDestinations)
                Expanded(
                  child: _NavigationItem(
                    destination: destination,
                    isSelected: destination.branchIndex == selectedBranchIndex,
                    selectedColor: layoutTheme.selectedColor,
                    unselectedColor: layoutTheme.unselectedColor,
                    onPressed: () {
                      onDestinationSelected(destination.branchIndex);
                    },
                  ),
                ),
              SizedBox(
                width: 84,
                child: _PrimaryActionItem(
                  action: primaryAction,
                  size: primaryActionSize,
                  backgroundColor: layoutTheme.primaryActionColor,
                  foregroundColor: layoutTheme.primaryActionForegroundColor,
                  errorColor: layoutTheme.errorColor,
                ),
              ),
              for (final destination in rightDestinations)
                Expanded(
                  child: _NavigationItem(
                    destination: destination,
                    isSelected: destination.branchIndex == selectedBranchIndex,
                    selectedColor: layoutTheme.selectedColor,
                    unselectedColor: layoutTheme.unselectedColor,
                    onPressed: () {
                      onDestinationSelected(destination.branchIndex);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onPressed,
  });

  final AppBottomNavigationDestination destination;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.semanticLabel ?? destination.label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme(
                  data: IconThemeData(color: color, size: 24),
                  child: isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                ),
                const SizedBox(height: 4),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionItem extends StatelessWidget {
  const _PrimaryActionItem({
    required this.action,
    required this.size,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.errorColor,
  });

  final AppPrimaryNavigationAction action;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color errorColor;

  @override
  Widget build(BuildContext context) {
    final icon = action.isExpanded
        ? action.expandedIcon ?? const Icon(Icons.close_rounded)
        : action.icon;

    return Semantics(
      button: true,
      enabled: !action.isLoading,
      label: action.semanticLabel ?? action.label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: action.isLoading ? null : action.onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, -15),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      color: backgroundColor,
                      elevation: 8,
                      shape: const CircleBorder(),
                      child: SizedBox.square(
                        dimension: size,
                        child: Center(
                          child: action.isLoading
                              ? SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: foregroundColor,
                                  ),
                                )
                              : IconTheme(
                                  data: IconThemeData(
                                    size: 30,
                                    color: foregroundColor,
                                  ),
                                  child: icon,
                                ),
                        ),
                      ),
                    ),
                    if (action.isOffline)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Material(
                          color: Colors.white,
                          elevation: 2,
                          shape: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.cloud_off_outlined,
                              size: 14,
                              color: errorColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: backgroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
