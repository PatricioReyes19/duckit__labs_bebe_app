import '../models/models.dart';

/// Puerto para la persistencia del flujo inicial.
///
/// La implementación Firebase podrá usar Firestore y Cloud Functions para
/// validar invitaciones de forma atómica sin modificar el Cubit ni las vistas.
abstract interface class OnboardingRepository {
  Future<bool> isCompleted();

  Future<InvitationLookupResult> findInvitation(String code);

  Future<void> acceptInvitation(CareInvitation invitation);

  Future<void> declineInvitation(CareInvitation invitation);

  Future<BabyProfile> createBaby(BabyDraft draft);

  Future<void> complete();
}
