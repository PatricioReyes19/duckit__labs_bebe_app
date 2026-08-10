import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum BebeIconSize {
  xs(16),
  sm(20),
  md(24),
  lg(32),
  xl(40),
  illustrative(56);

  const BebeIconSize(this.value);

  final double value;
}

sealed class BebeIconSource {
  const BebeIconSource();
}

final class BebeMaterialIconSource extends BebeIconSource {
  const BebeMaterialIconSource(this.icon);

  final IconData icon;
}

final class BebeSvgIconSource extends BebeIconSource {
  const BebeSvgIconSource(this.assetPath);

  final String assetPath;
}

class BebeIcon extends StatelessWidget {
  const BebeIcon({
    required this.source,
    this.size = BebeIconSize.md,
    this.color,
    this.semanticLabel,
    this.strokeWidth,
    super.key,
  });

  factory BebeIcon.material({
    required IconData icon,
    BebeIconSize size = BebeIconSize.md,
    Color? color,
    String? semanticLabel,
    double? strokeWidth,
    Key? key,
  }) {
    return BebeIcon(
      source: BebeMaterialIconSource(icon),
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      strokeWidth: strokeWidth,
      key: key,
    );
  }

  factory BebeIcon.svg({
    required String assetPath,
    BebeIconSize size = BebeIconSize.md,
    Color? color,
    String? semanticLabel,
    Key? key,
  }) {
    return BebeIcon(
      source: BebeSvgIconSource(assetPath),
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      key: key,
    );
  }

  final BebeIconSource source;
  final BebeIconSize size;
  final Color? color;
  final String? semanticLabel;

  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    final child = switch (source) {
      BebeMaterialIconSource(:final icon) => Icon(
        icon,
        size: size.value,
        color: effectiveColor,
        semanticLabel: semanticLabel,
      ),
      BebeSvgIconSource(:final assetPath) => SvgPicture.asset(
        assetPath,
        width: size.value,
        height: size.value,
        colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
        semanticsLabel: semanticLabel,
      ),
    };

    return ExcludeSemantics(
      excluding: semanticLabel == null,
      child: SizedBox.square(
        dimension: size.value,
        child: Center(child: child),
      ),
    );
  }
}
