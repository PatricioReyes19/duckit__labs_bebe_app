import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Responsive visual structure shared by all register event forms.
///
/// Every region is supplied as a slot. The template owns no navigation,
/// validation, persistence or feature state.
class BebeRegisterEventTemplate extends StatelessWidget {
  const BebeRegisterEventTemplate({
    required this.header,
    required this.form,
    this.babySelector,
    this.categorySelector,
    this.fullBleedCategorySelector = false,
    this.subcategorySelector,
    this.contextBanner,
    this.bottomNavigationBar,
    this.controller,
    this.maximumContentWidth = BebeLayout.formContentMaxWidth,
    this.semanticLabel = 'Registrar evento',
    super.key,
  });

  final Widget header;
  final Widget? babySelector;
  final Widget? categorySelector;
  final bool fullBleedCategorySelector;
  final Widget? subcategorySelector;
  final Widget? contextBanner;
  final Widget? bottomNavigationBar;
  final Widget form;
  final ScrollController? controller;
  final double maximumContentWidth;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final horizontalPadding = spacing.spacingXl;

    Widget padded(Widget child) => Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: child,
    );

    return Scaffold(
      backgroundColor: theme.colors.background.neutralsSurface,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Semantics(
          container: true,
          label: semanticLabel,
          child: CustomScrollView(
            controller: controller,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  spacing.spacingM,
                  0,
                  spacing.spacing4xl,
                ),
                sliver: SliverToBoxAdapter(
                  child: BebeResponsiveContent(
                    maxWidth: maximumContentWidth + horizontalPadding * 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        padded(header),
                        if (babySelector != null) ...[
                          SizedBox(height: spacing.spacingXl),
                          padded(babySelector!),
                        ],
                        if (categorySelector != null) ...[
                          SizedBox(height: spacing.spacingXl),
                          if (fullBleedCategorySelector)
                            categorySelector!
                          else
                            padded(categorySelector!),
                        ],
                        if (subcategorySelector != null) ...[
                          SizedBox(height: spacing.spacingL),
                          padded(subcategorySelector!),
                        ],
                        if (contextBanner != null) ...[
                          SizedBox(height: spacing.spacingL),
                          padded(contextBanner!),
                        ],
                        SizedBox(height: spacing.spacingL),
                        padded(form),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
