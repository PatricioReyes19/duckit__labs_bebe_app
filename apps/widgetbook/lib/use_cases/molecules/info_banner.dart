import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Variantes',
  type: BebeInfoBanner,
  path: '[Molecules]/Feedback',
)
Widget bebeInfoBannerVariants(BuildContext context) {
  return UseCaseFrame(
    width: 680,
    child: Column(
      children: [
        const BebeInfoBanner(
          title: 'Información neutral',
          description: 'Contenido general sin prioridad semántica.',
          icon: Icon(Icons.info_outline_rounded),
          variant: BebeInfoBannerVariant.neutral,
        ),
        const SizedBox(height: 16),
        const BebeInfoBanner(
          title: 'Información importante',
          description: 'Contenido relacionado con una acción informativa.',
          icon: Icon(Icons.notifications_none_rounded),
          variant: BebeInfoBannerVariant.brand,
        ),
        const SizedBox(height: 16),
        const BebeInfoBanner(
          title: 'Actualización disponible',
          description: 'Hay información nueva para revisar.',
          icon: Icon(Icons.update_rounded),
          variant: BebeInfoBannerVariant.information,
        ),
        const SizedBox(height: 16),
        const BebeInfoBanner(
          title: 'Operación completada',
          description: 'Los cambios se guardaron correctamente.',
          icon: Icon(Icons.check_circle_outline_rounded),
          variant: BebeInfoBannerVariant.success,
        ),
        const SizedBox(height: 16),
        const BebeInfoBanner(
          title: 'Requiere atención',
          description: 'Hay información pendiente por verificar.',
          icon: Icon(Icons.warning_amber_rounded),
          variant: BebeInfoBannerVariant.warning,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Con acción',
  type: BebeInfoBanner,
  path: '[Molecules]/Feedback',
)
Widget bebeInfoBannerWithAction(BuildContext context) {
  return UseCaseFrame(
    width: 680,
    child: BebeInfoBanner(
      title: 'Recordatorios activos',
      description: 'Te avisaremos antes de cada cita o medicación programada.',
      icon: const Icon(Icons.notifications_none_rounded),
      variant: BebeInfoBannerVariant.brand,
      action: BebeInlineAction(
        label: 'Ver ajustes',
        icon: const Icon(Icons.chevron_right_rounded),
        onPressed: () {},
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Ancho compacto',
  type: BebeInfoBanner,
  path: '[Molecules]/Feedback',
)
Widget bebeInfoBannerCompact(BuildContext context) {
  return UseCaseFrame(
    width: 320,
    child: BebeInfoBanner(
      title: 'Recordatorios activos',
      description:
          'Te avisaremos antes de cada cita programada y podrás administrarla desde los ajustes.',
      icon: const Icon(Icons.notifications_none_rounded),
      action: BebeInlineAction(
        icon: Icon(LucideIcons.chevronRight),
        label: 'Configurar',
        onPressed: () {},
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Solo descripción',
  type: BebeInfoBanner,
  path: '[Molecules]/Feedback',
)
Widget bebeInfoBannerDescriptionOnly(BuildContext context) {
  return const UseCaseFrame(
    width: 680,
    child: BebeInfoBanner(
      title: '',
      description:
          'Los antecedentes clínicos completos se encuentran disponibles en Salud.',
      icon: Icon(Icons.info_outline_rounded),
      variant: BebeInfoBannerVariant.neutral,
    ),
  );
}
