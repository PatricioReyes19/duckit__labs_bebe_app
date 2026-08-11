import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:register/register.dart';

void main() {
  late _MemoryRegisterEventRepository repository;
  late SaveRegisterEvent saveRegisterEvent;

  setUp(() {
    repository = _MemoryRegisterEventRepository();
    saveRegisterEvent = SaveRegisterEvent(repository);
  });

  test('maps the home medicine action to the medication form', () {
    expect(
      RegisterEventKind.fromRouteValue('medicine'),
      RegisterEventKind.medication,
    );
  });

  test('each form Cubit creates and saves its own event type', () async {
    final feeding = FeedingRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    );
    final sleep = SleepRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    );
    final diaper = DiaperRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    );
    final clinical = ClinicalObservationRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )..descriptionChanged('Irritación leve');
    final medication = MedicationRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )
      ..nameChanged('Paracetamol')
      ..doseChanged('2,5');
    final measurement = MeasurementRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )..valueChanged('5,8');
    final cubits = <RegisterFormCubit>[
      feeding,
      sleep,
      diaper,
      clinical,
      medication,
      measurement,
    ];
    addTearDown(() async {
      for (final cubit in cubits) {
        await cubit.close();
      }
    });

    for (final cubit in cubits) {
      await cubit.submit();
      expect(cubit.state.status, RegisterSubmissionStatus.success);
    }

    expect(repository.drafts.map((draft) => draft.type), [
      RegisterEventType.feeding,
      RegisterEventType.sleep,
      RegisterEventType.diaper,
      RegisterEventType.clinicalObservation,
      RegisterEventType.medication,
      RegisterEventType.measurement,
    ]);
  });

  test('medication rejects incomplete data before touching storage', () async {
    final cubit = MedicationRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    );
    addTearDown(cubit.close);

    await cubit.submit();

    expect(cubit.state.status, RegisterSubmissionStatus.failure);
    expect(cubit.state.message, 'Ingresa el nombre del medicamento.');
    expect(repository.drafts, isEmpty);
  });

  test('bottle feeding requires and persists milliliters instead of side',
      () async {
    final cubit = FeedingRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )
      ..subtypeChanged('bottle')
      ..amountMlChanged('90,5');
    addTearDown(cubit.close);

    await cubit.submit();

    expect(cubit.state.status, RegisterSubmissionStatus.success);
    expect(repository.drafts.single.details['amount_ml'], 90.5);
    expect(repository.drafts.single.details.containsKey('side'), isFalse);
  });

  test('bottle feeding rejects a missing amount', () async {
    final cubit = FeedingRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )..subtypeChanged('formula');
    addTearDown(cubit.close);

    await cubit.submit();

    expect(cubit.state.status, RegisterSubmissionStatus.failure);
    expect(cubit.state.message, 'Ingresa la cantidad tomada en mL.');
    expect(repository.drafts, isEmpty);
  });

  test('bottle feeding persists the next alarm interval', () async {
    final cubit = FeedingRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )
      ..subtypeChanged('formula')
      ..amountMlChanged('120')
      ..scheduleNextFeedingChanged(true)
      ..reminderHoursChanged(3);
    addTearDown(cubit.close);

    await cubit.submit();

    expect(repository.drafts.single.details['schedule_next_feeding'], isTrue);
    expect(repository.drafts.single.details['reminder_interval_hours'], 3);
  });

  test('wet diaper persists urine data without stool characteristics',
      () async {
    final cubit = DiaperRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )
      ..subtypeChanged('wet')
      ..urineColorChanged('yellow')
      ..urineAmountChanged('much');
    addTearDown(cubit.close);

    await cubit.submit();

    final details = repository.drafts.single.details;
    expect(details['urine_color'], 'yellow');
    expect(details['urine_amount'], 'much');
    expect(details.containsKey('appearance'), isFalse);
    expect(details.containsKey('color'), isFalse);
  });

  test('mixed diaper persists urine and stool data', () async {
    final cubit = DiaperRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )..subtypeChanged('mixed');
    addTearDown(cubit.close);

    await cubit.submit();

    final details = repository.drafts.single.details;
    expect(details.containsKey('urine_color'), isTrue);
    expect(details.containsKey('urine_amount'), isTrue);
    expect(details.containsKey('appearance'), isTrue);
    expect(details.containsKey('amount'), isTrue);
  });

  test('diaper change persists the requested reminder interval', () async {
    final cubit = DiaperRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )
      ..scheduleReminderChanged(true)
      ..reminderHoursChanged(4);
    addTearDown(cubit.close);

    await cubit.submit();

    expect(repository.drafts.single.details['schedule_reminder'], isTrue);
    expect(repository.drafts.single.details['reminder_interval_hours'], 4);
  });

  test('measurement normalizes decimal comma before persistence', () async {
    final cubit = MeasurementRegisterCubit(
      saveRegisterEvent: saveRegisterEvent,
      babyId: 'baby-1',
    )
      ..measurementTypeChanged('weight')
      ..valueChanged('5,9');
    addTearDown(cubit.close);

    await cubit.submit();

    expect(repository.drafts.single.details['value'], 5.9);
    expect(repository.drafts.single.details['unit'], 'kg');
  });
}

class _MemoryRegisterEventRepository implements RegisterEventRepository {
  final drafts = <RegisterEventDraft>[];

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<RegisteredEvent> save(RegisterEventDraft draft) async {
    drafts.add(draft);
    return RegisteredEvent(
      id: 'event-${drafts.length}',
      babyId: draft.babyId,
      type: draft.type,
      occurredAt: draft.occurredAt,
      createdAt: DateTime.utc(2026, 8, 5),
      details: draft.details,
      notes: draft.notes,
      caregiverId: draft.caregiverId,
      schemaVersion: draft.schemaVersion,
    );
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<RegisteredEvent?> findById(String id) async => null;

  @override
  Future<RegisteredEvent?> update(
    String id,
    RegisterEventPatch patch,
  ) async =>
      null;

  @override
  Future<List<RegisteredEvent>> listByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async =>
      const [];

  @override
  Stream<List<RegisteredEvent>> observeByBaby(
    String babyId, {
    RegisterEventType? type,
    int? limit,
  }) async* {
    yield await listByBaby(babyId, type: type, limit: limit);
  }
}
