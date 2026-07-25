import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class ColorConverter implements JsonConverter<Color, String> {
  const ColorConverter();

  @override
  Color fromJson(String json) {
    final normalized = json.trim().replaceFirst('#', '');

    if (normalized.length == 6) {
      return Color(
        int.parse('FF$normalized', radix: 16),
      );
    }

    if (normalized.length == 8) {
      final red = normalized.substring(0, 2);
      final green = normalized.substring(2, 4);
      final blue = normalized.substring(4, 6);
      final alpha = normalized.substring(6, 8);

      return Color(
        int.parse('$alpha$red$green$blue', radix: 16),
      );
    }

    throw FormatException(
      'Formato de color inválido: "$json". '
      'Utiliza #RRGGBB o #RRGGBBAA.',
    );
  }

  @override
  String toJson(Color color) {
    final red = (color.r * 255).round();
    final green = (color.g * 255).round();
    final blue = (color.b * 255).round();
    final alpha = (color.a * 255).round();

    final rgb = '${_toHex(red)}'
        '${_toHex(green)}'
        '${_toHex(blue)}';

    if (alpha == 255) {
      return '#$rgb';
    }

    return '#$rgb${_toHex(alpha)}';
  }

  String _toHex(int value) {
    return value.clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
  }
}
