import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Layout behavior for [BebeBottomSheet].
enum BebeBottomSheetVariant {
  /// Keeps a caller-defined fixed height and does not add scrolling.
  staticContent,

  /// Uses the configured maximum height and makes the body scrollable.
  scrollable,

  /// Grows with its content until the maximum height, then scrolls the body.
  dynamic,
}

/// Shared modal bottom-sheet surface for BebéApp.
///
/// Header and footer stay outside the body scroll. This keeps actions visible
/// while long content remains reachable without covering the complete screen.
class BebeBottomSheet extends StatelessWidget {
  const BebeBottomSheet({
    required this.child,
    this.variant = BebeBottomSheetVariant.dynamic,
    this.header,
    this.footer,
    this.showDragHandle = true,
    this.staticHeight = 320,
    this.maximumHeightFactor = .72,
    this.contentPadding,
    this.headerPadding,
    this.footerPadding,
    this.scrollController,
    this.semanticLabel,
    super.key,
  }) : assert(staticHeight > 0, 'staticHeight must be greater than zero.'),
       assert(
         maximumHeightFactor > 0 && maximumHeightFactor <= 1,
         'maximumHeightFactor must be greater than zero and at most one.',
       );

  final Widget child;
  final BebeBottomSheetVariant variant;
  final Widget? header;
  final Widget? footer;
  final bool showDragHandle;
  final double staticHeight;
  final double maximumHeightFactor;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? footerPadding;
  final ScrollController? scrollController;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = math.max(
      0.0,
      mediaQuery.size.height -
          mediaQuery.padding.top -
          mediaQuery.viewInsets.bottom,
    );
    final maximumHeight = availableHeight * maximumHeightFactor;
    final effectiveContentPadding =
        contentPadding ??
        EdgeInsets.fromLTRB(
          spacing.spacingXl,
          spacing.spacingL,
          spacing.spacingXl,
          spacing.spacingXl,
        );
    final effectiveHeaderPadding =
        headerPadding ??
        EdgeInsets.fromLTRB(
          spacing.spacingXl,
          spacing.spacingS,
          spacing.spacingXl,
          0,
        );
    final effectiveFooterPadding =
        footerPadding ?? EdgeInsets.all(spacing.spacingXl);

    final frame = switch (variant) {
      BebeBottomSheetVariant.staticContent => _StaticBottomSheetFrame(
        height: math.min(staticHeight, maximumHeight),
        header: header,
        footer: footer,
        showDragHandle: showDragHandle,
        contentPadding: effectiveContentPadding,
        headerPadding: effectiveHeaderPadding,
        footerPadding: effectiveFooterPadding,
        child: child,
      ),
      BebeBottomSheetVariant.scrollable => _ScrollableBottomSheetFrame(
        height: maximumHeight,
        header: header,
        footer: footer,
        showDragHandle: showDragHandle,
        contentPadding: effectiveContentPadding,
        headerPadding: effectiveHeaderPadding,
        footerPadding: effectiveFooterPadding,
        scrollController: scrollController,
        child: child,
      ),
      BebeBottomSheetVariant.dynamic => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maximumHeight),
        child: _DynamicBottomSheetFrame(
          header: header,
          footer: footer,
          showDragHandle: showDragHandle,
          contentPadding: effectiveContentPadding,
          headerPadding: effectiveHeaderPadding,
          footerPadding: effectiveFooterPadding,
          scrollController: scrollController,
          child: child,
        ),
      ),
    };

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: Material(
        key: const ValueKey('bebe-bottom-sheet-surface'),
        color: theme.colors.background.neutralsSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(theme.borderRadius.radius3xl),
            topRight: Radius.circular(theme.borderRadius.radius3xl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(top: false, child: frame),
      ),
    );
  }
}

/// Opens a [BebeBottomSheet] with the shared modal-route configuration.
Future<T?> showBebeBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder bodyBuilder,
  WidgetBuilder? headerBuilder,
  WidgetBuilder? footerBuilder,
  BebeBottomSheetVariant variant = BebeBottomSheetVariant.dynamic,
  bool showDragHandle = true,
  double staticHeight = 320,
  double maximumHeightFactor = .72,
  double maximumWidth = BebeLayout.formContentMaxWidth,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? headerPadding,
  EdgeInsetsGeometry? footerPadding,
  ScrollController? scrollController,
  String? semanticLabel,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(maxWidth: maximumWidth),
    builder: (sheetContext) => BebeBottomSheet(
      variant: variant,
      header: headerBuilder?.call(sheetContext),
      footer: footerBuilder?.call(sheetContext),
      showDragHandle: showDragHandle,
      staticHeight: staticHeight,
      maximumHeightFactor: maximumHeightFactor,
      contentPadding: contentPadding,
      headerPadding: headerPadding,
      footerPadding: footerPadding,
      scrollController: scrollController,
      semanticLabel: semanticLabel,
      child: bodyBuilder(sheetContext),
    ),
  );
}

class _StaticBottomSheetFrame extends StatelessWidget {
  const _StaticBottomSheetFrame({
    required this.height,
    required this.header,
    required this.footer,
    required this.showDragHandle,
    required this.contentPadding,
    required this.headerPadding,
    required this.footerPadding,
    required this.child,
  });

  final double height;
  final Widget? header;
  final Widget? footer;
  final bool showDragHandle;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry footerPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle) const _BottomSheetDragHandle(),
          if (header != null) Padding(padding: headerPadding, child: header),
          Expanded(
            child: Padding(padding: contentPadding, child: child),
          ),
          if (footer != null)
            _BottomSheetFooter(padding: footerPadding, child: footer!),
        ],
      ),
    );
  }
}

class _ScrollableBottomSheetFrame extends StatelessWidget {
  const _ScrollableBottomSheetFrame({
    required this.height,
    required this.header,
    required this.footer,
    required this.showDragHandle,
    required this.contentPadding,
    required this.headerPadding,
    required this.footerPadding,
    required this.scrollController,
    required this.child,
  });

  final double height;
  final Widget? header;
  final Widget? footer;
  final bool showDragHandle;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry footerPadding;
  final ScrollController? scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle) const _BottomSheetDragHandle(),
          if (header != null) Padding(padding: headerPadding, child: header),
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('bebe-bottom-sheet-scroll'),
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: contentPadding,
              child: child,
            ),
          ),
          if (footer != null)
            _BottomSheetFooter(padding: footerPadding, child: footer!),
        ],
      ),
    );
  }
}

class _DynamicBottomSheetFrame extends StatelessWidget {
  const _DynamicBottomSheetFrame({
    required this.header,
    required this.footer,
    required this.showDragHandle,
    required this.contentPadding,
    required this.headerPadding,
    required this.footerPadding,
    required this.scrollController,
    required this.child,
  });

  final Widget? header;
  final Widget? footer;
  final bool showDragHandle;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry footerPadding;
  final ScrollController? scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDragHandle) const _BottomSheetDragHandle(),
        if (header != null) Padding(padding: headerPadding, child: header),
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            key: const ValueKey('bebe-bottom-sheet-scroll'),
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: contentPadding,
            child: child,
          ),
        ),
        if (footer != null)
          _BottomSheetFooter(padding: footerPadding, child: footer!),
      ],
    );
  }
}

class _BottomSheetDragHandle extends StatelessWidget {
  const _BottomSheetDragHandle();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(
        top: theme.spacing.spacingS,
        bottom: theme.spacing.spacingXs,
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colors.border.neutralDefault,
            borderRadius: BorderRadius.circular(theme.borderRadius.radiusFull),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetFooter extends StatelessWidget {
  const _BottomSheetFooter({required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colors.border.neutralDefault),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
