import '../../../domain/entities/family/family.dart';
import '../../models/family_models.dart';
import '../../network/supabase_rest_client.dart';

abstract interface class FamilyRemoteDataSource {
  bool get isConfigured;

  Future<bool> isAuthenticated();

  Future<FamilySyncSnapshot> push(FamilySyncSnapshot snapshot);

  Future<List<FamilySyncSnapshot>> pull();

  Future<void> createInvitation(Map<String, Object?> parameters);

  Future<void> resendInvitation({
    required String code,
    required String newCode,
  });

  Future<void> revokeInvitation(String code);
}

class SupabaseFamilyRemoteDataSource implements FamilyRemoteDataSource {
  const SupabaseFamilyRemoteDataSource(this._client);

  final SupabaseRestClient _client;

  @override
  bool get isConfigured => _client.isConfigured;

  @override
  Future<bool> isAuthenticated() => _client.isAuthenticated();

  @override
  Future<FamilySyncSnapshot> push(FamilySyncSnapshot snapshot) async {
    await _client.rpc(
      'apply_family_snapshot',
      parameters: {'payload': snapshot.toRemoteJson()},
    );
    final snapshots = await pull();
    return snapshots.firstWhere(
      (candidate) => candidate.overview.id == snapshot.overview.id,
      orElse: () => snapshot,
    );
  }

  @override
  Future<List<FamilySyncSnapshot>> pull() async {
    final families = await _client.select('families', order: 'updated_at.asc');
    final babies = await _client.select('babies', order: 'updated_at.asc');
    final memberships = await _client.select('baby_caregivers');
    final profiles = await _client.select('profiles');
    final profileById = {
      for (final profile in profiles) profile['id'] as String: profile,
    };

    final snapshots = <FamilySyncSnapshot>[];
    for (final family in families) {
      final familyId = family['id']! as String;
      final familyBabies = babies
          .where((baby) => baby['family_id'] == familyId)
          .map(
            (baby) => BabyEntity(
              id: baby['id']! as String,
              familyId: familyId,
              name: baby['display_name']! as String,
              birthDate: DateTime.parse(baby['birth_date']! as String).toUtc(),
            ),
          )
          .toList(growable: false);
      final babyIds = familyBabies.map((baby) => baby.id).toSet();
      // Old deployments may retain an empty compatibility family after its
      // baby is attached to the canonical local family id.
      if (babyIds.isEmpty) continue;
      final seenUsers = <String>{};
      final members = <FamilyMemberEntity>[];
      for (final membership in memberships) {
        if (!babyIds.contains(membership['baby_id'])) continue;
        final userId = membership['user_id']! as String;
        if (!seenUsers.add(userId)) continue;
        final profile = profileById[userId];
        final canWrite = membership['can_write'] as bool? ?? false;
        members.add(
          FamilyMemberEntity(
            id: 'member-$userId-$familyId',
            familyId: familyId,
            name: profile?['display_name'] as String? ?? 'Cuidador/a',
            role: _roleLabel(membership['role'] as String?),
            accessDescription: canWrite
                ? 'Puede acompañar y registrar cuidados'
                : 'Acceso de solo lectura',
            status: FamilyMemberStatus.active,
            contact: profile?['email'] as String?,
          ),
        );
      }
      snapshots.add(
        FamilySyncSnapshot(
          overview: FamilyOverviewEntity(
            id: familyId,
            name: family['name']! as String,
            activeBabyId: familyBabies.first.id,
            babies: familyBabies,
            members: members,
          ),
          updatedAt: DateTime.parse(family['updated_at']! as String).toUtc(),
        ),
      );
    }
    return List.unmodifiable(snapshots);
  }

  @override
  Future<void> createInvitation(Map<String, Object?> parameters) async {
    await _client.rpc('create_care_invitation', parameters: parameters);
  }

  @override
  Future<void> resendInvitation({
    required String code,
    required String newCode,
  }) async {
    await _client.rpc(
      'resend_care_invitation',
      parameters: {'p_code': code, 'p_new_code': newCode},
    );
  }

  @override
  Future<void> revokeInvitation(String code) async {
    await _client.rpc('revoke_care_invitation', parameters: {'p_code': code});
  }

  static String _roleLabel(String? role) => switch (role) {
    'owner' => 'Administrador/a',
    'viewer' => 'Observador/a',
    _ => 'Cuidador/a',
  };
}
