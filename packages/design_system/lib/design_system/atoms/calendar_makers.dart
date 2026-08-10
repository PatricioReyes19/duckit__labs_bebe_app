import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeCalendarMarkers extends StatelessWidget {
  const BebeCalendarMarkers({
    required this.markers,
    this.maximumVisibleMarkers = 3,
    this.markerSize = 5,
    this.markerSpacing = 3,
    this.reservedHeight = 6,
    super.key,
  }) : assert(
         maximumVisibleMarkers > 0,
         'maximumVisibleMarkers must be greater than zero.',
       );

  final List<BebeCalendarMarkerData> markers;

  final int maximumVisibleMarkers;
  final double markerSize;
  final double markerSpacing;
  final double reservedHeight;

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      return SizedBox(height: reservedHeight);
    }

    final visibleMarkers = markers
        .take(maximumVisibleMarkers)
        .toList(growable: false);

    return SizedBox(
      height: reservedHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < visibleMarkers.length; index++) ...[
            ExcludeSemantics(
              child: SizedBox.square(
                dimension: markerSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: visibleMarkers[index].color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            if (index != visibleMarkers.length - 1)
              SizedBox(width: markerSpacing),
          ],
        ],
      ),
    );
  }
}
