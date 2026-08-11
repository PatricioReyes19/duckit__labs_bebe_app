import 'package:app_layout/src/bloc/app_layout_bloc.dart';
import 'package:app_layout/src/config/app_layout_tab_config.dart';
import 'package:app_layout/src/config/app_layout_visibility_rule.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'pages.dart';

class AppLayoutView extends StatefulWidget {
  const AppLayoutView({
    required this.child,
    required this.state,
    required this.navigationShell,
    required this.tabs,
    required this.visibilityPolicy,
    required this.defaultTitle,
    required this.onPrimaryActionPressed,
    this.defaultHeaderActions = const <Widget>[],
    super.key,
  });

  final Widget child;
  final GoRouterState state;
  final StatefulNavigationShell navigationShell;
  final List<AppLayoutTabConfig> tabs;
  final AppLayoutVisibilityPolicy visibilityPolicy;
  final String defaultTitle;
  final VoidCallback onPrimaryActionPressed;
  final List<Widget> defaultHeaderActions;

  @override
  State<AppLayoutView> createState() => _AppLayoutViewState();
}

class _AppLayoutViewState extends State<AppLayoutView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppLayoutBloc>().add(
        AppLayoutEvent.started(tabs: widget.tabs),
      );
      _notifyRouteChanged();
    });
  }

  @override
  void didUpdateWidget(covariant AppLayoutView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.uri.toString() != widget.state.uri.toString()) {
      _notifyRouteChanged();
    }
  }

  void _notifyRouteChanged() {
    final location = widget.state.uri.toString();
    context.read<AppLayoutBloc>().add(
      AppLayoutEvent.routeChanged(
        location: location,
        chrome: widget.visibilityPolicy.resolve(location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeChrome = widget.visibilityPolicy.resolve(
      widget.state.uri.toString(),
    );

    return BlocBuilder<AppLayoutBloc, AppLayoutState>(
      builder: (context, layoutState) {
        final layoutTheme = AppLayoutTheme.of(context);
        final showHeader = routeChrome.showHeader && layoutState.showHeader;
        final showBottomBar =
            routeChrome.showBottomBar && layoutState.showBottomBar;

        return Scaffold(
          appBar: showHeader
              ? AppHeader(
                  title: routeChrome.title ?? widget.defaultTitle,
                  leading: routeChrome.leading,
                  actions: routeChrome.actions.isEmpty
                      ? widget.defaultHeaderActions
                      : routeChrome.actions,
                  showBackButton: routeChrome.showBackButton,
                  showBrandMark: routeChrome.showBrandMark,
                  onBackPressed: routeChrome.showBackButton
                      ? _onBackPressed
                      : null,
                )
              : null,
          body: widget.child,
          bottomNavigationBar: showBottomBar
              ? AppBottomBar(
                  navigationShell: widget.navigationShell,
                  tabs: widget.tabs,
                  onPrimaryActionPressed: widget.onPrimaryActionPressed,
                )
              : null,
        );
      },
    );
  }

  void _onBackPressed() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(_parentLocation(widget.state.uri.path));
  }

  String _parentLocation(String path) {
    final segments = Uri.parse(path).pathSegments;
    if (segments.length < 2) {
      return '/home';
    }

    final branchRoot = '/${segments.first}';
    if (_branchRoots.contains(branchRoot)) {
      if (branchRoot == '/family' &&
          segments.length > 2 &&
          _familySectionParents.contains(segments[1])) {
        return '$branchRoot/${segments[1]}';
      }
      return branchRoot;
    }

    return '/${segments.take(segments.length - 1).join('/')}';
  }

  static const _branchRoots = {'/home', '/agenda', '/health', '/family'};
  static const _familySectionParents = {'babies', 'care-circle', 'settings'};
}
