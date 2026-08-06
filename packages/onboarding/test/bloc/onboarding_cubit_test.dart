import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding/onboarding.dart';

void main() {
  blocTest<OnboardingCubit, OnboardingState>(
    'prioriza una invitación válida y muestra su revisión',
    build: () => OnboardingCubit(
      repository: _FakeOnboardingRepository(),
      entry: OnboardingEntry.invitation,
    ),
    act: (cubit) async {
      cubit.invitationCodeChanged('MATEO2026');
      await cubit.invitationSubmitted();
    },
    verify: (cubit) {
      expect(cubit.state.step, OnboardingStep.invitationReview);
      expect(cubit.state.invitation?.babyName, 'Mateo López');
    },
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'crea el perfil solo con los datos mínimos completos',
    build: () => OnboardingCubit(repository: _FakeOnboardingRepository()),
    act: (cubit) async {
      cubit.createBabySelected();
      cubit.babyNameChanged('Mateo');
      cubit.birthDateChanged(DateTime(2026, 1, 10));
      cubit.sexReferenceChanged(SexReference.male);
      await cubit.babySubmitted();
    },
    verify: (cubit) {
      expect(cubit.state.step, OnboardingStep.babyCreated);
      expect(cubit.state.createdBaby?.name, 'Mateo');
    },
  );
}

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> acceptInvitation(CareInvitation invitation) async {}

  @override
  Future<void> complete() async {}

  @override
  Future<BabyProfile> createBaby(BabyDraft draft) async {
    return BabyProfile(
      id: '1',
      name: draft.name,
      birthDate: draft.birthDate,
      sexReference: draft.sexReference,
    );
  }

  @override
  Future<void> declineInvitation(CareInvitation invitation) async {}

  @override
  Future<InvitationLookupResult> findInvitation(String code) async {
    return const InvitationLookupResult.valid(
      CareInvitation(
        id: '1',
        code: 'MATEO2026',
        inviterName: 'María López',
        inviterRelationship: 'Mamá',
        babyName: 'Mateo López',
        babyAgeLabel: '8 meses',
      ),
    );
  }

  @override
  Future<bool> isCompleted() async => false;
}
