import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum BebeSkeletonShape { rectangle, pill, circle }

/// Animated loading placeholder shared by component-level skeleton states.
class BebeSkeleton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = context.theme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius =
        borderRadius ?? BorderRadius.circular(theme.borderRadius.radiusL);
    final baseColor = theme.colors.background.neutralsSkeleton;
    final highlightColor = theme.colors.background.neutralsActive;

    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: Skeletonizer.zone(
          effect: !animate || reduceMotion
              ? SolidColorEffect(color: baseColor)
              : ShimmerEffect(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  duration: const Duration(milliseconds: 900),
                ),
          child: Bone(
            width: width,
            height: height,
            shape: shape == BebeSkeletonShape.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius: shape == BebeSkeletonShape.circle
                ? null
                : shape == BebeSkeletonShape.pill
                ? BorderRadius.circular(theme.borderRadius.radiusFull)
                : radius,
          ),
        ),
      ),
    );
  }
}
