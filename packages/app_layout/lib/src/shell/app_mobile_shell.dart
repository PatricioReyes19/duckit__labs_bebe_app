import 'package:app_layout/src/layout/app_chrome_visibility_policy.dart';
import 'package:flutter/material.dart';

import '../app_layout_theme.dart';

class AppMobileShell extends StatelessWidget {
  const AppMobileShell({
    required this.body,
    required this.location,
    required this.visibilityPolicy,
    this.topNavigation,
    this.bottomNavigation,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    super.key,
  });

  final Widget body;
  final String location;
  final AppChromeVisibilityPolicy visibilityPolicy;
  final PreferredSizeWidget? topNavigation;
  final Widget? bottomNavigation;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final visibility = visibilityPolicy.resolve(location);
    final layoutTheme = AppLayoutTheme.of(context);

    return Scaffold(
      backgroundColor: layoutTheme.backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      appBar: visibility.showTopNavigation ? topNavigation : null,
      body: body,
      bottomNavigationBar: visibility.showBottomNavigation
          ? bottomNavigation
          : null,
    );
  }
}
