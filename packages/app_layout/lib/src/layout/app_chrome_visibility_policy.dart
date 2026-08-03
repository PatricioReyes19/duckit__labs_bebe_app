import 'package:flutter/foundation.dart';

import 'app_chrome_visibility.dart';
import 'app_route_visibility_rule.dart';

@immutable
class AppChromeVisibilityPolicy {
  const AppChromeVisibilityPolicy({
    this.rules = const <AppRouteVisibilityRule>[],
    this.defaultVisibility = const AppChromeVisibility.visible(),
  });

  final List<AppRouteVisibilityRule> rules;
  final AppChromeVisibility defaultVisibility;

  AppChromeVisibility resolve(String location) {
    for (final rule in rules) {
      if (rule.matches(location)) {
        return rule.visibility;
      }
    }

    return defaultVisibility;
  }

  bool showBottomNavigationFor(String location) {
    return resolve(location).showBottomNavigation;
  }

  bool showTopNavigationFor(String location) {
    return resolve(location).showTopNavigation;
  }
}
