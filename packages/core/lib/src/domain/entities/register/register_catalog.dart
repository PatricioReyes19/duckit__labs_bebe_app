/// Domain values accepted by the register-event forms.
///
/// Labels and icons remain in presentation because they can be localized or
/// redesigned without changing the stored values.
abstract final class RegisterCatalog {
  static const durationMinutes = <int>[5, 10, 15, 20, 30, 45, 60, 90, 120];

  static const medicationUnits = <String>['mL', 'mg', 'g', 'gotas'];

  static const medicationFrequencies = <String>[
    'Una vez',
    'Cada 4 horas',
    'Cada 6 horas',
    'Cada 8 horas',
    'Cada 12 horas',
    'Una vez al día',
  ];
}
