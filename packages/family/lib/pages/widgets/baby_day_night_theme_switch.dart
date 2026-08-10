import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BabyDayNightThemeSwitch extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final trackColor = isDark
        ? colors.background.accentSurface
        : colors.background.warningSurface;
    final trackBorder = isDark
        ? colors.border.accentAlternative
        : colors.border.warningDefault;

    return Semantics(
      container: true,
      label: 'Tema visual. Bebé despierto para claro, bebé dormido para oscuro',
      toggled: isDark,
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
                isDark
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
                  onTap: () => onChanged(!isDark),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
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
                                  selected: !isDark,
                                ),
                              ),
                              Expanded(
                                child: _ModeLabel(
                                  label: 'Dormido',
                                  icon: Icons.nightlight_round,
                                  selected: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutBack,
                          alignment: isDark
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: SizedBox.square(
                            dimension: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.background.neutralsSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? colors.border.accentAlternative
                                      : colors.border.warningDefault,
                                ),
                                boxShadow: theme.elevation.low,
                              ),
                              child: CustomPaint(
                                painter: _BabyFacePainter(
                                  sleeping: isDark,
                                  lineColor: isDark
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
                  onPressed: followsSystem ? null : onUseSystem,
                  icon: Icon(
                    followsSystem
                        ? Icons.check_circle_rounded
                        : Icons.settings_suggest_outlined,
                  ),
                  label: Text(
                    followsSystem
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
