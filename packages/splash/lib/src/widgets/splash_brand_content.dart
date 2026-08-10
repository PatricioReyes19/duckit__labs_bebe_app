import 'package:design_system/design_system/atoms/brand/bebe_brand_mark.dart';
import 'package:design_system/design_system/atoms/brand/bebe_brand_mark_variant.dart';
import 'package:design_system/tokens/bebe_color.dart';
import 'package:flutter/material.dart';

import 'splash_background_decoration.dart';

/// Composición accesible y responsive de la identidad Propuesta C.
class SplashBrandContent extends StatelessWidget {
  const SplashBrandContent({
    this.introProgress = 1,
    this.ambientProgress = 0,
    this.reduceMotion = false,
    this.showProgress = false,
    super.key,
  });

  final double introProgress;
  final double ambientProgress;
  final bool reduceMotion;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final isDark = materialTheme.brightness == Brightness.dark;
    final colors = materialTheme.extension<BebeColor>()!;
    final progress = introProgress.clamp(0, 1).toDouble();
    final backgroundProgress = _interval(progress, 0, 0.42);
    final symbolProgress = _interval(progress, 0, 0.81);
    final wordmarkProgress = _interval(progress, 0.23, 0.83);
    final claimProgress = _interval(progress, 0.46, 1);

    return Semantics(
      container: true,
      image: true,
      label: showProgress
          ? 'BebéApp está preparando tu espacio de cuidado'
          : 'BebéApp. Cuidamos juntos lo que más importa',
      child: SplashBackgroundDecoration(
        introProgress: backgroundProgress,
        ambientProgress: reduceMotion ? 0 : ambientProgress,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final symbolSize = (width * 0.29).clamp(92.0, 264.0).toDouble();
            final wordmarkSize = (width * 0.115).clamp(36.0, 68.0).toDouble();
            final claimSize = (width * 0.050).clamp(16.0, 26.0).toDouble();
            final logoGap =
                (constraints.maxHeight * 0.018).clamp(10.0, 22.0).toDouble();
            final claimGap =
                (constraints.maxHeight * 0.018).clamp(12.0, 22.0).toDouble();
            final symbolOpacity =
                reduceMotion ? symbolProgress : 0.82 + (symbolProgress * 0.18);
            final symbolScale =
                reduceMotion ? 1.0 : 0.94 + (symbolProgress * 0.06);
            // El asset oficial conserva margen transparente de seguridad. Esta
            // compensación mantiene visible el símbolo en el 26–31 % indicado
            // sin recortarlo ni reconstruirlo.
            const assetSafeAreaCompensation = 1.44;

            return Align(
              alignment: const Alignment(0, -0.22),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width * 0.86),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: symbolOpacity,
                      child: Transform.scale(
                        scale: symbolScale,
                        child: SizedBox.square(
                          dimension: symbolSize,
                          child: ClipRect(
                            child: Transform.scale(
                              scale: assetSafeAreaCompensation,
                              child: BebeBrandMark(
                                key: const Key('splash-brand-mark'),
                                variant: isDark
                                    ? BebeBrandMarkVariant.darkColor
                                    : BebeBrandMarkVariant.light,
                                size: symbolSize,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: logoGap),
                    Opacity(
                      opacity: wordmarkProgress,
                      child: Transform.translate(
                        offset: reduceMotion
                            ? Offset.zero
                            : Offset(0, (1 - wordmarkProgress) * 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'BebéApp',
                            key: const Key('splash-wordmark'),
                            maxLines: 1,
                            style:
                                materialTheme.textTheme.displayMedium?.copyWith(
                              color: isDark
                                  ? colors.text.neutralDisplay
                                  : colors.text.brandAlternative,
                              fontSize: wordmarkSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.1,
                              height: 1.04,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: claimGap),
                    Opacity(
                      opacity: claimProgress,
                      child: Transform.translate(
                        offset: reduceMotion
                            ? Offset.zero
                            : Offset(0, (1 - claimProgress) * 6),
                        child: Text(
                          'Cuidamos juntos\nlo que más importa',
                          key: const Key('splash-claim'),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.center,
                          style: materialTheme.textTheme.bodyLarge?.copyWith(
                            color: colors.text.neutralDisplay,
                            fontSize: claimSize,
                            fontWeight: FontWeight.w500,
                            height: 1.36,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _interval(double value, double begin, double end) {
    final normalized = ((value - begin) / (end - begin)).clamp(0, 1);
    return Curves.easeOutCubic.transform(normalized.toDouble());
  }
}
