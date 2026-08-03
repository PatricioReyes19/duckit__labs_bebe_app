import 'package:flutter/foundation.dart';
import 'app_layout_chrome_config.dart';

enum AppLayoutRouteMatchType { exact, prefix }

@immutable
class AppLayoutVisibilityRule {
  const AppLayoutVisibilityRule({
    required this.path,
    required this.chrome,
    this.matchType = AppLayoutRouteMatchType.exact,
  });

  const AppLayoutVisibilityRule.exact({
    required String path,
    required AppLayoutChromeConfig chrome,
  }) : this(path: path, chrome: chrome);

  const AppLayoutVisibilityRule.prefix({
    required String path,
    required AppLayoutChromeConfig chrome,
  }) : this(
          path: path,
          chrome: chrome,
          matchType: AppLayoutRouteMatchType.prefix,
        );

  final String path;
  final AppLayoutChromeConfig chrome;
  final AppLayoutRouteMatchType matchType;

  bool matches(String location) {
    final rule = _normalize(path);
    final current = _normalize(location);
    return switch (matchType) {
      AppLayoutRouteMatchType.exact => current == rule,
      AppLayoutRouteMatchType.prefix =>
        current == rule || current.startsWith('$rule/'),
    };
  }

  static String _normalize(String value) {
    var path = Uri.tryParse(value)?.path ?? value;
    if (path.isEmpty) path = '/';
    if (!path.startsWith('/')) path = '/$path';
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }
}

@immutable
class AppLayoutVisibilityPolicy {
  const AppLayoutVisibilityPolicy({
    this.rules = const <AppLayoutVisibilityRule>[],
    this.fallback = const AppLayoutChromeConfig(),
  });

  final List<AppLayoutVisibilityRule> rules;
  final AppLayoutChromeConfig fallback;

  AppLayoutChromeConfig resolve(String location) {
    for (final rule in rules) {
      if (rule.matches(location)) return rule.chrome;
    }
    return fallback;
  }
}
