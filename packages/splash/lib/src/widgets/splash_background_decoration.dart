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
    final haloOpacity = isDark ? 0.13 : 0.42;
    final breathingOpacity = 0.92 + (ambientProgress * 0.08);
    final wavesProgress = Curves.easeOutCubic.transform(introProgress);
    final wavesAsset = isDark
        ? 'assets/branding/dark/splash_waves.png'
        : 'assets/branding/light/splash_waves.png';

    return ColoredBox(
      color: colors.background.splash,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final waveHeight =
              (constraints.maxHeight * 0.20).clamp(112.0, 300.0).toDouble();

          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: introProgress.clamp(0, 1) * breathingOpacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.34),
                      radius: 0.62,
                      colors: [
                        colors.background.brandSurface.withValues(
                          alpha: haloOpacity,
                        ),
                        colors.background.brandDefault.withValues(
                          alpha: isDark ? 0.035 : 0.018,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.42, 1],
                    ),
                  ),
                ),
              ),
              ExcludeSemantics(
                child: CustomPaint(
                  painter: _SplashSparklesPainter(
                    color: isDark
                        ? colors.text.neutralDisplay
                        : colors.text.brandAlternative,
                    opacity: introProgress,
                    ambientProgress: ambientProgress,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, (1 - wavesProgress) * 18),
                  child: Opacity(
                    opacity: 0.65 + (wavesProgress * 0.35),
                    child: SizedBox(
                      key: const Key('splash-waves'),
                      width: constraints.maxWidth,
                      height: waveHeight,
                      child: Image.asset(
                        wavesAsset,
                        package: 'splash',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
              child,
            ],
          );
        },
      ),
    );
  }
}

class _SplashSparklesPainter extends CustomPainter {
  const _SplashSparklesPainter({
    required this.color,
    required this.opacity,
    required this.ambientProgress,
  });

  final Color color;
  final double opacity;
  final double ambientProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = size.shortestSide;
    final points = <Offset>[
      Offset(size.width * 0.16, size.height * 0.19),
      Offset(size.width * 0.84, size.height * 0.22),
      Offset(size.width * 0.11, size.height * 0.48),
      Offset(size.width * 0.89, size.height * 0.52),
    ];

    for (var index = 0; index < points.length; index++) {
      final phase = (ambientProgress + index * 0.18) % 1;
      final radius = shortestSide * (0.006 + phase * 0.0025);
      final paint = Paint()
        ..color = color.withValues(
          alpha: opacity * (0.10 + phase * 0.12),
        )
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.3;
      final center = points[index];

      canvas
        ..drawLine(
          Offset(center.dx - radius, center.dy),
          Offset(center.dx + radius, center.dy),
          paint,
        )
        ..drawLine(
          Offset(center.dx, center.dy - radius),
          Offset(center.dx, center.dy + radius),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_SplashSparklesPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.ambientProgress != ambientProgress;
  }
}
