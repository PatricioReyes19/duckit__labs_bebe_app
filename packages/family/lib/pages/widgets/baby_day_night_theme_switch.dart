import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BabyDayNightThemeSwitch extends StatefulWidget {
  const BabyDayNightThemeSwitch({
    required this.isDark,
    required this.followsSystem,
    required this.onChanged,
    required this.onUseSystem,
    super.key,
  });

  final bool isDark;
  final bool followsSystem;
  final ValueChanged<bool> onChanged;
  final VoidCallback onUseSystem;

  @override
  State<BabyDayNightThemeSwitch> createState() =>
      _BabyDayNightThemeSwitchState();
}

class _BabyDayNightThemeSwitchState extends State<BabyDayNightThemeSwitch> {
  static const _motionDuration = Duration(milliseconds: 160);

  late bool _visualIsDark;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _visualIsDark = widget.isDark;
  }

  @override
  void didUpdateWidget(covariant BabyDayNightThemeSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isTransitioning && widget.isDark != _visualIsDark) {
      _visualIsDark = widget.isDark;
    }
  }

  Future<void> _toggleTheme() async {
    if (_isTransitioning) return;

    final next = !_visualIsDark;
    setState(() {
      _visualIsDark = next;
      _isTransitioning = true;
    });
    widget.onChanged(next);

    await Future<void>.delayed(_motionDuration);
    if (!mounted) return;
    setState(() {
      _isTransitioning = false;
      _visualIsDark = widget.isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final trackColor = _visualIsDark
        ? colors.background.accentSurface
        : colors.background.warningSurface;
    final trackBorder = _visualIsDark
        ? colors.border.accentAlternative
        : colors.border.warningDefault;

    return Semantics(
      container: true,
      label: 'Tema visual. Bebé despierto para claro, bebé dormido para oscuro',
      toggled: _visualIsDark,
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿El bebé está despierto o dormido?',
                style: theme.typography.styles.title.sm.semibold.copyWith(
                  color: colors.text.neutralTitle,
                ),
              ),
              SizedBox(height: theme.spacing.spacingS),
              Text(
                _visualIsDark
                    ? 'Dormido · luz suave para la noche'
                    : 'Despierto · pantalla clara para el día',
                style: theme.typography.styles.body.sm.regular.copyWith(
                  color: colors.text.neutralBody,
                ),
              ),
              SizedBox(height: theme.spacing.spacingL),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: theme.borderRadius.full,
                  onTap: _isTransitioning ? null : _toggleTheme,
                  child: AnimatedContainer(
                    duration: _motionDuration,
                    curve: Curves.easeOutCubic,
                    height: 68,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: theme.borderRadius.full,
                      border: Border.all(color: trackBorder),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Row(
                            children: [
                              Expanded(
                                child: _ModeLabel(
                                  label: 'Despierto',
                                  icon: Icons.wb_sunny_rounded,
                                  selected: !_visualIsDark,
                                ),
                              ),
                              Expanded(
                                child: _ModeLabel(
                                  label: 'Dormido',
                                  icon: Icons.nightlight_round,
                                  selected: _visualIsDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedAlign(
                          duration: _motionDuration,
                          curve: Curves.easeOutCubic,
                          alignment: _visualIsDark
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: SizedBox.square(
                            dimension: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.background.neutralsSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _visualIsDark
                                      ? colors.border.accentAlternative
                                      : colors.border.warningDefault,
                                ),
                                boxShadow: theme.elevation.low,
                              ),
                              child: CustomPaint(
                                painter: _BabyFacePainter(
                                  sleeping: _visualIsDark,
                                  lineColor: _visualIsDark
                                      ? colors.text.accentDefault
                                      : colors.text.brandDefault,
                                  cheekColor: colors.background.errorSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: theme.spacing.spacingS),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: widget.followsSystem ? null : widget.onUseSystem,
                  icon: Icon(
                    widget.followsSystem
                        ? Icons.check_circle_rounded
                        : Icons.settings_suggest_outlined,
                  ),
                  label: Text(
                    widget.followsSystem
                        ? 'Siguiendo el sistema'
                        : 'Usar tema del sistema',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({
    required this.label,
    required this.icon,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Opacity(
      opacity: selected ? 0 : .72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: theme.colors.icons.neutralAlternative),
          SizedBox(width: theme.spacing.spacingS),
          Text(
            label,
            style: theme.typography.styles.label.sm.semibold.copyWith(
              color: theme.colors.text.neutralBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _BabyFacePainter extends CustomPainter {
  const _BabyFacePainter({
    required this.sleeping,
    required this.lineColor,
    required this.cheekColor,
  });

  final bool sleeping;
  final Color lineColor;
  final Color cheekColor;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = cheekColor;
    final center = Offset(size.width / 2, size.height / 2 + 1);

    canvas.drawCircle(center.translate(-14, 3), 3.5, fill);
    canvas.drawCircle(center.translate(14, 3), 3.5, fill);

    if (sleeping) {
      canvas.drawArc(
        Rect.fromCenter(center: center.translate(-8, -3), width: 10, height: 7),
        .1,
        2.75,
        false,
        line,
      );
      canvas.drawArc(
        Rect.fromCenter(center: center.translate(8, -3), width: 10, height: 7),
        .1,
        2.75,
        false,
        line,
      );
      canvas.drawArc(
        Rect.fromCenter(center: center.translate(0, 8), width: 8, height: 5),
        3.35,
        2.7,
        false,
        line,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'z',
          style: TextStyle(
            color: lineColor,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(size.width - 13, 5));
    } else {
      canvas.drawCircle(
        center.translate(-8, -3),
        1.8,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        center.translate(8, -3),
        1.8,
        Paint()..color = lineColor,
      );
      canvas.drawArc(
        Rect.fromCenter(center: center.translate(0, 5), width: 13, height: 10),
        .25,
        2.65,
        false,
        line,
      );
    }

    canvas.drawArc(
      Rect.fromCenter(center: center.translate(-2, -15), width: 13, height: 9),
      3.4,
      3.7,
      false,
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _BabyFacePainter oldDelegate) =>
      oldDelegate.sleeping != sleeping ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.cheekColor != cheekColor;
}
