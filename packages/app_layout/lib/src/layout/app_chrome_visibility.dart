import 'package:flutter/foundation.dart';

@immutable
class AppChromeVisibility {
  const AppChromeVisibility({
    this.showTopNavigation = true,
    this.showBottomNavigation = true,
  });

  const AppChromeVisibility.visible()
    : showTopNavigation = true,
      showBottomNavigation = true;

  static const hidden = AppChromeVisibility(
    showTopNavigation: false,
    showBottomNavigation: false,
  );

  final bool showTopNavigation;
  final bool showBottomNavigation;

  AppChromeVisibility copyWith({
    bool? showTopNavigation,
    bool? showBottomNavigation,
  }) {
    return AppChromeVisibility(
      showTopNavigation: showTopNavigation ?? this.showTopNavigation,
      showBottomNavigation: showBottomNavigation ?? this.showBottomNavigation,
    );
  }
}
