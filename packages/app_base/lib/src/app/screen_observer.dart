import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef ScreenTracked = void Function(String screenName);

class BebeScreenObserver extends NavigatorObserver {
  BebeScreenObserver({
    required ScreenTracked onScreenTracked,
  }) : _onScreenTracked = onScreenTracked;

  final ScreenTracked _onScreenTracked;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _track(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _track(previousRoute);
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name?.trim();
    if (name == null || name.isEmpty) return;

    if (kDebugMode) {
      debugPrint('Tracked screen: $name');
    }

    _onScreenTracked(name);
  }
}
