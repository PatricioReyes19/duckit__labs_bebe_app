import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Iniciales',
  type: BebeAvatar,
  path: '[Átomos]/Identidad',
)
Widget bebeAvatarInitials(BuildContext context) {
  final name = context.knobs.string(
    label: 'Nombre',
    initialValue: 'Mateo Reyes',
  );

  final size = context.knobs.object.dropdown<BebeAvatarSize>(
    label: 'Tamaño',
    options: BebeAvatarSize.values,
    initialOption: BebeAvatarSize.lg,
    labelBuilder: (value) => value.name,
  );

  return UseCaseFrame(
    child: BebeAvatar.initials(
      initials: name,
      size: size,
      semanticLabel: 'Avatar de $name',
    ),
  );
}

@widgetbook.UseCase(
  name: 'Fallback',
  type: BebeAvatar,
  path: '[Átomos]/Identidad',
)
Widget bebeAvatarFallback(BuildContext context) {
  return const UseCaseFrame(
    child: BebeAvatar.fallback(
      size: BebeAvatarSize.xl,
      semanticLabel: 'Avatar sin imagen',
    ),
  );
}

@widgetbook.UseCase(
  name: 'Escala completa',
  type: BebeAvatar,
  path: '[Átomos]/Identidad',
)
Widget bebeAvatarSizes(BuildContext context) {
  return UseCaseFrame(
    child: Wrap(
      spacing: 20,
      runSpacing: 20,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final size in BebeAvatarSize.values)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BebeAvatar.initials(
                initials: 'Mateo Reyes',
                size: size,
              ),
              const SizedBox(height: 8),
              Text(size.name),
            ],
          ),
      ],
    ),
  );
}
