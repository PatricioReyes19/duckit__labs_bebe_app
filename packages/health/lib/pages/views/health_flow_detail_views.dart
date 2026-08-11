import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:health/models/health_flow_controller.dart';
import 'package:health/pages/health_section_page.dart';
import 'package:health/pages/views/health_flow_widgets.dart';
import 'package:health/pages/views/health_section_views.dart';
import 'package:health/services/health_report_exporter.dart';

class HealthFlowDetailView extends StatelessWidget {
  const HealthFlowDetailView({
    required this.kind,
    required this.action,
    required this.controller,
    required this.openFlow,
    super.key,
  });

  final HealthSectionKind kind;
  final String action;
  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    if (action == HealthFlowAction.sync) {
      return SyncSectionView(controller: controller, openFlow: openFlow);
    }
    if (action == HealthFlowAction.reports) {
      return ReportsSectionView(controller: controller, openFlow: openFlow);
    }
    if (action == HealthFlowAction.history) {
      return ClinicalHistorySectionView(
        controller: controller,
        openFlow: openFlow,
      );
    }
    if (action == HealthFlowAction.export) {
      return _ExportReportView(controller: controller, openFlow: openFlow);
    }
    if (action == HealthFlowAction.exported) {
      return _ExportedReportView(controller: controller, openFlow: openFlow);
    }
    if (action == HealthFlowAction.observation) {
      return _ObservationForm(controller: controller, openFlow: openFlow);
    }
    if (action == HealthFlowAction.compare) {
      return _ComparePediatriciansView(openFlow: openFlow);
    }
    if (action == HealthFlowAction.success) {
      return _HealthSavedView(
        kind: kind,
        controller: controller,
        openFlow: openFlow,
      );
    }
    if (action == HealthFlowAction.detail) {
      return _HealthRecordDetailView(
        kind: kind,
        controller: controller,
        openFlow: openFlow,
      );
    }
    if (kind == HealthSectionKind.vaccines &&
        action == HealthFlowAction.register) {
      return _VaccinationForm(controller: controller, openFlow: openFlow);
    }
    if (kind == HealthSectionKind.growth &&
        (action == HealthFlowAction.registerWeight ||
            action == HealthFlowAction.registerHeight ||
            action == HealthFlowAction.register)) {
      return _MeasurementForm(
        controller: controller,
        openFlow: openFlow,
        type: action == HealthFlowAction.registerHeight
            ? HealthMeasurementType.height
            : HealthMeasurementType.weight,
      );
    }
    if ((kind == HealthSectionKind.consultations ||
            kind == HealthSectionKind.controls) &&
        action == HealthFlowAction.register) {
      return _ConsultationWizard(controller: controller, openFlow: openFlow);
    }
    if (kind == HealthSectionKind.pediatricCare &&
        action == HealthFlowAction.register) {
      return _PediatricianForm(openFlow: openFlow);
    }
    return _HealthRecordDetailView(
      kind: kind,
      controller: controller,
      openFlow: openFlow,
    );
  }
}

class _VaccinationForm extends StatefulWidget {
  const _VaccinationForm({required this.controller, required this.openFlow});

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  State<_VaccinationForm> createState() => _VaccinationFormState();
}

class _VaccinationFormState extends State<_VaccinationForm> {
  final formKey = GlobalKey<FormState>();
  final vaccine = TextEditingController(text: 'Neumococo');
  final dose = TextEditingController(text: '2da dosis');
  final location = TextEditingController(text: 'CESFAM Cien Águilas');
  final professional = TextEditingController();
  final lot = TextEditingController();
  final notes = TextEditingController();
  DateTime occurredAt = DateTime.now();
  bool busy = false;

  @override
  void dispose() {
    vaccine.dispose();
    dose.dispose();
    location.dispose();
    professional.dispose();
    lot.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          HealthBabyBanner(controller: widget.controller),
          const SizedBox(height: 20),
          const HealthSectionHeading(
            title: 'Registrar aplicación',
            subtitle: 'Completa los datos del comprobante de vacunación.',
          ),
          const SizedBox(height: 16),
          HealthSurface(
            child: Column(
              children: [
                TextFormField(
                  controller: vaccine,
                  decoration: const InputDecoration(
                    labelText: 'Vacuna',
                    prefixIcon: Icon(Icons.vaccines_outlined),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: dose,
                  decoration: const InputDecoration(
                    labelText: 'Dosis',
                    prefixIcon: Icon(Icons.format_list_numbered_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                _DateTimeField(
                  value: occurredAt,
                  onChanged: (value) => setState(() => occurredAt = value),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: location,
                  decoration: const InputDecoration(
                    labelText: 'Lugar de aplicación',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: professional,
                  decoration: const InputDecoration(
                    labelText: 'Profesional (opcional)',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: lot,
                  decoration: const InputDecoration(
                    labelText: 'Lote / N.º de serie (opcional)',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: notes,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones o reacciones',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          HealthSurface(
            child: Row(
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Adjuntar comprobante (opcional)')),
                TextButton(
                  onPressed: () => _notAvailable(context),
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          HealthPrimaryButton(
            label: 'Guardar registro',
            icon: Icons.save_outlined,
            busy: busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => busy = true);
    try {
      await widget.controller.saveVaccination(
        vaccineName: vaccine.text,
        dose: dose.text,
        occurredAt: occurredAt,
        location: location.text,
        professional: professional.text,
        lot: lot.text,
        notes: notes.text,
      );
      if (mounted) widget.openFlow(HealthFlowAction.success);
    } on Object catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _MeasurementForm extends StatefulWidget {
  const _MeasurementForm({
    required this.controller,
    required this.openFlow,
    required this.type,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;
  final HealthMeasurementType type;

  @override
  State<_MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends State<_MeasurementForm> {
  final formKey = GlobalKey<FormState>();
  final value = TextEditingController();
  final notes = TextEditingController();
  DateTime occurredAt = DateTime.now();
  bool busy = false;

  @override
  void dispose() {
    value.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weight = widget.type == HealthMeasurementType.weight;
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          HealthBabyBanner(controller: widget.controller),
          const SizedBox(height: 22),
          HealthSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HealthSectionHeading(
                  title: weight ? 'Registrar peso' : 'Registrar talla',
                  subtitle: 'La medición quedará en la curva de crecimiento.',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: value,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: weight ? 'Peso' : 'Talla',
                    suffixText: weight ? 'kg' : 'cm',
                    prefixIcon: Icon(
                      weight
                          ? Icons.monitor_weight_outlined
                          : Icons.straighten_rounded,
                    ),
                  ),
                  validator: (text) {
                    final parsed = double.tryParse(
                      (text ?? '').replaceAll(',', '.'),
                    );
                    return parsed == null || parsed <= 0
                        ? 'Ingresa una medición válida.'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                _DateTimeField(
                  value: occurredAt,
                  onChanged: (newValue) =>
                      setState(() => occurredAt = newValue),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notes,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          HealthPrimaryButton(
            label: 'Guardar medición',
            icon: Icons.save_outlined,
            busy: busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => busy = true);
    try {
      await widget.controller.saveMeasurement(
        type: widget.type,
        value: double.parse(value.text.replaceAll(',', '.')),
        occurredAt: occurredAt,
        notes: notes.text,
      );
      if (mounted) widget.openFlow(HealthFlowAction.success);
    } on Object catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _ConsultationWizard extends StatefulWidget {
  const _ConsultationWizard({required this.controller, required this.openFlow});

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  State<_ConsultationWizard> createState() => _ConsultationWizardState();
}

class _ConsultationWizardState extends State<_ConsultationWizard> {
  final formKey = GlobalKey<FormState>();
  final pediatrician = TextEditingController(text: 'Dra. Valeria Ruiz');
  final reason = TextEditingController(text: 'Control pediátrico');
  final summary = TextEditingController();
  final treatment = TextEditingController();
  final followUp = TextEditingController();
  final vigilance = TextEditingController();
  final notes = TextEditingController();
  DateTime occurredAt = DateTime.now();
  int step = 0;
  bool busy = false;

  @override
  void dispose() {
    pediatrician.dispose();
    reason.dispose();
    summary.dispose();
    treatment.dispose();
    followUp.dispose();
    vigilance.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            children: [
              for (var index = 0; index < 3; index++) ...[
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: index <= step
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                        foregroundColor: index <= step
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        const ['Datos', 'Indicaciones', 'Resumen'][index],
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Divider(
                      color: index < step
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          if (step == 0)
            _basicStep()
          else if (step == 1)
            _indicationsStep()
          else
            _summaryStep(),
          const SizedBox(height: 20),
          Row(
            children: [
              if (step > 0) ...[
                Expanded(
                  child: HealthPrimaryButton(
                    label: 'Volver',
                    outlined: true,
                    onPressed: () => setState(() => step--),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: HealthPrimaryButton(
                  label: step == 2 ? 'Guardar consulta' : 'Continuar',
                  busy: busy,
                  onPressed: step == 2 ? _save : _continue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _basicStep() => HealthSurface(
    child: Column(
      children: [
        const HealthSectionHeading(
          title: 'Datos básicos',
          subtitle: 'Ingresa la información principal de la consulta.',
        ),
        const SizedBox(height: 18),
        _DateTimeField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: pediatrician,
          decoration: const InputDecoration(
            labelText: 'Pediatra',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: _required,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: reason,
          decoration: const InputDecoration(
            labelText: 'Motivo de consulta',
            prefixIcon: Icon(Icons.medical_services_outlined),
          ),
          validator: _required,
        ),
      ],
    ),
  );

  Widget _indicationsStep() => Column(
    children: [
      _LongField(
        controller: summary,
        label: 'Lo que indicó el pediatra',
        hint: 'Diagnóstico, evaluación y recomendaciones generales.',
        icon: Icons.medical_services_outlined,
        required: true,
      ),
      const SizedBox(height: 12),
      _LongField(
        controller: treatment,
        label: 'Tratamiento',
        hint: 'Medicamentos, cremas, baños o cuidados indicados.',
        icon: Icons.medication_outlined,
      ),
      const SizedBox(height: 12),
      _LongField(
        controller: followUp,
        label: 'Seguimiento',
        hint: 'Próximo control e indicaciones para casa.',
        icon: Icons.calendar_month_outlined,
      ),
      const SizedBox(height: 12),
      _LongField(
        controller: vigilance,
        label: 'Vigilancia',
        hint: 'Señales de alerta o síntomas que se deben observar.',
        icon: Icons.visibility_outlined,
      ),
    ],
  );

  Widget _summaryStep() => Column(
    children: [
      HealthSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HealthSectionHeading(
              title: 'Resumen de consulta',
              subtitle: 'Revisa la información antes de guardarla.',
            ),
            const Divider(height: 28),
            _SummaryLine(label: 'Fecha', value: healthDateLabel(occurredAt)),
            _SummaryLine(label: 'Hora', value: healthTimeLabel(occurredAt)),
            _SummaryLine(label: 'Pediatra', value: pediatrician.text),
            _SummaryLine(label: 'Motivo', value: reason.text),
            _SummaryLine(
              label: 'Indicaciones',
              value: summary.text.isEmpty ? 'Sin información' : summary.text,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      HealthSurface(
        child: TextFormField(
          controller: notes,
          maxLines: 3,
          maxLength: 300,
          decoration: const InputDecoration(
            labelText: 'Comentario de la experiencia (opcional)',
          ),
        ),
      ),
    ],
  );

  void _continue() {
    if (step == 0 && !(formKey.currentState?.validate() ?? false)) return;
    if (step == 1 && summary.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega el resumen de la consulta.')),
      );
      return;
    }
    setState(() => step++);
  }

  Future<void> _save() async {
    setState(() => busy = true);
    try {
      await widget.controller.saveConsultation(
        occurredAt: occurredAt,
        pediatrician: pediatrician.text,
        reason: reason.text,
        summary: summary.text,
        treatment: treatment.text,
        followUp: followUp.text,
        vigilance: vigilance.text,
        notes: notes.text,
      );
      if (mounted) widget.openFlow(HealthFlowAction.success);
    } on Object catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _ObservationForm extends StatefulWidget {
  const _ObservationForm({required this.controller, required this.openFlow});

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  State<_ObservationForm> createState() => _ObservationFormState();
}

class _ObservationFormState extends State<_ObservationForm> {
  final title = TextEditingController();
  final description = TextEditingController();
  String severity = 'mild';
  bool busy = false;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const HealthSectionHeading(
          title: 'Nueva observación clínica',
          subtitle: 'Registra síntomas o cambios relevantes para el reporte.',
        ),
        const SizedBox(height: 18),
        HealthSurface(
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: description,
                maxLines: 5,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'mild', label: Text('Leve')),
                  ButtonSegment(value: 'moderate', label: Text('Moderada')),
                  ButtonSegment(value: 'severe', label: Text('Alta')),
                ],
                selected: {severity},
                onSelectionChanged: (value) =>
                    setState(() => severity = value.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HealthPrimaryButton(
          label: 'Guardar observación',
          busy: busy,
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (title.text.trim().isEmpty || description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el título y la descripción.')),
      );
      return;
    }
    setState(() => busy = true);
    try {
      await widget.controller.saveObservation(
        title: title.text,
        description: description.text,
        severity: severity,
      );
      if (mounted) widget.openFlow(HealthFlowAction.reports);
    } on Object catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _PediatricianForm extends StatefulWidget {
  const _PediatricianForm({required this.openFlow});

  final HealthFlowNavigator openFlow;

  @override
  State<_PediatricianForm> createState() => _PediatricianFormState();
}

class _PediatricianFormState extends State<_PediatricianForm> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final specialty = TextEditingController(text: 'Pediatría general');
  final phone = TextEditingController();
  final place = TextEditingController();
  final notes = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    specialty.dispose();
    phone.dispose();
    place.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Center(
            child: CircleAvatar(
              radius: 62,
              child: IconButton(
                iconSize: 40,
                onPressed: () => _notAvailable(context),
                icon: const Icon(Icons.add_a_photo_outlined),
              ),
            ),
          ),
          const SizedBox(height: 20),
          HealthSurface(
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: specialty,
                  decoration: const InputDecoration(
                    labelText: 'Especialidad',
                    prefixIcon: Icon(Icons.medical_services_outlined),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: place,
                  decoration: const InputDecoration(
                    labelText: 'Lugar habitual (opcional)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: notes,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Notas personales (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          HealthPrimaryButton(
            label: 'Guardar pediatra',
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${name.text} se guardó en tus pediatras.'),
                ),
              );
              widget.openFlow(HealthFlowAction.detail);
            },
          ),
        ],
      ),
    );
  }
}

class _HealthSavedView extends StatelessWidget {
  const _HealthSavedView({
    required this.kind,
    required this.controller,
    required this.openFlow,
  });

  final HealthSectionKind kind;
  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon) = switch (kind) {
      HealthSectionKind.vaccines => (
        '¡Vacuna registrada!',
        'La aplicación quedó guardada en el calendario.',
        Icons.vaccines_outlined,
      ),
      HealthSectionKind.growth => (
        '¡Medición registrada!',
        'La curva de crecimiento ya incluye este dato.',
        Icons.monitor_weight_outlined,
      ),
      HealthSectionKind.consultations || HealthSectionKind.controls => (
        '¡Consulta guardada!',
        'Las indicaciones están disponibles en el historial clínico.',
        Icons.medical_information_outlined,
      ),
      _ => (
        '¡Registro guardado!',
        'La información quedó disponible en Salud.',
        Icons.check_circle_outline_rounded,
      ),
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
      children: [
        const SizedBox(height: 22),
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 84,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        HealthSurface(
          child: Row(
            children: [
              Icon(
                controller.offlineMode
                    ? Icons.cloud_queue_outlined
                    : Icons.cloud_done_outlined,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.offlineMode
                          ? 'Guardado localmente'
                          : 'Sincronización en curso',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      controller.offlineMode
                          ? 'Se sincronizará cuando vuelvas a conectarte.'
                          : 'La familia verá el cambio al finalizar.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        HealthPrimaryButton(
          label: 'Ver detalle',
          icon: Icons.description_outlined,
          onPressed: () => openFlow(HealthFlowAction.detail),
        ),
        const SizedBox(height: 12),
        HealthPrimaryButton(
          label: 'Estado de sincronización',
          outlined: true,
          onPressed: () => openFlow(HealthFlowAction.sync),
        ),
      ],
    );
  }
}

class _HealthRecordDetailView extends StatelessWidget {
  const _HealthRecordDetailView({
    required this.kind,
    required this.controller,
    required this.openFlow,
  });

  final HealthSectionKind kind;
  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    return HealthFlowBody(
      controller: controller,
      builder: (context) {
        if (kind == HealthSectionKind.pediatricCare) {
          return _pediatricianDetail(context);
        }
        if (kind == HealthSectionKind.consultations ||
            kind == HealthSectionKind.controls) {
          return _consultationDetail(context);
        }
        if (kind == HealthSectionKind.vaccines) {
          return _vaccineDetail(context);
        }
        if (kind == HealthSectionKind.growth) {
          return _measurementDetail(context);
        }
        return _clinicalDetail(context);
      },
    );
  }

  List<Widget> _vaccineDetail(BuildContext context) => [
    HealthSurface(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: const Column(
        children: [
          Icon(Icons.health_and_safety_outlined, size: 72),
          SizedBox(height: 12),
          Text(
            'Neumococo · 2da dosis',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text('Protege contra infecciones graves por neumococo.'),
        ],
      ),
    ),
    const SizedBox(height: 14),
    const HealthActionRow(
      icon: Icons.calendar_today_outlined,
      title: 'Fecha programada',
      subtitle: 'Próxima fecha recomendada',
      trailing: Text('26 may'),
    ),
    const SizedBox(height: 10),
    const HealthActionRow(
      icon: Icons.location_on_outlined,
      title: 'Lugar sugerido',
      subtitle: 'CESFAM Cien Águilas',
    ),
    const SizedBox(height: 18),
    HealthPrimaryButton(
      label: 'Registrar aplicación',
      icon: Icons.vaccines_outlined,
      onPressed: () => openFlow(HealthFlowAction.register),
    ),
  ];

  List<Widget> _measurementDetail(BuildContext context) => [
    HealthSurface(
      child: Row(
        children: [
          Icon(
            Icons.monitor_weight_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peso', style: TextStyle(fontSize: 18)),
                Text(
                  '7,25 kg',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                ),
                Text('Percentil P41'),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    const HealthActionRow(
      icon: Icons.calendar_today_outlined,
      title: 'Fecha y hora',
      subtitle: '16 may 2025 · 10:30',
    ),
    const SizedBox(height: 10),
    const HealthActionRow(
      icon: Icons.person_outline_rounded,
      title: 'Registrado por',
      subtitle: 'Mamá',
    ),
    const SizedBox(height: 10),
    HealthActionRow(
      icon: Icons.sync_rounded,
      title: 'Estado de sincronización',
      subtitle: 'Revisa el respaldo de este registro',
      onTap: () => openFlow(HealthFlowAction.sync),
    ),
  ];

  List<Widget> _consultationDetail(BuildContext context) => [
    HealthBabyBanner(controller: controller),
    const SizedBox(height: 14),
    const HealthActionRow(
      icon: Icons.person_outline_rounded,
      title: 'Dra. Valeria Ruiz',
      subtitle: 'Pediatra · Consulta ingresada por el cuidador',
    ),
    const SizedBox(height: 10),
    const HealthActionRow(
      icon: Icons.medical_services_outlined,
      title: 'Evaluación',
      subtitle: 'El bebé está creciendo adecuadamente.',
    ),
    const SizedBox(height: 10),
    HealthActionRow(
      icon: Icons.medication_outlined,
      title: 'Tratamiento',
      subtitle: 'Hidratación de la piel 2 veces al día.',
      tint: Theme.of(context).colorScheme.error,
    ),
    const SizedBox(height: 10),
    const HealthActionRow(
      icon: Icons.calendar_month_outlined,
      title: 'Seguimiento',
      subtitle: 'Próximo control el 12 jun a las 11:30.',
    ),
    const SizedBox(height: 10),
    HealthActionRow(
      icon: Icons.visibility_outlined,
      title: 'Vigilancia',
      subtitle: 'Observar fiebre, irritabilidad o empeoramiento.',
      tint: Theme.of(context).colorScheme.secondary,
    ),
    const SizedBox(height: 10),
    const HealthActionRow(
      icon: Icons.attachment_outlined,
      title: 'Adjuntos y observaciones',
      subtitle: '2 fotos · Nota de mamá',
    ),
    const SizedBox(height: 18),
    HealthPrimaryButton(
      label: 'Ver reportes',
      onPressed: () => openFlow(HealthFlowAction.reports),
    ),
  ];

  List<Widget> _pediatricianDetail(BuildContext context) => [
    HealthSurface(
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            child: Icon(
              Icons.medical_services_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dra. Valeria Ruiz',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
                Text('Pediatría general'),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber),
                    Text(' 5.0 · valoración privada'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    const HealthActionRow(
      icon: Icons.phone_outlined,
      title: 'Información de contacto',
      subtitle: '+56 9 1234 5678 · Prefiere WhatsApp',
    ),
    const SizedBox(height: 10),
    const HealthActionRow(
      icon: Icons.local_hospital_outlined,
      title: 'Clínica infantil',
      subtitle: 'Lun a vie · 08:00 a 17:00',
    ),
    const SizedBox(height: 10),
    const HealthActionRow(
      icon: Icons.history_rounded,
      title: 'Consultas asociadas',
      subtitle: '4 consultas · Última el 15 may',
    ),
    const SizedBox(height: 18),
    HealthPrimaryButton(
      label: 'Comparar experiencias',
      icon: Icons.star_outline_rounded,
      onPressed: () => openFlow(HealthFlowAction.compare),
    ),
  ];

  List<Widget> _clinicalDetail(BuildContext context) => [
    HealthBabyBanner(controller: controller),
    const SizedBox(height: 14),
    const HealthActionRow(
      icon: Icons.note_alt_outlined,
      title: 'Observación clínica',
      subtitle: 'Registro disponible en el historial del bebé.',
    ),
    const SizedBox(height: 10),
    HealthActionRow(
      icon: Icons.sync_rounded,
      title: 'Sincronización familiar',
      subtitle: 'Consulta el estado del respaldo.',
      onTap: () => openFlow(HealthFlowAction.sync),
    ),
  ];
}

class _ExportReportView extends StatelessWidget {
  const _ExportReportView({required this.controller, required this.openFlow});

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  Future<void> _export(BuildContext context, {required bool csv}) async {
    try {
      const exporter = HealthReportExporter();
      if (csv) {
        await exporter.shareCsv(controller);
      } else {
        await exporter.sharePdf(controller);
      }
      if (context.mounted) openFlow(HealthFlowAction.exported);
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo generar el reporte: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const HealthSectionHeading(
          title: 'Exportar o compartir reporte',
          subtitle: 'Selecciona cómo quieres compartir el resumen de salud.',
        ),
        const SizedBox(height: 22),
        HealthActionRow(
          icon: Icons.picture_as_pdf_outlined,
          title: 'Exportar PDF',
          subtitle: 'Resumen visual listo para enviar o imprimir.',
          tint: Theme.of(context).colorScheme.error,
          onTap: () => _export(context, csv: false),
        ),
        const SizedBox(height: 12),
        HealthActionRow(
          icon: Icons.table_chart_outlined,
          title: 'Exportar CSV',
          subtitle: 'Datos del período para análisis.',
          tint: Theme.of(context).colorScheme.tertiary,
          onTap: () => _export(context, csv: true),
        ),
        const SizedBox(height: 12),
        HealthActionRow(
          icon: Icons.medical_services_outlined,
          title: 'Compartir con pediatra',
          subtitle: 'Abre las opciones seguras para compartir.',
          tint: Theme.of(context).colorScheme.secondary,
          onTap: () => _export(context, csv: false),
        ),
        const SizedBox(height: 20),
        HealthSurface(
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('El reporte solo incluye el período seleccionado.'),
              ),
              HealthSyncBadge(
                status: controller.offlineMode
                    ? RegisterSyncStatus.pending
                    : RegisterSyncStatus.synced,
                compact: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExportedReportView extends StatelessWidget {
  const _ExportedReportView({required this.controller, required this.openFlow});

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  Future<void> _shareAgain(BuildContext context) async {
    try {
      await const HealthReportExporter().sharePdf(controller);
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo compartir el reporte: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 36),
      children: [
        Center(
          child: Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 88,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Reporte generado con éxito',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'El resumen de salud está listo para compartir.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const HealthActionRow(
          icon: Icons.local_drink_outlined,
          title: 'Alimentación, sueño y pañales',
          subtitle: 'Actividad del período seleccionado',
        ),
        const SizedBox(height: 10),
        const HealthActionRow(
          icon: Icons.insights_rounded,
          title: 'Tendencias y crecimiento',
          subtitle: 'Evolución visual y mediciones',
        ),
        const SizedBox(height: 10),
        const HealthActionRow(
          icon: Icons.note_alt_outlined,
          title: 'Observaciones clínicas',
          subtitle: 'Notas registradas por los cuidadores',
        ),
        const SizedBox(height: 24),
        HealthPrimaryButton(
          label: 'Compartir ahora',
          icon: Icons.ios_share_rounded,
          onPressed: () => _shareAgain(context),
        ),
        const SizedBox(height: 12),
        HealthPrimaryButton(
          label: 'Volver a Reportes',
          outlined: true,
          onPressed: () => openFlow(HealthFlowAction.reports),
        ),
      ],
    );
  }
}

class _ComparePediatriciansView extends StatelessWidget {
  const _ComparePediatriciansView({required this.openFlow});

  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const HealthSectionHeading(
          title: 'Comparar experiencias',
          subtitle: 'Resumen privado de tus consultas con pediatras.',
        ),
        const SizedBox(height: 18),
        HealthSurface(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Row(
            children: [
              Icon(Icons.lock_outline_rounded),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Esta comparación es privada y solo tú puedes verla.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final pediatrician in const [
          ('Dra. Valeria Ruiz', '5.0', '4 consultas', 'Claridad · Calidez'),
          ('Dr. Mateo Salazar', '4.7', '2 consultas', 'Puntualidad'),
          ('Dra. Juliana Torres', '4.6', '3 consultas', 'Empatía'),
        ]) ...[
          HealthSurface(
            onTap: () => openFlow(HealthFlowAction.detail),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(pediatrician.$1.split(' ').last[0]),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pediatrician.$1,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text('${pediatrician.$2} ★ · ${pediatrician.$3}'),
                      Text(
                        pediatrician.$4,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: value,
              );
              if (date == null) return;
              onChanged(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  value.hour,
                  value.minute,
                ),
              );
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(healthDateLabel(value)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(value),
              );
              if (time == null) return;
              onChanged(
                DateTime(
                  value.year,
                  value.month,
                  value.day,
                  time.hour,
                  time.minute,
                ),
              );
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Hora',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              child: Text(healthTimeLabel(value)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LongField extends StatelessWidget {
  const _LongField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return HealthSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(hintText: hint),
            validator: required ? _required : null,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'Este campo es obligatorio.' : null;

void _showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('No pudimos guardar el registro: $error')),
  );
}

void _notAvailable(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Esta acción estará disponible en el dispositivo.'),
    ),
  );
}
