import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/use_case_frame.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: BebeStatusBanner,
  path: '[Moleculas]/Feedback',
)
Widget bebeStatusBannerPlayground(BuildContext context) {
  final type = context.knobs.object.dropdown<BebeStatusBannerType>(
    label: 'Tipo',
    options: BebeStatusBannerType.values,
    initialOption: BebeStatusBannerType.information,
    labelBuilder: (value) => value.name,
  );

  final title = context.knobs.string(
    label: 'Título',
    initialValue: 'Última toma hace 2 h 10 min',
  );

  final description = context.knobs.stringOrNull(
    label: 'Descripción',
    initialValue: 'Sugerido cada 2–3 horas',
  );

  return UseCaseFrame(
    child: BebeStatusBanner(
      title: title,
      description: description,
      type: type,
      leading: const Icon(Icons.schedule_outlined),
      trailing: const Icon(Icons.info_outline_rounded),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Estados de sincronización',
  type: BebeStatusBanner,
  path: '[Moleculas]/Offline-first',
)
Widget bebeStatusBannerSyncStates(BuildContext context) {
  return UseCaseFrame(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        BebeStatusBanner(
          title: 'Guardado localmente',
          description: 'Se sincronizará cuando haya conexión.',
          type: BebeStatusBannerType.offline,
          leading: Icon(Icons.cloud_done_outlined),
        ),
        SizedBox(height: 16),
        BebeStatusBanner(
          title: 'Sincronizando',
          description: 'Estamos enviando el registro.',
          type: BebeStatusBannerType.syncing,
          leading: Icon(Icons.cloud_sync_outlined),
        ),
        SizedBox(height: 16),
        BebeStatusBanner(
          title: 'No pudimos sincronizar',
          description: 'Revisa tu conexión e inténtalo nuevamente.',
          type: BebeStatusBannerType.error,
          leading: Icon(Icons.cloud_off_outlined),
        ),
      ],
    ),
  );
}
