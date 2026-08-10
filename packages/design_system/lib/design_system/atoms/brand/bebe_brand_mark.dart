import 'package:flutter/material.dart';

import 'bebe_brand_assets.dart';
import 'bebe_brand_mark_variant.dart';

class BebeBrandMark extends StatelessWidget {
  const BebeBrandMark({
    this.variant = BebeBrandMarkVariant.master,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'BebéApp',
    this.excludeFromSemantics = false,
    super.key,
  }) : assert(
         size == null || (width == null && height == null),
         'Use size o width/height, no ambos.',
       );

  final BebeBrandMarkVariant variant;
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String semanticLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      BebeBrandAssets.pathFor(variant),
      package: BebeBrandAssets.packageName,
      width: size ?? width,
      height: size ?? height,
      fit: fit,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );

    if (excludeFromSemantics) {
      return ExcludeSemantics(child: image);
    }

    return Semantics(image: true, label: semanticLabel, child: image);
  }
}
