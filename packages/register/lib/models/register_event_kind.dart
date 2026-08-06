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

  static RegisterEventKind fromRouteValue(String? value) {
    if (value == 'medicine') {
      return RegisterEventKind.medication;
    }
    return RegisterEventKind.values.firstWhere(
      (kind) => kind.routeValue == value,
      orElse: () => RegisterEventKind.feeding,
    );
  }
}
