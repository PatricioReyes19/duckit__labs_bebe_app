import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reuses generated ThemeData for an unchanged token set', () {
    final file = [
      File('assets/json/bebe_theme.json'),
      File('packages/design_system/assets/json/bebe_theme.json'),
    ].firstWhere((candidate) => candidate.existsSync());
    final theme = BebeTheme.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );

    expect(identical(theme.lightTheme(), theme.lightTheme()), isTrue);
    expect(identical(theme.darkTheme(), theme.darkTheme()), isTrue);
  });
}
