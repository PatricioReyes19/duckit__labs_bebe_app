import 'dart:io';

import 'package:core/core.dart' as core;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_repository.dart';
import '../models/models.dart';

/// Adaptador navegable para desarrollo y pruebas manuales.
///
/// Códigos útiles: MATEO2026, VENCIDA, REVOCADA, CUENTA y YAESTOY.
class LocalOnboardingRepository implements OnboardingRepository {
  LocalOnboardingRepository(
    this._preferences, {
    Future<String?> Function()? currentUserId,
    Future<core.AuthUser?> Function()? currentUser,
    core.FamilyRepository? familyRepository,
    core.SupabaseRestClient? remoteClient,
    Future<Directory> Function()? storageDirectory,
  })  : _currentUserId = currentUserId,
        _currentUser = currentUser,
        _familyRepository = familyRepository,
        _remoteClient = remoteClient,
        _storageDirectory = storageDirectory ?? getApplicationSupportDirectory;

  final SharedPreferencesAsync _preferences;
  final Future<String?> Function()? _currentUserId;
  final Future<core.AuthUser?> Function()? _currentUser;
  final core.FamilyRepository? _familyRepository;
  final core.SupabaseRestClient? _remoteClient;
  final Future<Directory> Function() _storageDirectory;

  static const completedKey = 'bebeapp.onboarding.completed';
  static const babyNameKey = 'bebeapp.active_baby.name';
  static const babyBirthDateKey = 'bebeapp.active_baby.birth_date';
  static const babySexReferenceKey = 'bebeapp.active_baby.sex_reference';

  @override
  Future<bool> isCompleted() async {
    return await _preferences.getBool(await _scopedKey(completedKey)) ?? false;
  }

  @override
  Future<InvitationLookupResult> findInvitation(String code) async {
    final normalized = code.trim().toUpperCase().replaceAll(' ', '');
    final client = _remoteClient;
    if (client != null && await client.isAuthenticated()) {
      final payload = await client.rpc(
        'lookup_care_invitation',
        parameters: {'p_code': normalized},
      );
      return _invitationResultFromRemote(payload, normalized);
    }
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
    final client = _remoteClient;
    if (client != null && await client.isAuthenticated()) {
      await client.rpc(
        'accept_care_invitation',
        parameters: {'p_code': invitation.code},
      );
    }
    final user = await _currentUser?.call();
    final userId = user?.id ?? await _currentUserId?.call() ?? 'local-member';
    final familyRepository = _familyRepository;
    if (familyRepository != null) {
      await familyRepository.joinCareCircle(
        core.JoinedCareCircleDraft(
          familyId: invitation.familyId ?? 'family-${invitation.code}',
          familyName: 'Círculo de ${invitation.babyName}',
          babyId: invitation.babyId ?? 'baby-${invitation.code}',
          babyName: invitation.babyName,
          babyBirthDate: _estimatedBirthDate(invitation.babyAgeLabel),
          memberId: 'member-$userId-${invitation.familyId ?? invitation.code}',
          memberName: user?.displayName ?? 'Cuidador/a',
          memberEmail: user?.email ?? '',
        ),
      );
    }
    await _preferences.setString(
      await _scopedKey(babyNameKey),
      invitation.babyName,
    );
    await complete();
  }

  @override
  Future<void> declineInvitation(CareInvitation invitation) async {
    final client = _remoteClient;
    if (client != null && await client.isAuthenticated()) {
      await client.rpc(
        'reject_care_invitation',
        parameters: {'p_code': invitation.code},
      );
    }
    await _preferences.setString(
      await _scopedKey('bebeapp.invitation.last_declined'),
      invitation.code,
    );
  }

  @override
  Future<BabyProfile> createBaby(BabyDraft draft) async {
    final user = await _currentUser?.call();
    final scopeId = user?.id ?? await _currentUserId?.call() ?? 'local';
    final storedPhotoPath = await _persistPhoto(draft.photoPath, scopeId);
    var id = 'local-baby-${DateTime.now().microsecondsSinceEpoch}';

    final familyRepository = _familyRepository;
    if (familyRepository != null) {
      final family = await familyRepository.createInitialFamily(
        core.InitialFamilyDraft(
          familyName: 'Círculo de ${draft.name.trim()}',
          babyName: draft.name,
          birthDate: draft.birthDate,
          ownerName: user?.displayName ?? 'Cuidador principal',
          ownerEmail: user?.email ?? '',
          avatarAssetPath: storedPhotoPath,
        ),
      );
      id = family.activeBaby.id;
    }
    await _preferences.setString(await _scopedKey(babyNameKey), draft.name);
    await _preferences.setString(
      await _scopedKey(babyBirthDateKey),
      draft.birthDate.toIso8601String(),
    );
    await _preferences.setString(
      await _scopedKey(babySexReferenceKey),
      draft.sexReference.name,
    );
    await complete();
    return BabyProfile(
      id: id,
      name: draft.name,
      birthDate: draft.birthDate,
      sexReference: draft.sexReference,
      photoPath: storedPhotoPath,
    );
  }

  @override
  Future<void> complete() async {
    await _preferences.setBool(await _scopedKey(completedKey), true);
  }

  Future<String> _scopedKey(String key) async {
    final userId = await _currentUserId?.call();
    return userId == null || userId.isEmpty ? key : '$key.$userId';
  }

  Future<String?> _persistPhoto(String? sourcePath, String scopeId) async {
    final normalized = sourcePath?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    final source = File(normalized);
    if (!await source.exists()) {
      throw StateError('La fotografía seleccionada ya no está disponible.');
    }
    final root = await _storageDirectory();
    final safeScope = scopeId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}baby_profiles'
      '${Platform.pathSeparator}$safeScope',
    );
    await directory.create(recursive: true);
    final extension = _extensionOf(normalized);
    final destination = File(
      '${directory.path}${Platform.pathSeparator}'
      'avatar_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    await source.copy(destination.path);
    return destination.path;
  }

  static String _extensionOf(String path) {
    final separator = path.lastIndexOf('.');
    if (separator < 0) return '.jpg';
    final extension = path.substring(separator).toLowerCase();
    return const {'.jpg', '.jpeg', '.png', '.webp', '.heic'}.contains(extension)
        ? extension
        : '.jpg';
  }

  static DateTime _estimatedBirthDate(String ageLabel) {
    final months = int.tryParse(
      RegExp(r'\d+').firstMatch(ageLabel)?.group(0) ?? '',
    );
    final now = DateTime.now();
    return DateTime(now.year, now.month - (months ?? 0), now.day);
  }

  static InvitationLookupResult _invitationResultFromRemote(
    Object? payload,
    String code,
  ) {
    final raw = payload is Map ? Map<String, Object?>.from(payload) : null;
    if (raw == null || raw['found'] != true) {
      final failure = switch (raw?['failure']) {
        'expired' => InvitationFailureReason.expired,
        'revoked' || 'rejected' => InvitationFailureReason.revoked,
        'wrong_account' => InvitationFailureReason.wrongAccount,
        'already_member' => InvitationFailureReason.alreadyMember,
        _ => InvitationFailureReason.notFound,
      };
      return InvitationLookupResult.invalid(failure);
    }
    final babyId = raw['baby_id']?.toString() ?? '';
    return InvitationLookupResult.valid(
      CareInvitation(
        id: raw['id']?.toString() ?? code,
        code: code,
        inviterName: raw['inviter_name']?.toString() ?? 'Tu familiar',
        inviterRelationship:
            raw['inviter_relationship']?.toString() ?? 'Administrador/a',
        babyName: raw['baby_name']?.toString() ?? 'Bebé',
        babyAgeLabel: raw['baby_age_label']?.toString() ?? 'Círculo compartido',
        familyId: 'family-$babyId',
        babyId: babyId,
      ),
    );
  }
}
