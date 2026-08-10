import 'package:app_layout/src/app_layout_theme.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.centerTitle = true,
    this.showDivider = false,
    this.showBackButton = false,
    this.showBrandMark = true,
    this.onBackPressed,
    this.brandMarkSize = 34,
    this.backgroundColor,
    this.foregroundColor,
    this.titleStyle,
    super.key,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  final bool centerTitle;
  final bool showDivider;
  final bool showBackButton;
  final bool showBrandMark;
  final VoidCallback? onBackPressed;
  final double brandMarkSize;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? titleStyle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final layoutTheme = AppLayoutTheme.of(context);
    final theme = Theme.of(context);
    final bbTheme = context.theme;
    final colors = bbTheme.colors;
    final typography = bbTheme.typography;

    final effectiveForeground = foregroundColor ?? theme.colorScheme.onSurface;

    final resolvedLeading =
        leading ??
        (showBackButton
            ? IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            : BebeBrandMark(
                variant: theme.brightness == Brightness.dark
                    ? BebeBrandMarkVariant.darkColor
                    : BebeBrandMarkVariant.master,
                size: brandMarkSize,
                excludeFromSemantics: true,
              ));

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? layoutTheme.surfaceColor,
      foregroundColor: effectiveForeground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: resolvedLeading,
      iconTheme: IconThemeData(color: effectiveForeground),
      actionsIconTheme: IconThemeData(color: effectiveForeground),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  titleStyle ??
                  typography.styles.title.lg.bold.copyWith(
                    color: colors.text.brandDefault,
                  ),
            ),
          ),
        ],
      ),
      actions: actions,
      shape: showDivider
          ? Border(bottom: BorderSide(color: layoutTheme.borderColor))
          : null,
    );
  }
}
