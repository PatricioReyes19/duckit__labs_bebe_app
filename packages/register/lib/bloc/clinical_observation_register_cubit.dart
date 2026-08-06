import 'package:core/core.dart';

import 'register_form_cubit.dart';

class ClinicalObservationRegisterCubit extends RegisterFormCubit {
  ClinicalObservationRegisterCubit({
    required super.saveRegisterEvent,
    required super.babyId,
    DateTime? initialDateTime,
  }) : super(
          initialValues: {
            'observationType': 'stool',
            'occurredAt': initialDateTime ?? DateTime.now(),
            'description': '',
            'photoPaths': <String>[],
            'severity': 'mild',
            'shareWithPediatrician': true,
            'caregiver': 'father',
          },
        );

  String get observationType => state.value<String>('observationType');
  DateTime get occurredAt => state.value<DateTime>('occurredAt');
  String get description => state.value<String>('description');
  List<String> get photoPaths => state.value<List<String>>('photoPaths');
  String get severity => state.value<String>('severity');
  bool get shareWithPediatrician => state.value<bool>('shareWithPediatrician');
  String get caregiver => state.value<String>('caregiver');

  void observationTypeChanged(String value) =>
      setValue('observationType', value);
  void dateChanged(DateTime value) =>
      setValue('occurredAt', replaceDate(occurredAt, value));
  void timeChanged(int hour, int minute) =>
      setValue('occurredAt', replaceTime(occurredAt, hour, minute));
  void descriptionChanged(String value) => setValue('description', value);
  void photoAdded(String path) => setValue('photoPaths', [...photoPaths, path]);
  void photoRemoved(String path) => setValue(
        'photoPaths',
        photoPaths.where((item) => item != path).toList(growable: false),
      );
  void severityChanged(String value) => setValue('severity', value);
  void shareChanged(bool value) => setValue('shareWithPediatrician', value);
  void caregiverChanged(String value) => setValue('caregiver', value);

  @override
  RegisterEventDraft buildDraft() {
    final normalizedDescription = description.trim();
    if (normalizedDescription.isEmpty) {
      throw const RegisterValidationException(
        'Describe la observación antes de guardar.',
      );
    }
    return RegisterEventDraft(
      babyId: babyId,
      type: RegisterEventType.clinicalObservation,
      occurredAt: occurredAt,
      caregiverId: caregiver,
      details: {
        'observation_type': observationType,
        'description': normalizedDescription,
        'photo_paths': photoPaths,
        'severity': severity,
        'share_with_pediatrician': shareWithPediatrician,
      },
    );
  }
}
