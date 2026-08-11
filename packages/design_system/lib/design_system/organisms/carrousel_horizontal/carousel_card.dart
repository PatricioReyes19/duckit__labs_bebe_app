import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeHorizontalCardCarousel extends StatefulWidget {
  const BebeHorizontalCardCarousel({
    required this.children,
    this.height = 172,
    this.initialPage = 0,
    this.viewportFraction = 0.88,
    this.showPageIndicator = true,
    this.padEnds = false,
    this.edgePadding,
    this.onPageChanged,
    this.semanticLabel,
    super.key,
  }) : assert(
         children.length > 0,
         'BebeHorizontalCardCarousel requires at least one child.',
       ),
       assert(height > 0, 'height must be greater than zero.'),
       assert(
         initialPage >= 0 && initialPage < children.length,
         'initialPage must be inside the children range.',
       ),
       assert(
         viewportFraction > 0 && viewportFraction <= 1,
         'viewportFraction must be greater than zero and at most one.',
       );

  final List<Widget> children;
  final double height;
  final int initialPage;
  final double viewportFraction;
  final bool showPageIndicator;
  final bool padEnds;

  /// Espacio inicial que pertenece al contenido desplazable. Desaparece al
  /// avanzar el carrusel, a diferencia de un padding exterior fijo.
  final double? edgePadding;
  final ValueChanged<int>? onPageChanged;
  final String? semanticLabel;

  @override
  State<BebeHorizontalCardCarousel> createState() =>
      _BebeHorizontalCardCarouselState();
}

class _BebeHorizontalCardCarouselState
    extends State<BebeHorizontalCardCarousel> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialPage;
    _controller = _createController();
  }

  @override
  void didUpdateWidget(covariant BebeHorizontalCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.viewportFraction != widget.viewportFraction) {
      _controller.dispose();
      _controller = _createController();
    }

    if (_currentIndex >= widget.children.length) {
      _currentIndex = widget.children.length - 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) {
          return;
        }

        _controller.jumpToPage(_currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PageController _createController() {
    return PageController(
      initialPage: _currentIndex,
      viewportFraction: widget.viewportFraction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    final edgePadding = widget.edgePadding ?? spacing.spacingL;
    final effectiveSemanticLabel = _normalizeText(widget.semanticLabel);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            padEnds: widget.padEnds,
            itemCount: widget.children.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 && !widget.padEnds
                      ? edgePadding
                      : spacing.spacingXs,
                  right: index == widget.children.length - 1
                      ? edgePadding
                      : spacing.spacingXs,
                ),
                child: SizedBox.expand(
                  child: KeyedSubtree(
                    key: ValueKey<int>(index),
                    child: widget.children[index],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showPageIndicator && widget.children.length > 1) ...[
          SizedBox(height: spacing.spacingM),
          BebeCarouselPageIndicator(
            itemCount: widget.children.length,
            currentIndex: _currentIndex,
          ),
        ],
      ],
    );

    if (effectiveSemanticLabel == null) {
      return content;
    }

    return Semantics(
      container: true,
      label: effectiveSemanticLabel,
      child: content,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    widget.onPageChanged?.call(index);
  }

  static String? _normalizeText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
