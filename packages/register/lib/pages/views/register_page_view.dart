import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:register/register.dart';

/// Connects the six registration forms to their independent Cubits.
class RegisterPageView extends StatefulWidget {
  const RegisterPageView({
    required this.initialKind,
    required this.babyName,
    required this.babyAge,
    required this.familyContextLabel,
    required this.onKindChanged,
    required this.onSaved,
    required this.onCancel,
    this.initialEvent,
    this.isEditing = false,
    this.babyAvatar,
    this.onNotificationsPressed,
    this.onHomePressed,
    this.onAgendaPressed,
    this.onHealthPressed,
    this.onFamilyPressed,
    this.onBabyPressed,
    super.key,
  });

  final RegisterEventKind initialKind;
  final String babyName;
  final String babyAge;
  final String familyContextLabel;
  final BebeAvatar? babyAvatar;
  final ValueChanged<RegisterEventKind> onKindChanged;
  final ValueChanged<RegisteredEvent> onSaved;
  final VoidCallback onCancel;
  final RegisteredEvent? initialEvent;
  final bool isEditing;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onHomePressed;
  final VoidCallback? onAgendaPressed;
  final VoidCallback? onHealthPressed;
  final VoidCallback? onFamilyPressed;
  final VoidCallback? onBabyPressed;

  @override
  State<RegisterPageView> createState() => _RegisterPageViewState();
}

class _RegisterPageViewState extends State<RegisterPageView> {
  final _feedingAmount = TextEditingController();
  final _feedingNotes = TextEditingController();
  final _feedingSymptoms = TextEditingController();
  final _sleepNotes = TextEditingController();
  final _sleepSymptoms = TextEditingController();
  final _diaperNotes = TextEditingController();
  final _diaperSymptoms = TextEditingController();
  final _clinicalDescription = TextEditingController();
  final _medicationName = TextEditingController();
  final _medicationDose = TextEditingController();
  final _medicationNotes = TextEditingController();
  final _measurementValue = TextEditingController();
  final _measurementNotes = TextEditingController();
  final _imagePicker = ImagePicker();
  final Map<String, Uint8List> _photoPreviews = {};

  late RegisterEventKind _kind;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind;
    _hydrateControllers(widget.initialEvent);
  }

  @override
  void didUpdateWidget(covariant RegisterPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialKind != widget.initialKind) {
      _kind = widget.initialKind;
    }
    if (oldWidget.initialEvent?.id != widget.initialEvent?.id) {
      _hydrateControllers(widget.initialEvent);
    }
  }

  @override
  void dispose() {
    _feedingAmount.dispose();
    _feedingNotes.dispose();
    _feedingSymptoms.dispose();
    _sleepNotes.dispose();
    _sleepSymptoms.dispose();
    _diaperNotes.dispose();
    _diaperSymptoms.dispose();
    _clinicalDescription.dispose();
    _medicationName.dispose();
    _medicationDose.dispose();
    _medicationNotes.dispose();
    _measurementValue.dispose();
    _measurementNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cada BlocProvider padre es lazy. Escuchar sólo el formulario visible
    // evita construir los otros cinco Cubits durante el primer frame.
    return switch (_kind) {
      RegisterEventKind.feeding =>
        BlocListener<FeedingRegisterCubit, RegisterFormState>(
          listener: _onSubmissionChanged,
          child: _feeding(),
        ),
      RegisterEventKind.sleep =>
        BlocListener<SleepRegisterCubit, RegisterFormState>(
          listener: _onSubmissionChanged,
          child: _sleep(),
        ),
      RegisterEventKind.diaper =>
        BlocListener<DiaperRegisterCubit, RegisterFormState>(
          listener: _onSubmissionChanged,
          child: _diaper(),
        ),
      RegisterEventKind.observation =>
        BlocListener<ClinicalObservationRegisterCubit, RegisterFormState>(
          listener: _onSubmissionChanged,
          child: _clinicalObservation(),
        ),
      RegisterEventKind.medication =>
        BlocListener<MedicationRegisterCubit, RegisterFormState>(
          listener: _onSubmissionChanged,
          child: _medication(),
        ),
      RegisterEventKind.measurement =>
        BlocListener<MeasurementRegisterCubit, RegisterFormState>(
          listener: _onSubmissionChanged,
          child: _measurement(),
        ),
    };
  }

  void _onSubmissionChanged(BuildContext context, RegisterFormState state) {
    if (state.status == RegisterSubmissionStatus.success &&
        state.savedEvent != null) {
      widget.onSaved(state.savedEvent!);
    }
  }

  void _hydrateControllers(RegisteredEvent? event) {
    if (event == null) return;
    final details = event.details;
    _feedingAmount.text = details['amount_ml']?.toString() ?? '';
    _feedingNotes.text = event.notes ?? '';
    _feedingSymptoms.text = details['symptoms']?.toString() ?? '';
    _sleepNotes.text = event.notes ?? '';
    _sleepSymptoms.text = details['symptoms']?.toString() ?? '';
    _diaperNotes.text = event.notes ?? '';
    _diaperSymptoms.text = details['symptoms']?.toString() ?? '';
    _clinicalDescription.text = details['description']?.toString() ?? '';
    _medicationName.text = details['name']?.toString() ?? '';
    _medicationDose.text = details['dose']?.toString() ?? '';
    _medicationNotes.text = event.notes ?? '';
    _measurementValue.text = details['value']?.toString() ?? '';
    _measurementNotes.text = event.notes ?? '';
  }

  Widget _feeding() {
    return BlocBuilder<FeedingRegisterCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<FeedingRegisterCubit>();
        return _shell(
          state: state,
          kind: RegisterEventKind.feeding,
          subcategories: _feedingTypes,
          selectedSubcategory: cubit.subtype,
          onSubcategoryChanged: cubit.subtypeChanged,
          contextTitle: 'Registra la toma de ${widget.babyName}',
          contextDescription: 'Guarda el tipo, horario y duración.',
          onSave: cubit.submit,
          form: FeedingRegisterForm(
            subtype: cubit.subtype,
            side: cubit.side,
            amountController: _feedingAmount,
            startTime: _time(context, cubit.startedAt),
            duration: _duration(cubit.durationMinutes),
            endTime:
                cubit.endAt == null ? '--:--' : _time(context, cubit.endAt!),
            scheduleNextFeeding: cubit.scheduleNextFeeding,
            reminderLabel: 'En ${cubit.reminderHours} horas',
            mood: cubit.mood,
            notesController: _feedingNotes,
            symptomsController: _feedingSymptoms,
            onSideChanged: cubit.sideChanged,
            onAmountChanged: cubit.amountMlChanged,
            onStartTimePressed: () => _pickTime(
              cubit.startedAt,
              cubit.timeChanged,
            ),
            onDurationPressed: () => _pickDuration(
              cubit.durationMinutes,
              cubit.durationChanged,
            ),
            onEndTimePressed: () => _pickTime(
              cubit.endAt ??
                  cubit.startedAt.add(
                    Duration(minutes: cubit.durationMinutes),
                  ),
              cubit.endTimeChanged,
            ),
            onScheduleNextFeedingChanged: cubit.scheduleNextFeedingChanged,
            onReminderPressed: () => _pickReminderHours(
              current: cubit.reminderHours,
              onSelected: cubit.reminderHoursChanged,
            ),
            onMoodChanged: cubit.moodChanged,
            onNotesChanged: cubit.notesChanged,
            onSymptomsChanged: cubit.symptomsChanged,
          ),
        );
      },
    );
  }

  Widget _sleep() {
    return BlocBuilder<SleepRegisterCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<SleepRegisterCubit>();
        return _shell(
          state: state,
          kind: RegisterEventKind.sleep,
          subcategories: _sleepTypes,
          selectedSubcategory: cubit.subtype,
          onSubcategoryChanged: cubit.subtypeChanged,
          contextTitle: 'Registra el sueño de ${widget.babyName}',
          contextDescription: cubit.isOngoing
              ? 'Guarda el inicio ahora y registra el despertar cuando ocurra.'
              : 'Registra una siesta o sueño que ya terminó.',
          saveLabel: cubit.isOngoing ? 'Iniciar sueño' : 'Guardar sueño',
          onSave: cubit.submit,
          form: SleepRegisterForm(
            mode: cubit.mode.name,
            startTime: _time(context, cubit.startedAt),
            duration: _duration(cubit.durationMinutes),
            endTime:
                cubit.endAt == null ? '--:--' : _time(context, cubit.endAt!),
            place: cubit.place,
            mood: cubit.mood,
            notesController: _sleepNotes,
            symptomsController: _sleepSymptoms,
            onModeChanged: cubit.modeChanged,
            onStartTimePressed: () => _pickTime(
              cubit.startedAt,
              cubit.timeChanged,
            ),
            onDurationPressed: () => _pickDuration(
              cubit.durationMinutes,
              cubit.durationChanged,
            ),
            onEndTimePressed: () => _pickTime(
              cubit.endAt ??
                  cubit.startedAt.add(
                    Duration(minutes: cubit.durationMinutes),
                  ),
              cubit.endTimeChanged,
            ),
            onPlaceChanged: cubit.placeChanged,
            onMoodChanged: cubit.moodChanged,
            onNotesChanged: cubit.notesChanged,
            onSymptomsChanged: cubit.symptomsChanged,
          ),
        );
      },
    );
  }

  Widget _diaper() {
    return BlocBuilder<DiaperRegisterCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<DiaperRegisterCubit>();
        return _shell(
          state: state,
          kind: RegisterEventKind.diaper,
          subcategories: _diaperTypes,
          selectedSubcategory: cubit.subtype,
          onSubcategoryChanged: cubit.subtypeChanged,
          contextTitle: 'Registra el cambio de pañal',
          contextDescription: 'Guarda sus características y el horario.',
          onSave: cubit.submit,
          form: DiaperRegisterForm(
            subtype: cubit.subtype,
            date: _date(context, cubit.occurredAt),
            time: _time(context, cubit.occurredAt),
            appearance: cubit.appearance,
            color: cubit.color,
            amount: cubit.amount,
            urineColor: cubit.urineColor,
            urineAmount: cubit.urineAmount,
            scheduleReminder: cubit.scheduleReminder,
            reminderLabel: 'En ${cubit.reminderHours} horas',
            notesController: _diaperNotes,
            symptomsController: _diaperSymptoms,
            onDatePressed: () => _pickDate(
              cubit.occurredAt,
              cubit.dateChanged,
            ),
            onTimePressed: () => _pickTime(
              cubit.occurredAt,
              cubit.timeChanged,
            ),
            onAppearanceChanged: cubit.appearanceChanged,
            onColorChanged: cubit.colorChanged,
            onAmountChanged: cubit.amountChanged,
            onUrineColorChanged: cubit.urineColorChanged,
            onUrineAmountChanged: cubit.urineAmountChanged,
            onScheduleReminderChanged: cubit.scheduleReminderChanged,
            onReminderPressed: () => _pickReminderHours(
              current: cubit.reminderHours,
              onSelected: cubit.reminderHoursChanged,
            ),
            onNotesChanged: cubit.notesChanged,
            onSymptomsChanged: cubit.symptomsChanged,
          ),
        );
      },
    );
  }

  Widget _clinicalObservation() {
    return BlocBuilder<ClinicalObservationRegisterCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<ClinicalObservationRegisterCubit>();
        return _shell(
          state: state,
          kind: RegisterEventKind.observation,
          title: 'Nueva observación clínica',
          showEventContext: false,
          useFormSurface: false,
          onBackPressed: _kind == widget.initialKind
              ? null
              : () => _onKindChanged(widget.initialKind),
          onSave: cubit.submit,
          form: ClinicalObservationRegisterForm(
            observationType: cubit.observationType,
            date: _date(context, cubit.occurredAt),
            time: _time(context, cubit.occurredAt),
            descriptionController: _clinicalDescription,
            photos: [
              for (final path in cubit.photoPaths)
                BebePhotoItem(
                  id: path,
                  semanticLabel: 'Foto de la observación',
                  preview: _photoPreviews[path] == null
                      ? const Center(child: Icon(Icons.image_outlined))
                      : Image.memory(
                          _photoPreviews[path]!,
                          fit: BoxFit.cover,
                        ),
                ),
            ],
            severity: cubit.severity,
            shareWithPediatrician: cubit.shareWithPediatrician,
            caregiver: cubit.caregiver,
            onObservationTypeChanged: cubit.observationTypeChanged,
            onDatePressed: () => _pickDate(
              cubit.occurredAt,
              cubit.dateChanged,
            ),
            onTimePressed: () => _pickTime(
              cubit.occurredAt,
              cubit.timeChanged,
            ),
            onDescriptionChanged: cubit.descriptionChanged,
            onAddPhotoPressed: () => _addPhoto(cubit),
            onRemovePhotoPressed: (path) => _removePhoto(cubit, path),
            onSeverityChanged: cubit.severityChanged,
            onShareChanged: cubit.shareChanged,
            onCaregiverChanged: cubit.caregiverChanged,
          ),
        );
      },
    );
  }

  Widget _medication() {
    return BlocBuilder<MedicationRegisterCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<MedicationRegisterCubit>();
        return _shell(
          state: state,
          kind: RegisterEventKind.medication,
          subcategories: _medicationTypes,
          selectedSubcategory: cubit.subtype,
          onSubcategoryChanged: cubit.subtypeChanged,
          contextTitle: 'Registra una administración',
          contextDescription: 'La dosis quedará disponible sin conexión.',
          onSave: cubit.submit,
          form: MedicationRegisterForm(
            subtype: cubit.subtype,
            nameController: _medicationName,
            doseController: _medicationDose,
            unit: cubit.unit,
            time: _time(context, cubit.occurredAt),
            frequency: cubit.frequency,
            endDate: cubit.endDate == null
                ? 'Selecciona una fecha'
                : _date(context, cubit.endDate!),
            scheduleNextDoses: cubit.scheduleNextDoses,
            notesController: _medicationNotes,
            caregiver: cubit.caregiver,
            onNameChanged: cubit.nameChanged,
            onDoseChanged: cubit.doseChanged,
            onUnitPressed: () => _pickString(
              title: 'Unidad',
              current: cubit.unit,
              options: RegisterCatalog.medicationUnits,
              onSelected: cubit.unitChanged,
            ),
            onTimePressed: () => _pickTime(
              cubit.occurredAt,
              cubit.timeChanged,
            ),
            onFrequencyPressed: () => _pickString(
              title: 'Frecuencia',
              current: cubit.frequency,
              options: RegisterCatalog.medicationFrequencies,
              onSelected: cubit.frequencyChanged,
            ),
            onEndDatePressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: cubit.endDate ?? cubit.occurredAt,
                firstDate: cubit.occurredAt,
                lastDate: DateTime(cubit.occurredAt.year + 5),
              );
              if (selected != null) cubit.endDateChanged(selected);
            },
            onScheduleChanged: cubit.scheduleChanged,
            onNotesChanged: cubit.notesChanged,
            onCaregiverChanged: cubit.caregiverChanged,
          ),
        );
      },
    );
  }

  Widget _measurement() {
    return BlocBuilder<MeasurementRegisterCubit, RegisterFormState>(
      builder: (context, state) {
        final cubit = context.read<MeasurementRegisterCubit>();
        return _shell(
          state: state,
          kind: RegisterEventKind.measurement,
          subcategories: _measurementTypes,
          selectedSubcategory: cubit.measurementType,
          onSubcategoryChanged: cubit.measurementTypeChanged,
          contextTitle: 'Registra una medición',
          contextDescription: 'Se guardará en el historial de crecimiento.',
          onSave: cubit.submit,
          form: MeasurementRegisterForm(
            measurementType: cubit.measurementType,
            valueController: _measurementValue,
            unit: cubit.unit,
            date: _date(context, cubit.occurredAt),
            time: _time(context, cubit.occurredAt),
            source: cubit.source,
            notesController: _measurementNotes,
            onValueChanged: cubit.valueChanged,
            onDatePressed: () => _pickDate(
              cubit.occurredAt,
              cubit.dateChanged,
            ),
            onTimePressed: () => _pickTime(
              cubit.occurredAt,
              cubit.timeChanged,
            ),
            onSourceChanged: cubit.sourceChanged,
            onNotesChanged: cubit.notesChanged,
          ),
        );
      },
    );
  }

  Widget _shell({
    required RegisterFormState state,
    required RegisterEventKind kind,
    required Widget form,
    required VoidCallback onSave,
    String title = 'Registrar evento',
    bool showEventContext = true,
    bool useFormSurface = true,
    String saveLabel = 'Guardar registro',
    List<BebeSegmentedItem<String>> subcategories = const [],
    String? selectedSubcategory,
    ValueChanged<String>? onSubcategoryChanged,
    String? contextTitle,
    String? contextDescription,
    VoidCallback? onBackPressed,
  }) {
    return RegisterEventView(
      title: widget.isEditing ? 'Editar registro' : title,
      selectedKind: kind,
      onKindChanged: widget.isEditing ? null : _onKindChanged,
      babyName: widget.babyName,
      babyAge: widget.babyAge,
      familyContextLabel: widget.familyContextLabel,
      babyAvatar: widget.babyAvatar,
      onBabyPressed: widget.onBabyPressed,
      showEventContext: showEventContext,
      useFormSurface: useFormSurface,
      subcategories: subcategories,
      selectedSubcategory: selectedSubcategory,
      onSubcategoryChanged: onSubcategoryChanged,
      contextTitle: contextTitle,
      contextDescription: contextDescription,
      contextTrailing:
          contextTitle == null ? null : const Icon(Icons.info_outline_rounded),
      onNotificationsPressed: widget.onNotificationsPressed,
      form: form,
      onBackPressed: onBackPressed ?? widget.onCancel,
      onSavePressed: state.isSaving ? null : onSave,
      onCancelPressed: state.isSaving ? null : widget.onCancel,
      isSaving: state.isSaving,
      saveLabel: widget.isEditing ? 'Guardar cambios' : saveLabel,
      errorMessage: state.message,
    );
  }

  void _onKindChanged(RegisterEventKind nextKind) {
    if (_kind == nextKind) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _kind = nextKind);
    widget.onKindChanged(nextKind);
  }

  Future<void> _pickDate(
    DateTime current,
    ValueChanged<DateTime> onSelected,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(current.year - 5),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (selected != null) onSelected(selected);
  }

  Future<void> _pickTime(
    DateTime current,
    void Function(int hour, int minute) onSelected,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (selected != null) onSelected(selected.hour, selected.minute);
  }

  Future<void> _pickDuration(
    int current,
    ValueChanged<int> onSelected,
  ) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final value in RegisterCatalog.durationMinutes)
              ListTile(
                title: Text(_duration(value)),
                selected: value == current,
                onTap: () => Navigator.of(context).pop(value),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onSelected(selected);
  }

  Future<void> _pickString({
    required String title,
    required String current,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(option),
                selected: option == current,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onSelected(selected);
  }

  Future<void> _pickReminderHours({
    required int current,
    required ValueChanged<int> onSelected,
  }) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text(
                'Programar recordatorio',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            for (final hours in RegisterCatalog.careReminderIntervals)
              ListTile(
                leading: const Icon(Icons.alarm_outlined),
                title: Text('En $hours horas'),
                selected: current == hours,
                onTap: () => Navigator.of(context).pop(hours),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onSelected(selected);
  }

  Future<void> _addPhoto(ClinicalObservationRegisterCubit cubit) async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (photo == null) return;
    final bytes = await photo.readAsBytes();
    if (!mounted) return;
    setState(() => _photoPreviews[photo.path] = bytes);
    cubit.photoAdded(photo.path);
  }

  void _removePhoto(
    ClinicalObservationRegisterCubit cubit,
    String path,
  ) {
    setState(() => _photoPreviews.remove(path));
    cubit.photoRemoved(path);
  }

  String _date(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatMediumDate(value);

  String _time(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(value),
      );

  static String _duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining == 0 ? '$hours h' : '$hours h $remaining min';
  }

  static const _feedingTypes = <BebeSegmentedItem<String>>[
    BebeSegmentedItem(
      value: 'breast',
      label: 'Pecho',
      icon: Icon(Icons.child_care_rounded),
    ),
    BebeSegmentedItem(
      value: 'bottle',
      label: 'Mamadera',
      icon: Icon(Icons.local_drink_outlined),
    ),
    BebeSegmentedItem(
      value: 'expressed',
      label: 'Leche extraída',
      icon: Icon(Icons.water_drop_outlined),
    ),
    BebeSegmentedItem(
      value: 'formula',
      label: 'Fórmula',
      icon: Icon(Icons.inventory_2_outlined),
    ),
  ];
  static const _sleepTypes = <BebeSegmentedItem<String>>[
    BebeSegmentedItem(
      value: 'nap',
      label: 'Siesta',
      icon: Icon(Icons.light_mode_outlined),
    ),
    BebeSegmentedItem(
      value: 'night',
      label: 'Sueño nocturno',
      icon: Icon(Icons.dark_mode_outlined),
    ),
  ];
  static const _diaperTypes = <BebeSegmentedItem<String>>[
    BebeSegmentedItem(
      value: 'wet',
      label: 'Orina',
      icon: Icon(Icons.water_drop_outlined),
    ),
    BebeSegmentedItem(
      value: 'dirty',
      label: 'Deposición',
      icon: Icon(Icons.layers_outlined),
    ),
    BebeSegmentedItem(
      value: 'mixed',
      label: 'Mixto',
      icon: Icon(Icons.water_drop_rounded),
    ),
  ];
  static const _medicationTypes = <BebeSegmentedItem<String>>[
    BebeSegmentedItem(
      value: 'medication',
      label: 'Medicamento',
      icon: Icon(Icons.medication_outlined),
    ),
    BebeSegmentedItem(
      value: 'supplement',
      label: 'Suplemento',
      icon: Icon(Icons.eco_outlined),
    ),
    BebeSegmentedItem(
      value: 'vitamin',
      label: 'Vitamina',
      icon: Icon(Icons.health_and_safety_outlined),
    ),
  ];
  static const _measurementTypes = <BebeSegmentedItem<String>>[
    BebeSegmentedItem(
      value: 'weight',
      label: 'Peso',
      icon: Icon(Icons.monitor_weight_outlined),
    ),
    BebeSegmentedItem(
      value: 'height',
      label: 'Talla',
      icon: Icon(Icons.height_rounded),
    ),
    BebeSegmentedItem(
      value: 'head',
      label: 'Perímetro cefálico',
      icon: Icon(Icons.face_outlined),
    ),
  ];
}
