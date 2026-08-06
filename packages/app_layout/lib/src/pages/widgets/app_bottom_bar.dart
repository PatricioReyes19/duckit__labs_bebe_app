import 'package:app_layout/src/app_layout_theme.dart';
import 'package:app_layout/src/bloc/app_layout_bloc.dart';
import 'package:app_layout/src/config/app_layout_tab_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.navigationShell,
    required this.tabs,
    required this.onPrimaryActionPressed,
    this.primaryActionLabel = 'Registrar',
    super.key,
  }) : assert(tabs.length == 4);

  final StatefulNavigationShell navigationShell;
  final List<AppLayoutTabConfig> tabs;
  final VoidCallback onPrimaryActionPressed;
  final String primaryActionLabel;

  static const double _baseHeight = 80;
  static const double _maximumAccessibleHeight = 96;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLayoutBloc, AppLayoutState>(
      builder: (context, state) {
        final enabledTabs = state.tabs.isEmpty
            ? (tabs.where((tab) => tab.enabled).toList()
                ..sort((a, b) => a.order.compareTo(b.order)))
            : state.tabs;

        if (enabledTabs.length != 4) {
          return const SizedBox.shrink();
        }

        final left = enabledTabs.take(2).toList();
        final right = enabledTabs.skip(2).toList();
        final layoutTheme = AppLayoutTheme.of(context);
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final barHeight = (_baseHeight + (textScale - 1) * 16).clamp(
          _baseHeight,
          _maximumAccessibleHeight,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: layoutTheme.surfaceColor,
            border: Border(top: BorderSide(color: layoutTheme.borderColor)),
            boxShadow: [
              BoxShadow(
                color: layoutTheme.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 2),
            child: SizedBox(
              height: barHeight,
              child: Row(
                children: [
                  for (final tab in left)
                    Expanded(
                      child: _Item(
                        tab: tab,
                        active:
                            enabledTabs.indexOf(tab) ==
                            state.activeDisplayIndex,
                        onTap: () =>
                            _onTabTap(context, tab, enabledTabs.indexOf(tab)),
                      ),
                    ),
                  SizedBox(
                    width: 80,
                    child: state.showPrimaryAction
                        ? _PrimaryAction(
                            label: primaryActionLabel,
                            expanded: state.primaryActionExpanded,
                            onTap: onPrimaryActionPressed,
                          )
                        : null,
                  ),
                  for (final tab in right)
                    Expanded(
                      child: _Item(
                        tab: tab,
                        active:
                            enabledTabs.indexOf(tab) ==
                            state.activeDisplayIndex,
                        onTap: () =>
                            _onTabTap(context, tab, enabledTabs.indexOf(tab)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTabTap(
    BuildContext context,
    AppLayoutTabConfig tab,
    int displayIndex,
  ) {
    final bloc = context.read<AppLayoutBloc>();

    final currentPath = _normalize(
      navigationShell.shellRouteContext.routerState.uri.toString(),
    );

    final rootPath = _normalize(tab.route);
    final isCurrent = bloc.state.activeDisplayIndex == displayIndex;

    if (isCurrent) {
      if (currentPath == rootPath) {
        bloc.add(AppLayoutEvent.scrollToTop(tabId: tab.id));
      } else {
        context.go(tab.route);
      }
      return;
    }

    bloc.add(
      AppLayoutEvent.tabChanged(
        displayIndex: displayIndex,
        branchIndex: tab.branchIndex,
        tabId: tab.id,
      ),
    );

    navigationShell.goBranch(
      tab.branchIndex,
      initialLocation: tab.branchIndex == navigationShell.currentIndex,
    );
  }

  String _normalize(String value) {
    var path = Uri.tryParse(value)?.path ?? value;

    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.tab, required this.active, required this.onTap});

  final AppLayoutTabConfig tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final layoutTheme = AppLayoutTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    final contentColor = active
        ? layoutTheme.selectedColor
        : layoutTheme.unselectedColor;

    return Semantics(
      button: true,
      selected: active,
      label: tab.semanticLabel ?? tab.label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? layoutTheme.selectedContainerColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: IconTheme(
                    data: IconThemeData(size: 24, color: contentColor),
                    child: active ? tab.selectedIcon : tab.icon,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: active
                        ? layoutTheme.selectedColor
                        : layoutTheme.unselectedColor,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
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

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final layoutTheme = AppLayoutTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, -16),
                child: Material(
                  color: layoutTheme.primaryActionColor,
                  elevation: 7,
                  shadowColor: layoutTheme.primaryActionShadowColor,
                  shape: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: 60,
                    child: Icon(
                      expanded ? Icons.close_rounded : Icons.add_rounded,
                      size: 31,
                      color: layoutTheme.primaryActionForegroundColor,
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Text(
                  label,
                  maxLines: 1,
                  style: textTheme.labelSmall?.copyWith(
                    color: layoutTheme.unselectedColor,
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
