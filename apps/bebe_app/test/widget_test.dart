import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el harness de la aplicación está disponible', () {
    expect(TestWidgetsFlutterBinding.ensureInitialized(), isNotNull);
  });
}
