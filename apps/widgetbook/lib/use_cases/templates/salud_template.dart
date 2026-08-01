import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// ---------------------------------------------------------------------------
/// USE CASES
/// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Consulta completa',
  type: BebeConsultationDetailTemplate,
  path: '[Templates]/Salud',
)
Widget bebeConsultationDetailTemplateComplete(
  BuildContext context,
) {
  return const _ConsultationDetailExample();
}

@widgetbook.UseCase(
  name: 'Ancho móvil',
  type: BebeConsultationDetailTemplate,
  path: '[Templates]/Salud',
)
Widget bebeConsultationDetailTemplateMobile(
  BuildContext context,
) {
  return const Center(
    child: SizedBox(
      width: 390,
      height: 844,
      child: _ConsultationDetailExample(),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Contenido extenso',
  type: BebeConsultationDetailTemplate,
  path: '[Templates]/Salud',
)
Widget bebeConsultationDetailTemplateLongContent(
  BuildContext context,
) {
  return const _ConsultationDetailExample(
    useLongContent: true,
  );
}

@widgetbook.UseCase(
  name: 'Solo información',
  type: BebeConsultationDetailTemplate,
  path: '[Templates]/Salud',
)
Widget bebeConsultationDetailTemplateReadOnly(
  BuildContext context,
) {
  return const _ConsultationDetailExample(
    interactive: false,
  );
}

/// ---------------------------------------------------------------------------
/// FIXTURE PRINCIPAL
/// ---------------------------------------------------------------------------

class _ConsultationDetailExample extends StatefulWidget {
  const _ConsultationDetailExample({
    this.useLongContent = false,
    this.interactive = true,
  });

  final bool useLongContent;
  final bool interactive;

  @override
  State<_ConsultationDetailExample> createState() {
    return _ConsultationDetailExampleState();
  }
}

class _ConsultationDetailExampleState
    extends State<_ConsultationDetailExample> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.colors.background.neutralsSurface,
      child: BebeConsultationDetailTemplate(
        semanticLabel: 'Detalle de consulta pediátrica',
        header: _buildHeader(),
        summary: _buildSummary(),
        evaluation: _buildEvaluation(),
        treatment: _buildTreatment(),
        followUp: _buildFollowUp(),
        monitoring: _buildMonitoring(),
        attachments: _buildAttachments(),
      ),
    );
  }

  Widget _buildHeader() {
    return BebePageHeader(
      title: 'Detalle de consulta',
      alignment: BebePageHeaderAlignment.center,
      leading: BebeNavigationIconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
        ),
        semanticLabel: 'Volver',
        size: BebeNavigationIconButtonSize.large,
        showSurface: false,
        onPressed: widget.interactive ? () => _showInteraction('Volver') : null,
      ),
      trailing: BebeNavigationIconButton(
        icon: const Icon(
          Icons.more_horiz_rounded,
        ),
        semanticLabel: 'Más opciones',
        size: BebeNavigationIconButtonSize.large,
        showSurface: false,
        onPressed:
            widget.interactive ? () => _showInteraction('Más opciones') : null,
      ),
    );
  }

  Widget _buildSummary() {
    return BebeDetailSummaryCard(
      semanticLabel: 'Resumen de la consulta',
      items: [
        BebeDetailSummaryItem(
          icon: Icon(
            Icons.calendar_today_outlined,
          ),
          label: 'Fecha de consulta',
          value: '15 may 2025',
          semanticLabel: 'Fecha de consulta. 15 de mayo de 2025',
        ),
        BebeDetailSummaryItem(
          icon: Icon(
            Icons.schedule_outlined,
          ),
          label: 'Hora',
          value: '10:00',
          semanticLabel: 'Hora de la consulta. 10 de la mañana',
        ),
        BebeDetailSummaryItem(
          icon: Icon(
            Icons.medical_services_outlined,
          ),
          label: 'Pediatra',
          value: 'Dra. Valeria Ruiz',
          supportingText: 'Pediatra',
          semanticLabel: 'Pediatra. Doctora Valeria Ruiz',
        ),
      ],
    );
  }

  Widget _buildEvaluation() {
    final description = widget.useLongContent
        ? 'El bebé está creciendo adecuadamente y presenta una evolución '
            'favorable de acuerdo con su edad, peso, talla y antecedentes '
            'registrados durante la consulta.'
        : 'El bebé está creciendo adecuadamente.';

    return BebeDetailActionCard(
      title: 'Evaluación',
      description: description,
      icon: const Icon(
        Icons.assignment_turned_in_outlined,
      ),
      variant: BebeDetailActionCardVariant.success,
      onPressed: null,
    );
  }

  Widget _buildTreatment() {
    final description = widget.useLongContent
        ? 'Aplicar crema hipoalergénica dos veces al día, mantener la piel '
            'hidratada y evitar productos con fragancias durante el periodo '
            'indicado por la pediatra.'
        : 'Hidratación de la piel 2 veces al día con crema hipoalergénica.';

    return BebeDetailActionCard(
      title: 'Tratamiento',
      description: description,
      icon: const Icon(
        Icons.medication_outlined,
      ),
      variant: BebeDetailActionCardVariant.warning,
      onPressed:
          widget.interactive ? () => _showInteraction('Tratamiento') : null,
    );
  }

  Widget _buildFollowUp() {
    return BebeDetailActionCard(
      title: 'Seguimiento',
      description: 'Próximo control',
      metadata: '12 jun 2025 · 11:30',
      icon: const Icon(
        Icons.calendar_month_outlined,
      ),
      variant: BebeDetailActionCardVariant.information,
      onPressed:
          widget.interactive ? () => _showInteraction('Seguimiento') : null,
    );
  }

  Widget _buildMonitoring() {
    final description = widget.useLongContent
        ? 'Observar si la erupción aumenta de tamaño, cambia de color, '
            'se extiende a otras zonas o si aparece fiebre, malestar general '
            'o cambios en la alimentación.'
        : 'Observar si la erupción se extiende o si aparece fiebre.';

    return BebeDetailActionCard(
      title: 'Vigilancia',
      description: description,
      icon: const Icon(
        Icons.notifications_active_outlined,
      ),
      variant: BebeDetailActionCardVariant.accent,
      onPressed: null,
    );
  }

  Widget _buildAttachments() {
    return BebeDetailActionCard(
      title: 'Adjuntos y observaciones',
      description: '2 adjuntos · 1 observación',
      icon: const Icon(
        Icons.attach_file_rounded,
      ),
      variant: BebeDetailActionCardVariant.brand,
      onPressed: widget.interactive
          ? () => _showInteraction(
                'Adjuntos y observaciones',
              )
          : null,
    );
  }

  void _showInteraction(String action) {
    final messenger = ScaffoldMessenger.maybeOf(
      context,
    );

    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Acción: $action',
          ),
          duration: const Duration(
            milliseconds: 900,
          ),
        ),
      );
  }
}

/// ---------------------------------------------------------------------------
/// USE CASES INDIVIDUALES: RESUMEN
/// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Resumen de consulta',
  type: BebeDetailSummaryCard,
  path: '[Molecules]/Information',
)
Widget bebeDetailSummaryCardDefault(
  BuildContext context,
) {
  return _ComponentFrame(
    child: BebeDetailSummaryCard(
      items: [
        BebeDetailSummaryItem(
          icon: Icon(
            Icons.calendar_today_outlined,
          ),
          label: 'Fecha de consulta',
          value: '15 may 2025',
        ),
        BebeDetailSummaryItem(
          icon: Icon(
            Icons.schedule_outlined,
          ),
          label: 'Hora',
          value: '10:00',
        ),
        BebeDetailSummaryItem(
          icon: Icon(
            Icons.medical_services_outlined,
          ),
          label: 'Pediatra',
          value: 'Dra. Valeria Ruiz',
          supportingText: 'Pediatra',
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Valores extensos',
  type: BebeDetailSummaryCard,
  path: '[Molecules]/Information',
)
Widget bebeDetailSummaryCardLongValues(
  BuildContext context,
) {
  return _ComponentFrame(
    width: 340,
    child: BebeDetailSummaryCard(
      items: [
        BebeDetailSummaryItem(
          icon: Icon(
            Icons.calendar_today_outlined,
          ),
          label: 'Fecha de consulta',
          value: 'Miércoles, 15 de mayo de 2025',
        ),
        BebeDetailSummaryItem(
          icon: Icon(
            Icons.medical_services_outlined,
          ),
          label: 'Profesional responsable',
          value: 'Dra. Valeria Fernanda Ruiz',
          supportingText: 'Especialista en pediatría general',
        ),
      ],
    ),
  );
}

/// ---------------------------------------------------------------------------
/// USE CASES INDIVIDUALES: ACTION CARD
/// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Variantes',
  type: BebeDetailActionCard,
  path: '[Molecules]/Cards',
)
Widget bebeDetailActionCardVariants(
  BuildContext context,
) {
  return _ComponentFrame(
    width: 680,
    child: Column(
      children: [
        const BebeDetailActionCard(
          title: 'Información general',
          description: 'Contenido informativo sin acción asociada.',
          icon: Icon(
            Icons.info_outline_rounded,
          ),
          variant: BebeDetailActionCardVariant.neutral,
        ),
        const SizedBox(height: 12),
        BebeDetailActionCard(
          title: 'Adjuntos y observaciones',
          description: '2 adjuntos · 1 observación',
          icon: const Icon(
            Icons.attach_file_rounded,
          ),
          variant: BebeDetailActionCardVariant.brand,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        const BebeDetailActionCard(
          title: 'Vigilancia',
          description: 'Observar si aparecen nuevos síntomas.',
          icon: Icon(
            Icons.notifications_active_outlined,
          ),
          variant: BebeDetailActionCardVariant.accent,
        ),
        const SizedBox(height: 12),
        BebeDetailActionCard(
          title: 'Seguimiento',
          description: 'Próximo control',
          metadata: '12 jun 2025 · 11:30',
          icon: const Icon(
            Icons.calendar_month_outlined,
          ),
          variant: BebeDetailActionCardVariant.information,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        BebeDetailActionCard(
          title: 'Tratamiento',
          description: 'Aplicar crema hipoalergénica dos veces al día.',
          icon: const Icon(
            Icons.medication_outlined,
          ),
          variant: BebeDetailActionCardVariant.warning,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        const BebeDetailActionCard(
          title: 'Evaluación',
          description: 'El bebé está creciendo adecuadamente.',
          icon: Icon(
            Icons.assignment_turned_in_outlined,
          ),
          variant: BebeDetailActionCardVariant.success,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Interactiva',
  type: BebeDetailActionCard,
  path: '[Molecules]/Cards',
)
Widget bebeDetailActionCardInteractive(
  BuildContext context,
) {
  return _ComponentFrame(
    child: BebeDetailActionCard(
      title: 'Tratamiento',
      description: 'Hidratación de la piel 2 veces al día.',
      icon: const Icon(
        Icons.medication_outlined,
      ),
      variant: BebeDetailActionCardVariant.warning,
      onPressed: () {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'Abrir tratamiento',
            ),
          ),
        );
      },
    ),
  );
}

@widgetbook.UseCase(
  name: 'Informativa sin chevron',
  type: BebeDetailActionCard,
  path: '[Molecules]/Cards',
)
Widget bebeDetailActionCardInformative(
  BuildContext context,
) {
  return const _ComponentFrame(
    child: BebeDetailActionCard(
      title: 'Vigilancia',
      description: 'Observar si la erupción se extiende o si aparece fiebre.',
      icon: Icon(
        Icons.notifications_active_outlined,
      ),
      variant: BebeDetailActionCardVariant.accent,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Contenido extenso',
  type: BebeDetailActionCard,
  path: '[Molecules]/Cards',
)
Widget bebeDetailActionCardLongContent(
  BuildContext context,
) {
  return const _ComponentFrame(
    width: 340,
    child: BebeDetailActionCard(
      title: 'Evaluación y recomendaciones generales',
      description: 'El bebé está creciendo adecuadamente de acuerdo con los '
          'antecedentes registrados. Se recomienda mantener la rutina '
          'actual de alimentación, sueño y cuidados diarios.',
      metadata: 'Información registrada durante la consulta pediátrica.',
      icon: Icon(
        Icons.assignment_turned_in_outlined,
      ),
      variant: BebeDetailActionCardVariant.success,
    ),
  );
}

/// ---------------------------------------------------------------------------
/// FRAME PRIVADO DE WIDGETBOOK
///
/// No debe exportarse desde el Design System.
/// ---------------------------------------------------------------------------

class _ComponentFrame extends StatelessWidget {
  const _ComponentFrame({
    required this.child,
    this.width = 430,
  });

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Material(
      color: context.theme.colors.background.neutralsSurface,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            spacing.spacingXl,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
