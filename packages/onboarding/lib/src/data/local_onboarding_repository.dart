import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_repository.dart';
import '../models/models.dart';

/// Adaptador navegable para desarrollo y pruebas manuales.
///
/// Códigos útiles: MATEO2026, VENCIDA, REVOCADA, CUENTA y YAESTOY.
class LocalOnboardingRepository implements OnboardingRepository {
  LocalOnboardingRepository(this._preferences);

  final SharedPreferencesAsync _preferences;

  static const completedKey = 'bebeapp.onboarding.completed';
  static const babyNameKey = 'bebeapp.active_baby.name';
  static const babyBirthDateKey = 'bebeapp.active_baby.birth_date';
  static const babySexReferenceKey = 'bebeapp.active_baby.sex_reference';

  @override
  Future<bool> isCompleted() async {
    return await _preferences.getBool(completedKey) ?? false;
  }

  @override
  Future<InvitationLookupResult> findInvitation(String code) async {
    final normalized = code.trim().toUpperCase().replaceAll(' ', '');
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return switch (normalized) {
      'MATEO2026' || 'FAMILIA2026' => const InvitationLookupResult.valid(
          CareInvitation(
            id: 'local-invitation-mateo',
            code: 'MATEO2026',
            inviterName: 'María López',
            inviterRelationship: 'Mamá',
            babyName: 'Mateo López',
            babyAgeLabel: '8 meses',
          ),
        ),
      'VENCIDA' => const InvitationLookupResult.invalid(
          InvitationFailureReason.expired,
        ),
      'REVOCADA' => const InvitationLookupResult.invalid(
          InvitationFailureReason.revoked,
        ),
      'CUENTA' => const InvitationLookupResult.invalid(
          InvitationFailureReason.wrongAccount,
        ),
      'YAESTOY' => const InvitationLookupResult.invalid(
          InvitationFailureReason.alreadyMember,
        ),
      _ => const InvitationLookupResult.invalid(
          InvitationFailureReason.notFound,
        ),
    };
  }

  @override
  Future<void> acceptInvitation(CareInvitation invitation) async {
    await _preferences.setString(babyNameKey, invitation.babyName);
    await complete();
  }

  @override
  Future<void> declineInvitation(CareInvitation invitation) async {}

  @override
  Future<BabyProfile> createBaby(BabyDraft draft) async {
    final id = 'local-baby-${DateTime.now().microsecondsSinceEpoch}';
    await _preferences.setString(babyNameKey, draft.name);
    await _preferences.setString(
      babyBirthDateKey,
      draft.birthDate.toIso8601String(),
    );
    await _preferences.setString(
      babySexReferenceKey,
      draft.sexReference.name,
    );
    await complete();
    return BabyProfile(
      id: id,
      name: draft.name,
      birthDate: draft.birthDate,
      sexReference: draft.sexReference,
    );
  }

  @override
  Future<void> complete() => _preferences.setBool(completedKey, true);
}
