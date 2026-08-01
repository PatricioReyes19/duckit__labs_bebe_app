import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeMonthCalendarDay extends StatelessWidget {
  const BebeMonthCalendarDay({
    required this.day,
    this.markers = const [],
    this.isSelected = false,
    this.isToday = false,
    this.isOutside = false,
    this.isDisabled = false,
    super.key,
  });

  final DateTime day;
  final List<BebeCalendarMarkerData> markers;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final bool isDisabled;

  static const double _selectedDaySize = 30;
  static const double _todayBorderWidth = 1;
  static const double _markerSize = 4;
  static const double _markerSpacing = 2;
  static const double _markersHeight = 5;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final typography = theme.typography;
    final colors = theme.colors;

    final contentColor = _resolveContentColor(colors: colors);

    final dayContent = SizedBox.square(
      dimension: _selectedDaySize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? colors.background.brandDefault
              : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(
                  color: colors.border.brandAlternative,
                  width: _todayBorderWidth,
                )
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            maxLines: 1,
            softWrap: false,
            style: typography.styles.label.sm.regular.copyWith(
              color: contentColor,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      selected: isSelected,
      enabled: !isDisabled,
      label: _buildSemanticLabel(),
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dayContent,
            BebeCalendarMarkers(
              markers: markers,
              maximumVisibleMarkers: 3,
              markerSize: _markerSize,
              markerSpacing: _markerSpacing,
              reservedHeight: _markersHeight,
            ),
          ],
        ),
      ),
    );
  }

  Color _resolveContentColor({required dynamic colors}) {
    if (isDisabled || isOutside) {
      return colors.text.neutralDisabled;
    }

    if (isSelected) {
      return colors.background.neutralsSurface;
    }

    return colors.text.neutralTitle;
  }

  String _buildSemanticLabel() {
    final parts = <String>[
      '${day.day}',
      if (isToday) 'Hoy',
      if (markers.isNotEmpty)
        '${markers.length} ${markers.length == 1 ? 'evento' : 'eventos'}',
      if (isSelected) 'Seleccionado',
      if (isDisabled) 'No disponible',
    ];

    return parts.join('. ');
  }
}
