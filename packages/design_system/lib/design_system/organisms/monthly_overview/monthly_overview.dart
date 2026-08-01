import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeAgendaMonthlyOverview extends StatelessWidget {
  const BebeAgendaMonthlyOverview({
    required this.calendar,
    required this.nextEvent,
    this.title = 'Próximo en tu agenda',
    this.semanticLabel,
    super.key,
  });

  /// Normalmente recibe [BebeMonthCalendar].
  final Widget calendar;

  /// Normalmente recibe [BebeEventPreview].
  final Widget nextEvent;

  final String title;
  final String? semanticLabel;

  static const double _horizontalLayoutBreakpoint = 340;
  static const int _calendarFlex = 11;
  static const int _eventFlex = 10;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final radius = theme.borderRadius;
    final elevation = theme.elevation;
    final colors = theme.colors;

    final card = Material(
      color: colors.background.neutralsSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.radius3xl),
        side: BorderSide(color: colors.border.accentAlternative),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(spacing.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BebeTitleSection(title: title),
            SizedBox(height: spacing.spacingL),
            LayoutBuilder(
              builder: (context, constraints) {
                final useHorizontalLayout =
                    constraints.maxWidth >= _horizontalLayoutBreakpoint;

                if (!useHorizontalLayout) {
                  return _AgendaMonthlyVerticalLayout(
                    calendar: calendar,
                    nextEvent: nextEvent,
                  );
                }

                return _AgendaMonthlyHorizontalLayout(
                  calendar: calendar,
                  nextEvent: nextEvent,
                );
              },
            ),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel ?? title,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.radius3xl),
            boxShadow: elevation.low,
          ),
          child: card,
        ),
      ),
    );
  }
}

class _AgendaMonthlyHorizontalLayout extends StatelessWidget {
  const _AgendaMonthlyHorizontalLayout({
    required this.calendar,
    required this.nextEvent,
  });

  final Widget calendar;
  final Widget nextEvent;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: BebeAgendaMonthlyOverview._calendarFlex,
          child: calendar,
        ),
        SizedBox(width: spacing.spacingL),
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 1,
            height: 220,
            child: ColoredBox(color: colors.border.accentAlternative),
          ),
        ),
        SizedBox(width: spacing.spacingL),
        Expanded(flex: BebeAgendaMonthlyOverview._eventFlex, child: nextEvent),
      ],
    );
  }
}

class _AgendaMonthlyVerticalLayout extends StatelessWidget {
  const _AgendaMonthlyVerticalLayout({
    required this.calendar,
    required this.nextEvent,
  });

  final Widget calendar;
  final Widget nextEvent;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        calendar,
        SizedBox(height: spacing.spacingXl),
        Divider(
          height: 1,
          thickness: 1,
          color: colors.border.accentAlternative,
        ),
        SizedBox(height: spacing.spacingXl),
        nextEvent,
      ],
    );
  }
}
