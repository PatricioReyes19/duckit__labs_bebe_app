import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';

Future<BebeTheme> loadBebeTheme() async {
  try {
    final response = await rootBundle.loadString(
      'packages/design_system/assets/json/bebe_theme.json',
    );

    final themeJson = json.decode(response) as Map<String, dynamic>;

    return BebeTheme.fromJson(themeJson);
  } on Object catch (error) {
    throw Exception('Error al cargar el tema BebéApp: $error');
  }
}
