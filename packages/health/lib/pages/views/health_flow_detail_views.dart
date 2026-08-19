import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
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
      return _ComparePediatriciansView(
        controller: controller,
        openFlow: openFlow,
      );
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
      return _ConsultationWizard(
        controller: controller,
        openFlow: openFlow,
        appointmentKind: kind == HealthSectionKind.controls
            ? HealthAppointmentKind.wellChildControl
            : HealthAppointmentKind.consultation,
      );
    }
    if (kind == HealthSectionKind.pediatricCare &&
        action == HealthFlowAction.register) {
      return _PediatricianForm(controller: controller, openFlow: openFlow);
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
  final vaccine = TextEditingController();
  final dose = TextEditingController();
  final location = TextEditingController();
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
  const _ConsultationWizard({
    required this.controller,
    required this.openFlow,
    required this.appointmentKind,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;
  final HealthAppointmentKind appointmentKind;

  @override
  State<_ConsultationWizard> createState() => _ConsultationWizardState();
}

class _ConsultationWizardState extends State<_ConsultationWizard> {
  final formKey = GlobalKey<FormState>();
  final pediatrician = TextEditingController();
  final reason = TextEditingController();
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
                  label: step == 2
                      ? occurredAt.isAfter(DateTime.now())
                            ? 'Programar cita'
                            : 'Finalizar resumen'
                      : 'Continuar',
                  busy: busy,
                  onPressed: step == 2 ? () => _save(true) : _continue,
                ),
              ),
            ],
          ),
          if (step == 2 && !occurredAt.isAfter(DateTime.now())) ...[
            const SizedBox(height: 10),
            HealthPrimaryButton(
              label: 'Guardar para completar después',
              outlined: true,
              busy: busy,
              onPressed: () => _save(false),
            ),
          ],
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
    setState(() => step++);
  }

  Future<void> _save(bool finishSummary) async {
    if (finishSummary &&
        !occurredAt.isAfter(DateTime.now()) &&
        summary.text.trim().isEmpty) {
      BebeInAppSnackbar.show(
        context,
        message: 'Agrega el resumen clínico antes de finalizar.',
        variant: BebeInAppSnackbarVariant.warning,
      );
      return;
    }
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
        appointmentKind: widget.appointmentKind,
        finishSummary: finishSummary,
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
      BebeInAppSnackbar.show(
        context,
        message: 'Completa el título y la descripción.',
        variant: BebeInAppSnackbarVariant.warning,
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
  const _PediatricianForm({required this.controller, required this.openFlow});

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  State<_PediatricianForm> createState() => _PediatricianFormState();
}

class _PediatricianFormState extends State<_PediatricianForm> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final specialty = TextEditingController();
  final phone = TextEditingController();
  final place = TextEditingController();
  final notes = TextEditingController();
  bool busy = false;

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
      await widget.controller.savePediatrician(
        name: name.text,
        specialty: specialty.text,
        phone: phone.text,
        place: place.text,
        notes: notes.text,
      );
      if (!mounted) return;
      BebeInAppSnackbar.show(
        context,
        message: '${name.text.trim()} se guardó en Salud.',
        variant: BebeInAppSnackbarVariant.success,
      );
      widget.openFlow(HealthFlowAction.detail);
    } on Object catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
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
      HealthSectionKind.consultations => (
        '¡Consulta guardada!',
        'Las indicaciones están disponibles en el historial clínico.',
        Icons.medical_information_outlined,
      ),
      HealthSectionKind.controls => (
        '¡Control guardado!',
        'El control está disponible en el historial clínico.',
        Icons.health_and_safety_outlined,
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

  List<Widget> _vaccineDetail(BuildContext context) {
    final selected = controller.selectedHealthEvent;
    final event = selected?.type == HealthEventType.vaccine
        ? selected
        : controller.vaccines.firstOrNull;
    if (event == null) {
      return [
        HealthEmptyState(
          title: 'No hay una vacuna para mostrar',
          description:
              'Registra una vacuna aplicada para consultar aquí su detalle.',
          icon: Icons.vaccines_outlined,
          actionLabel: 'Registrar vacuna',
          onActionPressed: () => openFlow(HealthFlowAction.register),
        ),
      ];
    }
    final applied = event.status == HealthEventStatus.completed;
    return [
      HealthSurface(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Column(
          children: [
            const Icon(Icons.health_and_safety_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              event.title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (event.description.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(event.description, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
      const SizedBox(height: 14),
      HealthActionRow(
        icon: Icons.calendar_today_outlined,
        title: applied ? 'Fecha de aplicación' : 'Fecha programada',
        subtitle:
            '${healthDateLabel(event.startsAt)} · ${healthTimeLabel(event.startsAt)}',
        trailing: _EventStatusLabel(event.status),
      ),
      if (!applied) ...[
        const SizedBox(height: 18),
        HealthPrimaryButton(
          label: 'Registrar aplicación',
          icon: Icons.vaccines_outlined,
          onPressed: () => openFlow(HealthFlowAction.register),
        ),
      ],
    ];
  }

  List<Widget> _measurementDetail(BuildContext context) {
    final measurement =
        controller.selectedMeasurement ?? controller.measurements.firstOrNull;
    if (measurement == null) {
      return [
        HealthEmptyState(
          title: 'Todavía no hay mediciones',
          description:
              'Registra peso o talla para consultar el detalle de crecimiento.',
          icon: Icons.monitor_weight_outlined,
          actionLabel: 'Registrar medición',
          onActionPressed: () => openFlow(HealthFlowAction.register),
        ),
      ];
    }

    final isWeight = measurement.type == HealthMeasurementType.weight;
    final unit = measurement.unit;
    final value = measurement.value.toStringAsFixed(isWeight ? 2 : 1);
    return [
      HealthSurface(
        child: Row(
          children: [
            Icon(
              isWeight
                  ? Icons.monitor_weight_outlined
                  : Icons.straighten_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWeight ? 'Peso' : 'Talla',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    '$value $unit',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text('Medición registrada'),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      HealthActionRow(
        icon: Icons.calendar_today_outlined,
        title: 'Fecha y hora',
        subtitle:
            '${healthDateLabel(measurement.recordedAt)} · ${healthTimeLabel(measurement.recordedAt)}',
      ),
      const SizedBox(height: 10),
      HealthActionRow(
        icon: Icons.person_outline_rounded,
        title: 'Origen del registro',
        subtitle: measurement.source,
      ),
      const SizedBox(height: 10),
      HealthActionRow(
        icon: Icons.sync_rounded,
        title: 'Estado de sincronización',
        subtitle: 'Revisa el respaldo de este registro',
        trailing: HealthSyncBadge(
          status: measurement.syncStatus,
          compact: true,
        ),
        onTap: () => openFlow(HealthFlowAction.sync),
      ),
      ..._recordManagementActions(context),
    ];
  }

  List<Widget> _consultationDetail(BuildContext context) {
    final selectedEvent = controller.selectedHealthEvent;
    if (selectedEvent != null && selectedEvent.isAppointment) {
      final status = selectedEvent.effectiveStatus(DateTime.now());
      return [
        HealthActionRow(
          icon: selectedEvent.type == HealthEventType.growthControl
              ? Icons.monitor_weight_outlined
              : Icons.medical_services_outlined,
          title: selectedEvent.title,
          subtitle: selectedEvent.description.trim().isEmpty
              ? 'Sin descripción adicional'
              : selectedEvent.description,
          trailing: _EventStatusLabel(status),
        ),
        const SizedBox(height: 10),
        HealthActionRow(
          icon: Icons.calendar_today_outlined,
          title: 'Fecha y hora',
          subtitle:
              '${healthDateLabel(selectedEvent.startsAt)} · ${healthTimeLabel(selectedEvent.startsAt)}',
        ),
        if (selectedEvent.professionalName?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          HealthActionRow(
            icon: Icons.person_outline_rounded,
            title: 'Profesional',
            subtitle: selectedEvent.professionalName,
          ),
        ],
        if (selectedEvent.clinicalSummary?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          HealthActionRow(
            icon: Icons.description_outlined,
            title: 'Resumen clínico',
            subtitle: selectedEvent.clinicalSummary,
          ),
        ],
        if (selectedEvent.indications?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          HealthActionRow(
            icon: Icons.medical_information_outlined,
            title: 'Indicaciones',
            subtitle: selectedEvent.indications,
          ),
        ],
        if (status == HealthEventStatus.due ||
            status == HealthEventStatus.attendancePending) ...[
          const SizedBox(height: 18),
          HealthPrimaryButton(
            key: const ValueKey('health-confirm-attendance-now'),
            label: 'Sí, completar ahora',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () => _completeAppointment(context),
          ),
          const SizedBox(height: 10),
          HealthPrimaryButton(
            key: const ValueKey('health-confirm-attendance-later'),
            label: 'Sí, completar después',
            outlined: true,
            onPressed: () =>
                controller.confirmSelectedAttendance(completeNow: false),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const ValueKey('health-mark-not-attended'),
            onPressed: controller.markSelectedNotAttended,
            icon: const Icon(Icons.event_busy_outlined),
            label: const Text('No asistimos'),
          ),
        ],
        if (status == HealthEventStatus.attendedPendingSummary) ...[
          const SizedBox(height: 18),
          HealthPrimaryButton(
            key: const ValueKey('health-finalize-summary'),
            label: 'Completar resumen',
            icon: Icons.edit_note_rounded,
            onPressed: () => _completeAppointment(context),
          ),
        ],
        if (status == HealthEventStatus.scheduled ||
            status == HealthEventStatus.due ||
            status == HealthEventStatus.attendancePending) ...[
          const SizedBox(height: 10),
          HealthPrimaryButton(
            key: const ValueKey('health-reschedule-appointment'),
            label: 'Reprogramar',
            icon: Icons.event_repeat_outlined,
            outlined: true,
            onPressed: () => _rescheduleAppointment(context, selectedEvent),
          ),
        ],
      ];
    }

    final consultation =
        controller.selectedConsultation ?? controller.consultations.firstOrNull;
    if (consultation == null) {
      return [
        HealthEmptyState(
          title: 'No hay una consulta para mostrar',
          description:
              'Registra una consulta para conservar su evaluación e indicaciones.',
          icon: Icons.medical_information_outlined,
          actionLabel: 'Registrar consulta',
          onActionPressed: () => openFlow(HealthFlowAction.register),
        ),
      ];
    }
    return [
      HealthActionRow(
        icon: Icons.person_outline_rounded,
        title: consultation.pediatrician,
        subtitle:
            '${healthDateLabel(consultation.occurredAt)} · ${healthTimeLabel(consultation.occurredAt)}',
      ),
      const SizedBox(height: 10),
      HealthActionRow(
        icon: Icons.medical_services_outlined,
        title: consultation.title,
        subtitle: consultation.summary.isEmpty
            ? 'Sin evaluación registrada'
            : consultation.summary,
      ),
      if (consultation.treatment != null) ...[
        const SizedBox(height: 10),
        HealthActionRow(
          icon: Icons.medication_outlined,
          title: 'Tratamiento',
          subtitle: consultation.treatment,
          tint: Theme.of(context).colorScheme.error,
        ),
      ],
      if (consultation.followUp != null) ...[
        const SizedBox(height: 10),
        HealthActionRow(
          icon: Icons.calendar_month_outlined,
          title: 'Seguimiento',
          subtitle: consultation.followUp,
        ),
      ],
      if (consultation.vigilance != null) ...[
        const SizedBox(height: 10),
        HealthActionRow(
          icon: Icons.visibility_outlined,
          title: 'Vigilancia',
          subtitle: consultation.vigilance,
          tint: Theme.of(context).colorScheme.secondary,
        ),
      ],
      if (consultation.notes != null) ...[
        const SizedBox(height: 10),
        HealthActionRow(
          icon: Icons.notes_outlined,
          title: 'Notas del cuidador',
          subtitle: consultation.notes,
        ),
      ],
      ..._recordManagementActions(context),
      const SizedBox(height: 18),
      HealthPrimaryButton(
        label: 'Ver reportes',
        onPressed: () => openFlow(HealthFlowAction.reports),
      ),
    ];
  }

  Future<void> _completeAppointment(BuildContext context) async {
    final summary = TextEditingController(
      text: controller.selectedHealthEvent?.clinicalSummary,
    );
    final assessment = TextEditingController(
      text: controller.selectedHealthEvent?.professionalAssessment,
    );
    final indications = TextEditingController(
      text: controller.selectedHealthEvent?.indications,
    );
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Completar atención'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('health-clinical-summary-field'),
                controller: summary,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Resumen clínico *',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: assessment,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Evaluación profesional',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: indications,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Indicaciones'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Finalizar resumen'),
          ),
        ],
      ),
    );
    if (accepted == true && context.mounted) {
      try {
        await controller.finalizeSelectedSummary(
          clinicalSummary: summary.text,
          professionalAssessment: assessment.text,
          indications: indications.text,
        );
      } on ArgumentError catch (error) {
        if (context.mounted) _showError(context, error);
      }
    }
    summary.dispose();
    assessment.dispose();
    indications.dispose();
  }

  Future<void> _rescheduleAppointment(
    BuildContext context,
    HealthEventEntity event,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: event.startsAt.toLocal(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(event.startsAt.toLocal()),
    );
    if (time == null) return;
    await controller.rescheduleSelected(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  List<Widget> _pediatricianDetail(BuildContext context) {
    final pediatrician =
        controller.selectedPediatrician ?? controller.pediatricians.firstOrNull;
    if (pediatrician == null) {
      return [
        HealthEmptyState(
          title: 'No hay un pediatra para mostrar',
          description: 'Agrega un profesional para consultar aquí sus datos.',
          icon: Icons.medical_services_outlined,
          actionLabel: 'Agregar pediatra',
          onActionPressed: () => openFlow(HealthFlowAction.register),
        ),
      ];
    }
    final consultationLabel = pediatrician.consultationCount == 0
        ? 'Sin consultas asociadas'
        : '${pediatrician.consultationCount} ${pediatrician.consultationCount == 1 ? 'consulta' : 'consultas'} · Última ${healthDateLabel(pediatrician.lastConsultationAt!)}';
    return [
      HealthSurface(
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(
                pediatrician.name.characters.first.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pediatrician.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(pediatrician.specialty),
                  const SizedBox(height: 6),
                  Text(
                    consultationLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (pediatrician.phone != null) ...[
        const SizedBox(height: 12),
        HealthActionRow(
          icon: Icons.phone_outlined,
          title: 'Información de contacto',
          subtitle: pediatrician.phone,
        ),
      ],
      if (pediatrician.place != null) ...[
        const SizedBox(height: 10),
        HealthActionRow(
          icon: Icons.local_hospital_outlined,
          title: 'Lugar habitual',
          subtitle: pediatrician.place,
        ),
      ],
      if (pediatrician.notes != null) ...[
        const SizedBox(height: 10),
        HealthActionRow(
          icon: Icons.notes_outlined,
          title: 'Notas personales',
          subtitle: pediatrician.notes,
        ),
      ],
      ..._recordManagementActions(context),
      const SizedBox(height: 18),
      HealthPrimaryButton(
        label: 'Comparar experiencias',
        icon: Icons.compare_arrows_rounded,
        onPressed: () => openFlow(HealthFlowAction.compare),
      ),
    ];
  }

  List<Widget> _clinicalDetail(BuildContext context) {
    final healthEvent = controller.selectedHealthEvent;
    if (healthEvent != null) {
      return [
        HealthActionRow(
          icon: healthEvent.type == HealthEventType.vaccine
              ? Icons.vaccines_outlined
              : Icons.medical_services_outlined,
          title: healthEvent.title,
          subtitle: healthEvent.description.trim().isEmpty
              ? healthDateLabel(healthEvent.startsAt)
              : '${healthDateLabel(healthEvent.startsAt)} · ${healthEvent.description}',
          trailing: _EventStatusLabel(healthEvent.status),
        ),
      ];
    }
    final record =
        controller.selectedRecord ?? controller.clinicalNotes.firstOrNull;
    if (record == null) {
      return const [
        HealthEmptyState(
          title: 'No hay un registro para mostrar',
          description: 'Los detalles aparecerán al seleccionar un registro.',
          icon: Icons.folder_open_outlined,
        ),
      ];
    }
    return [
      HealthActionRow(
        icon: Icons.note_alt_outlined,
        title: _recordText(record, 'title', 'Registro de salud'),
        subtitle: _recordText(
          record,
          'description',
          record.notes ?? 'Sin descripción adicional',
        ),
        trailing: HealthSyncBadge(status: record.syncStatus, compact: true),
      ),
      const SizedBox(height: 10),
      HealthActionRow(
        icon: Icons.calendar_today_outlined,
        title: 'Fecha y hora',
        subtitle:
            '${healthDateLabel(record.occurredAt)} · ${healthTimeLabel(record.occurredAt)}',
      ),
      const SizedBox(height: 10),
      HealthActionRow(
        icon: Icons.sync_rounded,
        title: 'Sincronización familiar',
        subtitle: 'Consulta el estado del respaldo.',
        onTap: () => openFlow(HealthFlowAction.sync),
      ),
      ..._recordManagementActions(context),
    ];
  }

  List<Widget> _recordManagementActions(BuildContext context) {
    if (!controller.selectedRecordCanBeManaged) return const [];
    return [
      const SizedBox(height: 18),
      if (controller.selectedRecordCanBeEdited) ...[
        HealthPrimaryButton(
          label: 'Editar registro',
          icon: Icons.edit_outlined,
          outlined: true,
          onPressed: () => openFlow(HealthFlowAction.edit),
        ),
        const SizedBox(height: 10),
      ],
      OutlinedButton.icon(
        key: const ValueKey('health-delete-record'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        onPressed: () => _confirmDelete(context),
        icon: const Icon(Icons.delete_outline_rounded),
        label: const Text('Eliminar registro'),
      ),
    ];
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar este registro?'),
        content: const Text(
          'Se quitará del historial y de los reportes. La eliminación se '
          'sincronizará con los demás cuidadores.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final deleted = await controller.deleteSelectedRecord();
      if (deleted && context.mounted) Navigator.of(context).maybePop();
    } on Object catch (_) {
      if (!context.mounted) return;
      BebeInAppSnackbar.show(
        context,
        title: 'No pudimos eliminarlo',
        message: 'El registro sigue guardado. Intenta nuevamente.',
        variant: BebeInAppSnackbarVariant.error,
      );
    }
  }
}

class _ExportReportView extends StatefulWidget {
  const _ExportReportView({required this.controller, required this.openFlow});

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  State<_ExportReportView> createState() => _ExportReportViewState();
}

class _ExportReportViewState extends State<_ExportReportView> {
  ClinicalReportType _type = ClinicalReportType.pediatricControl;
  int _periodDays = 30;
  bool _includeCaregivers = false;
  bool _includePhotos = false;
  bool _includePrivateNotes = false;
  bool _includeTimeline = false;
  bool _exporting = false;
  DateTimeRange? _customPeriod;
  final Set<ClinicalReportSection> _sections = {
    ClinicalReportSection.growth,
    ClinicalReportSection.feeding,
    ClinicalReportSection.medications,
    ClinicalReportSection.vaccines,
    ClinicalReportSection.appointments,
    ClinicalReportSection.observations,
    ClinicalReportSection.elimination,
    ClinicalReportSection.sleep,
  };

  HealthFlowController get controller => widget.controller;
  HealthFlowNavigator get openFlow => widget.openFlow;

  List<int> get _periodOptions => switch (_type) {
    ClinicalReportType.symptomConsultation => const [1, 2, 3, 7],
    ClinicalReportType.pediatricControl => const [7, 30, 90],
    ClinicalReportType.medicationFollowUp => const [7, 30, 90],
    ClinicalReportType.growthNutrition => const [30, 90],
    ClinicalReportType.fullHistory => const [30, 90],
  };

  ClinicalReportRequest get _request {
    final generatedAt = controller.reportSnapshot.generatedAt;
    final customEnd = _customPeriod?.end;
    final requestedEnd = customEnd == null
        ? generatedAt
        : DateTime(
            customEnd.year,
            customEnd.month,
            customEnd.day,
            23,
            59,
            59,
            999,
          );
    final dateTo = requestedEnd.isAfter(generatedAt)
        ? generatedAt
        : requestedEnd;
    final dateFrom =
        _customPeriod?.start ??
        generatedAt.subtract(Duration(days: _periodDays));
    return ClinicalReportRequest(
      babyId: controller.activeBaby?.id ?? '',
      type: _type,
      dateFrom: dateFrom,
      dateTo: dateTo,
      includePhotos: _includePhotos,
      includeCaregiverNames: _includeCaregivers,
      includePrivateNotes: _includePrivateNotes,
      includeRawTimeline:
          _includeTimeline || _type == ClinicalReportType.fullHistory,
      sections: Set.unmodifiable(_sections),
    );
  }

  Future<void> _selectCustomPeriod() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _customPeriod,
      helpText: 'Período personalizado',
      saveText: 'Aplicar',
    );
    if (selected != null && mounted) setState(() => _customPeriod = selected);
  }

  Future<void> _export(BuildContext context, {required bool csv}) async {
    if (_exporting) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Antes de compartir'),
        content: const Text(
          'Este archivo contiene información personal y de salud del bebé. '
          'Compártelo sólo con personas autorizadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (accepted != true || !context.mounted) return;
    setState(() => _exporting = true);
    try {
      const exporter = HealthReportExporter();
      if (csv) {
        await exporter.shareCsv(controller);
      } else {
        await exporter.sharePdf(controller, request: _request);
      }
      if (context.mounted) openFlow(HealthFlowAction.exported);
    } on Object catch (error) {
      if (!context.mounted) return;
      BebeInAppSnackbar.show(
        context,
        message: 'No se pudo generar el reporte: $error',
        variant: BebeInAppSnackbarVariant.error,
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const HealthSectionHeading(
          title: 'Generar informe clínico',
          subtitle: 'Elige el propósito para mostrar sólo información útil.',
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<ClinicalReportType>(
          initialValue: _type,
          decoration: const InputDecoration(
            labelText: '¿Para qué lo necesitas?',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final type in ClinicalReportType.values)
              DropdownMenuItem(
                value: type,
                child: Text(_reportTypeLabel(type)),
              ),
          ],
          onChanged: _exporting
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() {
                    _type = value;
                    _customPeriod = null;
                    if (!_periodOptions.contains(_periodDays)) {
                      _periodDays = _periodOptions.first;
                    }
                  });
                },
        ),
        const SizedBox(height: 18),
        Text(
          'Período',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SegmentedButton<int>(
          segments: [
            for (final days in _periodOptions)
              ButtonSegment(
                value: days,
                label: Text(days == 1 ? '24 h' : '$days días'),
              ),
          ],
          selected: {_periodDays},
          showSelectedIcon: false,
          onSelectionChanged: _exporting
              ? null
              : (values) => setState(() {
                  _periodDays = values.first;
                  _customPeriod = null;
                }),
        ),
        if (_type != ClinicalReportType.symptomConsultation) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _exporting ? null : _selectCustomPeriod,
              icon: const Icon(Icons.date_range_outlined),
              label: Text(
                _customPeriod == null
                    ? 'Período personalizado'
                    : '${_shortDate(_customPeriod!.start)} - '
                          '${_shortDate(_customPeriod!.end)}',
              ),
            ),
          ),
        ],
        if (_type == ClinicalReportType.fullHistory) ...[
          const SizedBox(height: 14),
          HealthSurface(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded),
                SizedBox(width: 12),
                Expanded(child: Text('Este informe puede ser extenso.')),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        HealthSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Secciones del informe',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final section in const [
                    ClinicalReportSection.growth,
                    ClinicalReportSection.feeding,
                    ClinicalReportSection.medications,
                    ClinicalReportSection.vaccines,
                    ClinicalReportSection.appointments,
                    ClinicalReportSection.observations,
                    ClinicalReportSection.elimination,
                    ClinicalReportSection.sleep,
                  ])
                    FilterChip(
                      label: Text(_reportSectionLabel(section)),
                      selected: _sections.contains(section),
                      onSelected: _exporting
                          ? null
                          : (selected) {
                              if (!selected && _sections.length == 1) return;
                              setState(() {
                                if (selected) {
                                  _sections.add(section);
                                } else {
                                  _sections.remove(section);
                                }
                              });
                            },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HealthSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacidad y detalle',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Incluir nombres de cuidadores'),
                value: _includeCaregivers,
                onChanged: _exporting
                    ? null
                    : (value) => setState(() => _includeCaregivers = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Incluir fotografías'),
                subtitle: const Text('Desactivado por defecto'),
                value: _includePhotos,
                onChanged: _exporting
                    ? null
                    : (value) => setState(() => _includePhotos = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Incluir notas privadas'),
                subtitle: const Text('Desactivado por defecto'),
                value: _includePrivateNotes,
                onChanged: _exporting
                    ? null
                    : (value) => setState(() => _includePrivateNotes = value),
              ),
              if (_type != ClinicalReportType.fullHistory)
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Incluir timeline detallado'),
                  value: _includeTimeline,
                  onChanged: _exporting
                      ? null
                      : (value) => setState(() => _includeTimeline = value),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ClinicalReportPreview(controller: controller, request: _request),
        const SizedBox(height: 18),
        HealthPrimaryButton(
          label: _exporting ? 'Generando…' : 'Generar PDF y compartir',
          icon: Icons.picture_as_pdf_outlined,
          onPressed: _exporting || controller.activeBaby == null
              ? null
              : () => _export(context, csv: false),
        ),
        const SizedBox(height: 10),
        HealthActionRow(
          icon: Icons.table_chart_outlined,
          title: 'Exportar historial CSV',
          subtitle: 'Formato técnico con el detalle del período activo.',
          tint: Theme.of(context).colorScheme.tertiary,
          onTap: _exporting ? null : () => _export(context, csv: true),
        ),
        const SizedBox(height: 16),
        HealthSurface(
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'El PDF se genera localmente y no modifica los registros.',
                ),
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

class _ClinicalReportPreview extends StatelessWidget {
  const _ClinicalReportPreview({
    required this.controller,
    required this.request,
  });

  final HealthFlowController controller;
  final ClinicalReportRequest request;

  @override
  Widget build(BuildContext context) {
    ClinicalReportData? data;
    try {
      data = const HealthReportExporter().buildData(
        controller,
        request: request,
      );
    } on Object {
      data = null;
    }
    return HealthSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vista previa del contenido',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (data == null)
            const Text('No hay datos suficientes para previsualizar.')
          else ...[
            Text(data.summary),
            const SizedBox(height: 10),
            Text(
              '${data.feeding.recordCount} tomas · '
              '${data.elimination.wetDiapers + data.elimination.stools} registros de eliminación · '
              '${data.medications.length} medicamentos · '
              '${data.observations.length} observaciones',
            ),
            if (data.timeline.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('El timeline diario no se incluirá.'),
              ),
          ],
        ],
      ),
    );
  }
}

String _reportTypeLabel(ClinicalReportType type) => switch (type) {
  ClinicalReportType.pediatricControl => 'Control pediátrico',
  ClinicalReportType.symptomConsultation => 'Consulta por síntomas',
  ClinicalReportType.medicationFollowUp => 'Medicamentos',
  ClinicalReportType.growthNutrition => 'Crecimiento / nutrición',
  ClinicalReportType.fullHistory => 'Historial completo',
};

String _shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';

String _reportSectionLabel(ClinicalReportSection section) => switch (section) {
  ClinicalReportSection.growth => 'Crecimiento',
  ClinicalReportSection.feeding => 'Alimentación',
  ClinicalReportSection.medications => 'Medicamentos',
  ClinicalReportSection.vaccines => 'Vacunas',
  ClinicalReportSection.appointments => 'Controles',
  ClinicalReportSection.observations => 'Observaciones',
  ClinicalReportSection.elimination => 'Eliminación',
  ClinicalReportSection.sleep => 'Sueño',
  ClinicalReportSection.timeline => 'Timeline',
  ClinicalReportSection.photos => 'Fotografías',
};

class _ExportedReportView extends StatelessWidget {
  const _ExportedReportView({required this.controller, required this.openFlow});

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  Future<void> _shareAgain(BuildContext context) async {
    try {
      await const HealthReportExporter().sharePdf(controller);
    } on Object catch (error) {
      if (!context.mounted) return;
      BebeInAppSnackbar.show(
        context,
        message: 'No se pudo compartir el reporte: $error',
        variant: BebeInAppSnackbarVariant.error,
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
  const _ComparePediatriciansView({
    required this.controller,
    required this.openFlow,
  });

  final HealthFlowController controller;
  final HealthFlowNavigator openFlow;

  @override
  Widget build(BuildContext context) {
    return HealthFlowBody(
      controller: controller,
      builder: (context) {
        final pediatricians = controller.pediatricians;
        return [
          const HealthSectionHeading(
            title: 'Comparar experiencias',
            subtitle: 'Resumen privado basado en las consultas registradas.',
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
          if (pediatricians.isEmpty)
            const HealthEmptyState(
              title: 'No hay experiencias para comparar',
              description:
                  'Agrega pediatras o registra consultas para construir este resumen.',
              icon: Icons.compare_arrows_rounded,
            )
          else
            for (final pediatrician in pediatricians) ...[
              HealthSurface(
                onTap: () {
                  controller.selectPediatrician(pediatrician);
                  openFlow(HealthFlowAction.detail);
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                        pediatrician.name.characters.first.toUpperCase(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pediatrician.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(pediatrician.specialty),
                          const SizedBox(height: 4),
                          Text(
                            pediatrician.consultationCount == 0
                                ? 'Sin consultas asociadas'
                                : '${pediatrician.consultationCount} ${pediatrician.consultationCount == 1 ? 'consulta' : 'consultas'}',
                          ),
                          if (pediatrician.latestReason != null)
                            Text(
                              'Última: ${pediatrician.latestReason} · ${healthDateLabel(pediatrician.lastConsultationAt!)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
        ];
      },
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

class _EventStatusLabel extends StatelessWidget {
  const _EventStatusLabel(this.status);

  final HealthEventStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      HealthEventStatus.scheduled => (
        'Programado',
        Theme.of(context).colorScheme.primary,
      ),
      HealthEventStatus.completed => (
        'Completado',
        Theme.of(context).colorScheme.tertiary,
      ),
      HealthEventStatus.cancelled => (
        'Cancelado',
        Theme.of(context).colorScheme.error,
      ),
      HealthEventStatus.draft => (
        'Borrador',
        Theme.of(context).colorScheme.outline,
      ),
      HealthEventStatus.due => ('Hoy', Theme.of(context).colorScheme.primary),
      HealthEventStatus.attendancePending => (
        'Confirmar asistencia',
        Theme.of(context).colorScheme.primary,
      ),
      HealthEventStatus.attendedPendingSummary => (
        'Resumen pendiente',
        Theme.of(context).colorScheme.secondary,
      ),
      HealthEventStatus.notAttended => (
        'No asistieron',
        Theme.of(context).colorScheme.error,
      ),
      HealthEventStatus.rescheduled => (
        'Reprogramado',
        Theme.of(context).colorScheme.outline,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
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

String _recordText(RegisteredEvent event, String key, String fallback) {
  final value = event.details[key];
  return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
}

void _showError(BuildContext context, Object error) {
  BebeInAppSnackbar.show(
    context,
    message: 'No pudimos guardar el registro: $error',
    variant: BebeInAppSnackbarVariant.error,
  );
}

void _notAvailable(BuildContext context) {
  BebeInAppSnackbar.show(
    context,
    message: 'Esta acción estará disponible en el dispositivo.',
    variant: BebeInAppSnackbarVariant.information,
  );
}
