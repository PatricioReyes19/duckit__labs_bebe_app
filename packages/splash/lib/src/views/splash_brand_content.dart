import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashBrandContent extends StatefulWidget {
  const SplashBrandContent({
    this.showProgress = false,
    super.key,
  });

  final bool showProgress;

  @override
  State<SplashBrandContent> createState() => _SplashBrandContentState();
}

class _SplashBrandContentState extends State<SplashBrandContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final composition = isDark
        ? 'assets/branding/dark/splash_composition.png'
        : 'assets/branding/light/splash_composition.png';

    return Semantics(
      image: true,
      label: widget.showProgress
          ? 'BebéApp está preparando tu espacio de cuidado'
          : 'BebéApp',
      child: ColoredBox(
        color: isDark ? const Color(0xFF07575B) : const Color(0xFFFAFAFC),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              composition,
              package: 'splash',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              excludeFromSemantics: true,
            ),
            ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SplashAmbientPainter(
                      progress: _ambientController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashAmbientPainter extends CustomPainter {
  const _SplashAmbientPainter({
    required this.progress,
    required this.isDark,
  });

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = math.min(size.width, size.height);
    final logoCenter = Offset(size.width * 0.5, size.height * 0.335);
    final pulse = Curves.easeInOut.transform(progress);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? Colors.white : const Color(0xFF15A79A)).withValues(
            alpha: 0.10 + (pulse * 0.05),
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: logoCenter,
          radius: shortestSide * (0.34 + pulse * 0.025),
        ),
      );
    canvas.drawCircle(
      logoCenter,
      shortestSide * (0.34 + pulse * 0.025),
      glowPaint,
    );

    final orbitPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF15A79A))
          .withValues(alpha: 0.05 + pulse * 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromCircle(center: logoCenter, radius: shortestSide * 0.31),
      math.pi * 1.08,
      math.pi * 0.84,
      false,
      orbitPaint,
    );

    final sparkleColor = isDark ? Colors.white : const Color(0xFF15A79A);
    final sparkles = <Offset>[
      Offset(size.width * 0.17, size.height * 0.19),
      Offset(size.width * 0.83, size.height * 0.22),
      Offset(size.width * 0.12, size.height * 0.47),
      Offset(size.width * 0.88, size.height * 0.51),
    ];

    for (var index = 0; index < sparkles.length; index++) {
      final phase = (progress + index * 0.22) % 1;
      _paintSparkle(
        canvas,
        sparkles[index],
        shortestSide * (0.006 + phase * 0.004),
        sparkleColor.withValues(alpha: 0.15 + phase * 0.28),
      );
    }
  }

  void _paintSparkle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;
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

  @override
  bool shouldRepaint(_SplashAmbientPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
