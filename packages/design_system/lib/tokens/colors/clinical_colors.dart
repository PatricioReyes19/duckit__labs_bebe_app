import 'package:flutter/material.dart';

class ClinicalColors {
  const ClinicalColors(this._colors);

  final Map<String, Color> _colors;

  Color get feedingSurface => _get('clinical-feeding-surface');
  Color get feedingContent => _get('clinical-feeding-content');
  Color get feedingAccent => _get('clinical-feeding-accent');

  Color get sleepSurface => _get('clinical-sleep-surface');
  Color get sleepContent => _get('clinical-sleep-content');
  Color get sleepAccent => _get('clinical-sleep-accent');

  Color get diaperSurface => _get('clinical-diaper-surface');
  Color get diaperContent => _get('clinical-diaper-content');
  Color get diaperAccent => _get('clinical-diaper-accent');

  Color get observationSurface => _get('clinical-observation-surface');
  Color get observationContent => _get('clinical-observation-content');
  Color get observationAccent => _get('clinical-observation-accent');

  Color get medicationSurface => _get('clinical-medication-surface');
  Color get medicationContent => _get('clinical-medication-content');
  Color get medicationAccent => _get('clinical-medication-accent');

  Color get measurementSurface => _get('clinical-measurement-surface');
  Color get measurementContent => _get('clinical-measurement-content');
  Color get measurementAccent => _get('clinical-measurement-accent');

  Color get healthSurface => _get('clinical-health-surface');
  Color get healthContent => _get('clinical-health-content');
  Color get healthAccent => _get('clinical-health-accent');

  Color get vaccineSurface => _get('clinical-vaccine-surface');
  Color get vaccineContent => _get('clinical-vaccine-content');
  Color get vaccineAccent => _get('clinical-vaccine-accent');

  Color get growthSurface => _get('clinical-growth-surface');
  Color get growthContent => _get('clinical-growth-content');
  Color get growthAccent => _get('clinical-growth-accent');

  Color _get(String key) => _colors[key] ?? Colors.transparent;
}
