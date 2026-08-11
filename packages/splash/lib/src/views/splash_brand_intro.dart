import 'package:flutter/material.dart';

import '../widgets/splash_brand_content.dart';

/// Animación exclusivamente visual del splash.
///
/// La resolución funcional ocurre en paralelo dentro de `SplashBloc`.
class SplashBrandIntro extends StatefulWidget {
  const SplashBrandIntro({
    required this.onIntroCompleted,
    this.showProgress = true,
    super.key,
  });

  final VoidCallback onIntroCompleted;
  final bool showProgress;

  @override
  State<SplashBrandIntro> createState() => _SplashBrandIntroState();
}

class _SplashBrandIntroState extends State<SplashBrandIntro>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _ambientController;
  bool _started = false;
  bool _notified = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addStatusListener(_handleIntroStatus);
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion != reduceMotion) {
      _reduceMotion = reduceMotion;
      _introController.duration = Duration(
        milliseconds: reduceMotion ? 160 : 1200,
      );
      if (reduceMotion) {
        _ambientController.stop();
      }
    }

    if (!_started) {
      _started = true;
      _introController.forward();
    }
  }

  void _handleIntroStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    if (!_notified) {
      _notified = true;
      widget.onIntroCompleted();
    }

    if (!_reduceMotion && !_ambientController.isAnimating) {
      _ambientController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _introController
      ..removeStatusListener(_handleIntroStatus)
      ..dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_introController, _ambientController]),
      builder: (context, _) {
        return SplashBrandContent(
          introProgress: _introController.value,
          ambientProgress: _ambientController.value,
          reduceMotion: _reduceMotion,
          showProgress: widget.showProgress,
        );
      },
    );
  }
}
