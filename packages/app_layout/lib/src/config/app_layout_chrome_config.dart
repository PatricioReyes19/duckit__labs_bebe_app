import 'package:flutter/widgets.dart';

@immutable
class AppLayoutChromeConfig {
  const AppLayoutChromeConfig({
    this.showHeader = true,
    this.showBottomBar = true,
    this.showPrimaryAction = true,
    this.showBackButton = false,
    this.showBrandMark = true,
    this.title,
    this.leading,
    this.actions = const <Widget>[],
  });

  final bool showHeader;
  final bool showBottomBar;
  final bool showPrimaryAction;
  final bool showBackButton;
  final bool showBrandMark;
  final String? title;
  final Widget? leading;
  final List<Widget> actions;
}
