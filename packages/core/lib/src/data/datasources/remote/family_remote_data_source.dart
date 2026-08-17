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
    final results = await Future.wait([
      _client.select('families', order: 'updated_at.asc'),
      _client.select('babies', order: 'updated_at.asc'),
      _client.select('baby_caregivers'),
      _client.select('profiles'),
    ]);
    final families = results[0];
    final babies = results[1];
    final memberships = results[2];
    final profiles = results[3];
    final profileById = {
      for (final profile in profiles)
        _requiredText(profile, 'id', entity: 'perfil'): profile,
    };

    // Do not hydrate child tables from an incomplete parent graph. A local
    // pending snapshot is pushed before this pull and can repair the same Baby
    // id; any remaining invalid row needs an explicit server-side repair.
    for (final baby in babies) {
      final babyId = _requiredText(baby, 'id', entity: 'bebé');
      _requiredText(baby, 'family_id', entity: 'bebé $babyId');
      _requiredText(baby, 'display_name', entity: 'bebé $babyId');
      _requiredDateTime(baby, 'birth_date', entity: 'bebé $babyId');
    }

    final snapshots = <FamilySyncSnapshot>[];
    for (final family in families) {
      final familyId = _requiredText(family, 'id', entity: 'familia');
      final familyName = _requiredText(
        family,
        'name',
        entity: 'familia $familyId',
      );
      final familyBabies = babies
          .where((baby) => baby['family_id'] == familyId)
          .map(
            (baby) => BabyEntity(
              id: _requiredText(baby, 'id', entity: 'bebé'),
              familyId: familyId,
              name: _requiredText(
                baby,
                'display_name',
                entity: 'bebé ${baby['id']}',
              ),
              birthDate: _requiredDateTime(
                baby,
                'birth_date',
                entity: 'bebé ${baby['id']}',
              ),
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
            name: familyName,
            activeBabyId: familyBabies.first.id,
            babies: familyBabies,
            members: members,
          ),
          updatedAt: _requiredDateTime(
            family,
            'updated_at',
            entity: 'familia $familyId',
          ),
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

  static String _requiredText(
    Map<String, dynamic> row,
    String field, {
    required String entity,
  }) {
    final value = row[field];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    throw FormatException(
      'Supabase contiene un $entity incompleto: falta $field. '
      'Corrige el perfil del bebé antes de sincronizar sus registros.',
    );
  }

  static DateTime _requiredDateTime(
    Map<String, dynamic> row,
    String field, {
    required String entity,
  }) {
    final value = row[field];
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed != null) return parsed.toUtc();
    throw FormatException(
      'Supabase contiene un $entity incompleto: falta $field o no es válido. '
      'Corrige el perfil del bebé antes de sincronizar sus registros.',
    );
  }
}
