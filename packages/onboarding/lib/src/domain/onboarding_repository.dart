import '../models/models.dart';

abstract interface class OnboardingRepository {
  Future<bool> isCompleted();

  Future<InvitationLookupResult> findInvitation(String code);

  Future<void> acceptInvitation(CareInvitation invitation);

  Future<void> declineInvitation(CareInvitation invitation);

  Future<BabyProfile> createBaby(BabyDraft draft);

  Future<void> complete();
}
