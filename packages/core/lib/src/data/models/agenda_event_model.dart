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
    this.caregiverId,
    this.caregiver,
  });

  final String id;
  final String babyId;
  final AgendaCategory category;
  final String title;
  final String description;
  final DateTime startsAt;
  final String? caregiverId;
  final FamilyMemberEntity? caregiver;
  final AgendaSyncStatus syncStatus;

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
      caregiverId: row['caregiver_id'] as String?,
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
    );
  }

  Map<String, Object?> toRow() => {
    'id': id,
    'baby_id': babyId,
    'category': category.name,
    'title': title,
    'description': description,
    'starts_at': startsAt.toUtc().millisecondsSinceEpoch,
    'caregiver_id': caregiverId,
    'sync_status': syncStatus.name,
  };

  AgendaEventEntity toEntity() => AgendaEventEntity(
    id: id,
    babyId: babyId,
    category: category,
    title: title,
    description: description,
    startsAt: startsAt,
    caregiver: caregiver,
    syncStatus: syncStatus,
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
}
