/// Visual categories available in the register-event package.
enum RegisterEventKind {
  feeding,
  sleep,
  diaper,
  observation,
  medication,
  measurement,
  ;

  String get routeValue => switch (this) {
        RegisterEventKind.feeding => 'feeding',
        RegisterEventKind.sleep => 'sleep',
        RegisterEventKind.diaper => 'diaper',
        RegisterEventKind.observation => 'observation',
        RegisterEventKind.medication => 'medication',
        RegisterEventKind.measurement => 'measurement',
      };

  static RegisterEventKind fromRouteValue(String? value) =>
      tryFromRouteValue(value) ?? RegisterEventKind.feeding;

  static RegisterEventKind? tryFromRouteValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'medicine') {
      return RegisterEventKind.medication;
    }

    for (final kind in RegisterEventKind.values) {
      if (kind.routeValue == normalized) {
        return kind;
      }
    }
    return null;
  }
}
