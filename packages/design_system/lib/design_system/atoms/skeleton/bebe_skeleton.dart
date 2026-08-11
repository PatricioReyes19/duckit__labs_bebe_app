import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum BebeSkeletonShape { rectangle, pill, circle }

/// Animated loading placeholder shared by component-level skeleton states.
class BebeSkeleton extends StatefulWidget {
  const BebeSkeleton({
    required this.height,
    this.width = double.infinity,
    this.shape = BebeSkeletonShape.rectangle,
    this.borderRadius,
    this.animate = true,
    super.key,
  });

  const BebeSkeleton.line({
    this.width = double.infinity,
    this.height = 12,
    this.animate = true,
    super.key,
  }) : shape = BebeSkeletonShape.pill,
       borderRadius = null;

  const BebeSkeleton.circle({
    required double size,
    this.animate = true,
    super.key,
  }) : width = size,
       height = size,
       shape = BebeSkeletonShape.circle,
       borderRadius = null;

  final double width;
  final double height;
  final BebeSkeletonShape shape;
  final BorderRadiusGeometry? borderRadius;
  final bool animate;

  @override
  State<BebeSkeleton> createState() => _BebeSkeletonState();
}

class _BebeSkeletonState extends State<BebeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant BebeSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate == widget.animate) return;
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius =
        widget.borderRadius ??
        BorderRadius.circular(theme.borderRadius.radiusL);

    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = widget.animate && !reduceMotion
                ? Curves.easeInOut.transform(_controller.value)
                : .45;
            final color = Color.lerp(
              theme.colors.background.neutralsSkeleton,
              theme.colors.background.neutralsActive,
              progress,
            );

            return DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: widget.shape == BebeSkeletonShape.circle
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: widget.shape == BebeSkeletonShape.circle
                    ? null
                    : widget.shape == BebeSkeletonShape.pill
                    ? BorderRadius.circular(theme.borderRadius.radiusFull)
                    : radius,
              ),
            );
          },
        ),
      ),
    );
  }
}
