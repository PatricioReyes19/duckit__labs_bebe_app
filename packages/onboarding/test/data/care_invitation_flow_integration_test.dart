import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboarding/onboarding.dart' hide BabyDraft;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  const invitedUser = AuthUser(
    id: 'user-invited',
    email: 'abuela@example.com',
    displayName: 'Ana Pérez',
    emailVerification: true,
  );

  test(
    'the invited account resolves, accepts and stores the canonical circle',
    () async {
      SharedPreferences.setMockInitialValues({});
      final client = _MockSupabaseRestClient();
      final family = _RecordingFamilyRepository();
      when(client.isAuthenticated).thenAnswer((_) async => true);
      when(
        () => client.rpc(
          'lookup_care_invitation',
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer(
        (_) async => const {
          'found': true,
          'id': 'invitation-1',
          'family_id': 'family-1',
          'baby_id': 'baby-1',
          'baby_name': 'Mateo',
          'baby_birth_date': '2026-01-10',
          'baby_age_label': '7 meses',
          'inviter_name': 'María López',
          'inviter_relationship': 'Mamá',
        },
      );
      when(
        () => client.rpc(
          'accept_care_invitation',
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer(
        (_) async => const {
          'id': 'invitation-1',
          'status': 'accepted',
        },
      );
      final repository = LocalOnboardingRepository(
        SharedPreferencesAsync(),
        currentUserId: () async => invitedUser.id,
        currentUser: () async => invitedUser,
        familyRepository: family,
        remoteClient: client,
      );

      final lookup = await repository.findInvitation(' family42 ');
      await repository.acceptInvitation(lookup.invitation!);

      final joined = family.joinedDraft;
      expect(lookup.isValid, isTrue);
      expect(lookup.invitation!.code, 'FAMILY42');
      expect(joined, isNotNull);
      expect(joined!.familyId, 'family-1');
      expect(joined.babyId, 'baby-1');
      expect(joined.babyBirthDate, DateTime.utc(2026, 1, 10));
      expect(joined.memberId, 'member-user-invited-family-1');
      expect(joined.memberName, 'Ana Pérez');
      expect(joined.memberEmail, 'abuela@example.com');
      expect(await repository.isCompleted(), isTrue);
      verify(
        () => client.rpc(
          'accept_care_invitation',
          parameters: const {'p_code': 'FAMILY42'},
        ),
      ).called(1);
    },
  );

  test('an invitation cannot be opened with a different account', () async {
    SharedPreferences.setMockInitialValues({});
    final client = _MockSupabaseRestClient();
    when(client.isAuthenticated).thenAnswer((_) async => true);
    when(
      () => client.rpc(
        'lookup_care_invitation',
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer(
      (_) async => const {'found': false, 'failure': 'wrong_account'},
    );
    final repository = LocalOnboardingRepository(
      SharedPreferencesAsync(),
      currentUserId: () async => 'another-user',
      remoteClient: client,
    );

    final lookup = await repository.findInvitation('FAMILY42');

    expect(lookup.isValid, isFalse);
    expect(lookup.failure, InvitationFailureReason.wrongAccount);
  });
}

class _MockSupabaseRestClient extends Mock implements SupabaseRestClient {}

class _RecordingFamilyRepository implements FamilyRepository {
  JoinedCareCircleDraft? joinedDraft;

  @override
  Stream<String> get activeBabyChanges => const Stream.empty();

  @override
  Future<FamilyOverviewEntity> joinCareCircle(
    JoinedCareCircleDraft draft,
  ) async {
    joinedDraft = draft;
    return FamilyOverviewEntity(
      id: draft.familyId,
      name: draft.familyName,
      activeBabyId: draft.babyId,
      babies: [
        BabyEntity(
          id: draft.babyId,
          familyId: draft.familyId,
          name: draft.babyName,
          birthDate: draft.babyBirthDate,
        ),
      ],
      members: [
        FamilyMemberEntity(
          id: draft.memberId,
          familyId: draft.familyId,
          name: draft.memberName,
          role: draft.memberRole,
          accessDescription: 'Puede acompañar y registrar cuidados',
          status: FamilyMemberStatus.active,
          contact: draft.memberEmail,
        ),
      ],
    );
  }

  @override
  Future<void> cancelInvitation(String memberId) =>
      throw UnsupportedError('not used');

  @override
  Future<BabyEntity> createBaby(BabyDraft draft) =>
      throw UnsupportedError('not used');

  @override
  Future<FamilyOverviewEntity> createInitialFamily(InitialFamilyDraft draft) =>
      throw UnsupportedError('not used');

  @override
  Future<FamilyOverviewEntity> getCurrent() =>
      throw UnsupportedError('not used');

  @override
  Future<FamilyMemberEntity?> resendInvitation(String memberId) =>
      throw UnsupportedError('not used');

  @override
  Future<FamilyMemberEntity> sendInvitation(FamilyInvitationDraft draft) =>
      throw UnsupportedError('not used');

  @override
  Future<FamilyOverviewEntity> setActiveBaby(String babyId) =>
      throw UnsupportedError('not used');

  @override
  Future<BabyEntity?> updateBaby(String id, BabyPatch patch) =>
      throw UnsupportedError('not used');
}
