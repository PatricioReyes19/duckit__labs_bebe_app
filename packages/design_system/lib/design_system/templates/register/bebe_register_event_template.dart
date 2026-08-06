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
    this.subcategorySelector,
    this.contextBanner,
    this.controller,
    this.maximumContentWidth = BebeLayout.formContentMaxWidth,
    this.semanticLabel = 'Registrar evento',
    super.key,
  });

  final Widget header;
  final Widget? babySelector;
  final Widget? categorySelector;
  final Widget? subcategorySelector;
  final Widget? contextBanner;
  final Widget form;
  final ScrollController? controller;
  final double maximumContentWidth;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    return Scaffold(
      backgroundColor: theme.colors.background.neutralsPage,
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
                  spacing.spacingL,
                  spacing.spacingM,
                  spacing.spacingL,
                  spacing.spacing4xl,
                ),
                sliver: SliverToBoxAdapter(
                  child: BebeResponsiveContent(
                    maxWidth: maximumContentWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header,
                        if (babySelector != null) ...[
                          SizedBox(height: spacing.spacingXl),
                          babySelector!,
                        ],
                        if (categorySelector != null) ...[
                          SizedBox(height: spacing.spacing2xl),
                          categorySelector!,
                        ],
                        if (subcategorySelector != null) ...[
                          SizedBox(height: spacing.spacingXl),
                          subcategorySelector!,
                        ],
                        if (contextBanner != null) ...[
                          SizedBox(height: spacing.spacingXl),
                          contextBanner!,
                        ],
                        SizedBox(height: spacing.spacingXl),
                        form,
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
