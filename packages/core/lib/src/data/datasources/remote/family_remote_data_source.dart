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
    // The following aggregate pull is owned by FamilySyncService. Pulling
    // here as well doubled every family write from four reads to eight.
    return snapshot;
  }

  @override
  Future<List<FamilySyncSnapshot>> pull() async {
    final results = await Future.wait([
      _client.select(
        'families',
        columns: 'id,name,updated_at',
        order: 'updated_at.asc',
      ),
      _client.select(
        'babies',
        columns:
            'id,family_id,display_name,birth_date,is_premature,lives_in_rapa_nui,has_rsv_risk,updated_at',
        order: 'updated_at.asc',
      ),
      _client.select(
        'baby_caregivers',
        columns: 'baby_id,user_id,role,can_write',
      ),
      _client.select('profiles', columns: 'id,display_name,email'),
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
              isPremature: baby['is_premature'] == true,
              livesInRapaNui: baby['lives_in_rapa_nui'] == true,
              hasRsvRisk: baby['has_rsv_risk'] == true,
            ),
          )
          .toList(growable: false);
      final babyIds = familyBabies.map((baby) => baby.id).toSet();
      // Old deployments may retain an empty compatibility family after its
      // baby is attached to the canonical local family id.
      if (babyIds.isEmpty) continue;
      final membershipsByUser = <String, List<Map<String, dynamic>>>{};
      for (final membership in memberships) {
        if (!babyIds.contains(membership['baby_id'])) continue;
        final userId = _requiredText(
          membership,
          'user_id',
          entity: 'membresía',
        );
        membershipsByUser.putIfAbsent(userId, () => []).add(membership);
      }
      final members = <FamilyMemberEntity>[];
      for (final entry in membershipsByUser.entries) {
        final userId = entry.key;
        final userMemberships = entry.value;
        final profile = profileById[userId];
        // Memberships are per baby. The family summary must not let a write
        // grant for one baby overstate access to any other baby in the circle.
        final canWrite = userMemberships.every(
          (membership) => membership['can_write'] == true,
        );
        members.add(
          FamilyMemberEntity(
            id: 'member-$userId-$familyId',
            familyId: familyId,
            name: profile?['display_name'] as String? ?? 'Cuidador/a',
            role: _mostRestrictiveRole(
              userMemberships.map((membership) => membership['role']),
            ),
            accessDescription: canWrite
                ? 'Puede acompañar y registrar cuidados'
                : 'Acceso de solo lectura',
            status: FamilyMemberStatus.active,
            canWrite: canWrite,
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

  static String _mostRestrictiveRole(Iterable<Object?> roles) {
    final normalized = roles.map((role) => role?.toString()).toSet();
    if (normalized.contains('viewer')) return 'Observador/a';
    if (normalized.any((role) => role != 'owner' && role != 'caregiver')) {
      return 'Acceso pendiente de confirmación';
    }
    if (normalized.contains('caregiver')) return 'Cuidador/a';
    return normalized.contains('owner')
        ? 'Administrador/a'
        : 'Acceso pendiente de confirmación';
  }

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
