import 'package:design_system/tokens/bebe_color.dart';
import 'package:flutter/material.dart';

/// Capas decorativas responsive del splash de marca.
///
/// El símbolo y los textos viven fuera de este widget para conservar su
/// semántica y permitir que cada capa tenga su propia animación.
class SplashBackgroundDecoration extends StatelessWidget {
  const SplashBackgroundDecoration({
    required this.introProgress,
    required this.ambientProgress,
    required this.child,
    super.key,
  });

  final double introProgress;
  final double ambientProgress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final colors = materialTheme.extension<BebeColor>()!;
    final isDark = materialTheme.brightness == Brightness.dark;
    final haloOpacity = isDark ? 0.09 : 0.18;
    final backgroundAsset = isDark
        ? 'assets/branding/dark/splash_clouds_background.png'
        : 'assets/branding/light/splash_clouds_background.png';

    return ColoredBox(
      color: colors.background.splash,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundAsset,
            key: const Key('splash-clouds-background'),
            package: 'splash',
            alignment: Alignment.bottomCenter,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            excludeFromSemantics: true,
          ),
          Opacity(
            opacity:
                introProgress.clamp(0, 1) * (0.86 + (ambientProgress * 0.14)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.34),
                  radius: 0.62,
                  colors: [
                    colors.background.brandSurface.withValues(
                      alpha: haloOpacity,
                    ),
                    Colors.transparent,
                  ],
                  stops: const [0, 1],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
