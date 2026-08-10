import '../../domain/entities/agenda/agenda.dart';
import '../../domain/entities/family/family.dart';

class AgendaEventModel {
  const AgendaEventModel({
    required this.id,
    required this.babyId,
    required this.category,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.syncStatus,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.caregiverId,
    this.caregiver,
    this.sourceRegisterEventId,
    this.syncError,
  });

  final String id;
  final String babyId;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? caregiverId;
  final FamilyMemberEntity? caregiver;
  final String? sourceRegisterEventId;
  final AgendaSyncStatus syncStatus;
  final String? syncError;

  factory AgendaEventModel.fromEntity(AgendaEventEntity entity) =>
      AgendaEventModel(
        id: entity.id,
        babyId: entity.babyId,
        category: entity.category,
        title: entity.title,
        description: entity.description,
        startsAt: entity.startsAt,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        deletedAt: entity.deletedAt,
        caregiverId: entity.caregiverId,
        caregiver: entity.caregiver,
        sourceRegisterEventId: entity.sourceRegisterEventId,
        syncStatus: entity.syncStatus,
        syncError: entity.syncError,
      );

  factory AgendaEventModel.fromRemoteJson(Map<String, dynamic> json) =>
      AgendaEventModel(
        id: json['id']! as String,
        babyId: json['baby_id']! as String,
        category: _categoryFromStorage(json['category']! as String),
        title: json['title']! as String,
        description: (json['description'] as String?) ?? '',
        startsAt: _remoteDate(json, 'starts_at'),
        createdAt: _remoteDate(json, 'created_at'),
        updatedAt: _remoteDate(json, 'updated_at'),
        deletedAt: _nullableRemoteDate(json['deleted_at']),
        caregiverId: json['caregiver_id'] as String?,
        sourceRegisterEventId: json['source_register_event_id'] as String?,
        syncStatus: AgendaSyncStatus.synced,
      );

  factory AgendaEventModel.fromRow(Map<String, Object?> row) {
    final caregiverName = row['caregiver_name'] as String?;
    return AgendaEventModel(
      id: row['id']! as String,
      babyId: row['baby_id']! as String,
      category: _categoryFromStorage(row['category']! as String),
      title: row['title']! as String,
      description: row['description']! as String,
      startsAt: DateTime.fromMillisecondsSinceEpoch(
        row['starts_at']! as int,
        isUtc: true,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (row['created_at'] as int?) ?? row['starts_at']! as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (row['updated_at'] as int?) ?? row['starts_at']! as int,
        isUtc: true,
      ),
      deletedAt: switch (row['deleted_at']) {
        final int value => DateTime.fromMillisecondsSinceEpoch(
          value,
          isUtc: true,
        ),
        _ => null,
      },
      caregiverId: row['caregiver_id'] as String?,
      sourceRegisterEventId: row['source_register_event_id'] as String?,
      caregiver: caregiverName == null
          ? null
          : FamilyMemberEntity(
              id: row['caregiver_id']! as String,
              familyId: row['caregiver_family_id']! as String,
              name: caregiverName,
              role: row['caregiver_role']! as String,
              accessDescription: row['caregiver_access_description']! as String,
              status: (row['caregiver_status']! as String) == 'pending'
                  ? FamilyMemberStatus.pending
                  : FamilyMemberStatus.active,
            ),
      syncStatus: _syncFromStorage(row['sync_status']! as String),
      syncError: row['sync_error'] as String?,
    );
  }

  Map<String, Object?> toRow() => {
    'id': id,
    'baby_id': babyId,
    'category': category.name,
    'title': title,
    'description': description,
    'starts_at': startsAt.toUtc().millisecondsSinceEpoch,
    'created_at': (createdAt ?? startsAt).toUtc().millisecondsSinceEpoch,
    'updated_at': (updatedAt ?? createdAt ?? startsAt)
        .toUtc()
        .millisecondsSinceEpoch,
    'deleted_at': deletedAt?.toUtc().millisecondsSinceEpoch,
    'caregiver_id': caregiverId,
    'source_register_event_id': sourceRegisterEventId,
    'sync_status': syncStatus.name,
    'sync_error': syncError,
  };

  Map<String, Object?> toRemoteJson() => {
    'id': id,
    'baby_id': babyId,
    'category': category.name,
    'title': title,
    'description': description,
    'starts_at': startsAt.toUtc().toIso8601String(),
    'created_at': (createdAt ?? startsAt).toUtc().toIso8601String(),
    'updated_at': (updatedAt ?? createdAt ?? startsAt)
        .toUtc()
        .toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
    'caregiver_id': caregiverId,
    'source_register_event_id': sourceRegisterEventId,
  };

  AgendaEventEntity toEntity() => AgendaEventEntity(
    id: id,
    babyId: babyId,
    category: category,
    title: title,
    description: description,
    startsAt: startsAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    caregiver: caregiver,
    caregiverId: caregiverId,
    sourceRegisterEventId: sourceRegisterEventId,
    syncStatus: syncStatus,
    syncError: syncError,
  );

  static AgendaCategory _categoryFromStorage(String value) =>
      AgendaCategory.values.firstWhere(
        (category) => category.name == value,
        orElse: () => throw FormatException('Unknown agenda category: $value'),
      );

  static AgendaSyncStatus _syncFromStorage(String value) =>
      AgendaSyncStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => throw FormatException('Unknown sync status: $value'),
      );

  static DateTime _remoteDate(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Invalid or missing remote date: $key');
    }
    return DateTime.parse(value).toUtc();
  }

  static DateTime? _nullableRemoteDate(Object? value) => switch (value) {
    final String date when date.isNotEmpty => DateTime.parse(date).toUtc(),
    _ => null,
  };
}
