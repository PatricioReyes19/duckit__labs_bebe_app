import 'package:app_layout/src/app_layout_theme.dart';
import 'package:flutter/material.dart';

class AppTopNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AppTopNavigationBar({
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.centerTitle = false,
    this.showDivider = false,
    this.toolbarHeight = kToolbarHeight,
    super.key,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final bool showDivider;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final layoutTheme = AppLayoutTheme.of(context);

    return AppBar(
      backgroundColor: layoutTheme.surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: toolbarHeight,
      centerTitle: centerTitle,
      leading: leading,
      title: title,
      actions: actions,
      shape: showDivider
          ? Border(bottom: BorderSide(color: layoutTheme.borderColor))
          : null,
    );
  }
}
