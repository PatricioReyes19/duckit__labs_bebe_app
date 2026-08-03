import 'package:flutter/foundation.dart';

import 'app_chrome_visibility.dart';

enum AppRouteMatchType { exact, prefix }

@immutable
class AppRouteVisibilityRule {
  const AppRouteVisibilityRule({
    required this.path,
    required this.visibility,
    this.matchType = AppRouteMatchType.exact,
  }) : assert(path.length > 0, 'path must not be empty.');

  const AppRouteVisibilityRule.exact({
    required String path,
    required AppChromeVisibility visibility,
  }) : this(
         path: path,
         visibility: visibility,
         matchType: AppRouteMatchType.exact,
       );

  const AppRouteVisibilityRule.prefix({
    required String path,
    required AppChromeVisibility visibility,
  }) : this(
         path: path,
         visibility: visibility,
         matchType: AppRouteMatchType.prefix,
       );

  final String path;
  final AppChromeVisibility visibility;
  final AppRouteMatchType matchType;

  bool matches(String location) {
    final normalizedRule = _normalizePath(path);
    final normalizedLocation = _normalizePath(location);

    return switch (matchType) {
      AppRouteMatchType.exact => normalizedLocation == normalizedRule,
      AppRouteMatchType.prefix =>
        normalizedLocation == normalizedRule ||
            normalizedLocation.startsWith('$normalizedRule/'),
    };
  }

  static String _normalizePath(String value) {
    final parsed = Uri.tryParse(value);
    var normalized = parsed?.path ?? value;

    if (normalized.isEmpty) {
      normalized = '/';
    }

    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }

    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }
}
