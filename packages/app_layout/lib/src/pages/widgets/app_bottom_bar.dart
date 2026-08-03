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

        return Material(
          color: Colors.white,
          elevation: 12,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 2),
            child: SizedBox(
              height: 76,
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
                    width: 84,
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
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: active,
      label: tab.semanticLabel ?? tab.label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme(
                  data: IconThemeData(size: 24, color: color),
                  child: active ? tab.selectedIcon : tab.icon,
                ),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
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
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, -15),
                child: Material(
                  color: colors.primary,
                  elevation: 8,
                  shape: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: 58,
                    child: Icon(
                      expanded ? Icons.close_rounded : Icons.add_rounded,
                      size: 30,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.primary,
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
