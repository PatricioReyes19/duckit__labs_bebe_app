import 'package:sqflite/sqflite.dart';

import '../../domain/entities/agenda/agenda.dart';
import '../../domain/entities/family/family.dart';
import '../../domain/entities/health/health.dart';
import '../models/agenda_event_model.dart';
import '../models/family_models.dart';
import '../models/health_models.dart';
import 'bebe_database_schema.dart';

abstract final class BebeSeedData {
  static const familyId = 'family-local';
  static const activeBabyId = 'local-active-baby';

  static Future<void> insert(Database database) async {
    final batch = database.batch();
    batch.insert(
      BebeDatabaseSchema.families,
      const FamilyModel(
        id: familyId,
        name: 'Familia Reyes González',
        activeBabyId: activeBabyId,
      ).toRow(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    for (final baby in _babies) {
      batch.insert(
        BebeDatabaseSchema.babies,
        baby.toRow(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    for (final member in _members) {
      batch.insert(
        BebeDatabaseSchema.familyMembers,
        member.toRow(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    for (final event in _agendaEvents) {
      batch.insert(
        BebeDatabaseSchema.agendaEvents,
        event.toRow(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    for (final event in _healthEvents) {
      batch.insert(
        BebeDatabaseSchema.healthEvents,
        event.toRow(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    for (final measurement in _healthMeasurements) {
      batch.insert(
        BebeDatabaseSchema.healthMeasurements,
        measurement.toRow(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    batch.insert(BebeDatabaseSchema.appSettings, const {
      'id': 'local',
      'theme_mode': 'system',
      'high_contrast': 0,
      'personal_reminders': 1,
      'family_activity': 1,
      'daily_summary': 0,
      'reduce_motion': 0,
      'wifi_only': 0,
      'account_name': 'Usuario Bypass',
      'account_email': 'bypass@local.bebeapp',
      'language': 'Español',
      'time_format': '24 horas',
      'text_size': 'Predeterminado',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await batch.commit(noResult: true);
  }

  static final _babies = <BabyModel>[
    BabyModel(
      id: activeBabyId,
      familyId: familyId,
      name: 'Mateo Reyes',
      birthDate: DateTime.utc(2026, 6, 1),
      avatarAssetPath: 'assets/images/baby_avatar.png',
    ),
    BabyModel(
      id: 'sofia',
      familyId: familyId,
      name: 'Sofía Reyes',
      birthDate: DateTime.utc(2025, 12, 1),
      avatarAssetPath: 'assets/images/baby_avatar.png',
    ),
  ];

  static const _members = <FamilyMemberModel>[
    FamilyMemberModel(
      id: 'mother',
      familyId: familyId,
      name: 'Gesslien González',
      role: 'Mamá',
      accessDescription: 'Puede registrar y ver salud',
      status: FamilyMemberStatus.active,
    ),
    FamilyMemberModel(
      id: 'father',
      familyId: familyId,
      name: 'Patricio Reyes',
      role: 'Papá',
      accessDescription: 'Puede registrar y ver salud',
      status: FamilyMemberStatus.active,
    ),
    FamilyMemberModel(
      id: 'grandmother',
      familyId: familyId,
      name: 'Rosa González',
      role: 'Abuela',
      accessDescription: 'Acceso de colaboración',
      status: FamilyMemberStatus.active,
    ),
    FamilyMemberModel(
      id: 'aunt',
      familyId: familyId,
      name: 'Carolina Soto',
      role: 'Tía',
      accessDescription: 'Invitación pendiente',
      status: FamilyMemberStatus.pending,
    ),
  ];

  static final _agendaEvents = <AgendaEventModel>[
    AgendaEventModel(
      id: 'vaccine-pcv13',
      babyId: activeBabyId,
      category: AgendaCategory.vaccines,
      title: 'Vacuna Neumococo (PCV13)',
      description: 'Segunda dosis',
      startsAt: DateTime.utc(2026, 8, 10, 14),
      caregiverId: 'mother',
      syncStatus: AgendaSyncStatus.synced,
    ),
    AgendaEventModel(
      id: 'vitamin-d',
      babyId: activeBabyId,
      category: AgendaCategory.medication,
      title: 'Vitamina D',
      description: 'Administrar dosis indicada',
      startsAt: DateTime.utc(2026, 8, 6, 23),
      syncStatus: AgendaSyncStatus.synced,
    ),
    AgendaEventModel(
      id: 'laboratory-exam',
      babyId: activeBabyId,
      category: AgendaCategory.exams,
      title: 'Examen de laboratorio',
      description: 'Llevar orden médica y antecedentes',
      startsAt: DateTime.utc(2026, 8, 18, 12, 30),
      syncStatus: AgendaSyncStatus.synced,
    ),
  ];

  static final _healthEvents = <HealthEventModel>[
    for (var dose = 1; dose <= 4; dose++)
      HealthEventModel(
        id: 'completed-vaccine-$dose',
        babyId: activeBabyId,
        type: HealthEventType.vaccine,
        title: 'Vacuna dosis $dose',
        description: 'Dosis administrada',
        startsAt: DateTime.utc(2026, 4 + dose, 1),
        caregiverId: 'mother',
        status: HealthEventStatus.completed,
      ),
    HealthEventModel(
      id: 'vaccine-pneumococcus-2',
      babyId: activeBabyId,
      type: HealthEventType.vaccine,
      title: 'Vacuna Neumococo',
      description: 'Segunda dosis',
      startsAt: DateTime.utc(2026, 8, 10, 14),
      caregiverId: 'mother',
      status: HealthEventStatus.scheduled,
    ),
    HealthEventModel(
      id: 'pediatric-control',
      babyId: activeBabyId,
      type: HealthEventType.pediatricControl,
      title: 'Control pediátrico',
      description: 'Chequeo de rutina',
      startsAt: DateTime.utc(2026, 8, 14, 13),
      caregiverId: 'father',
      status: HealthEventStatus.scheduled,
    ),
    HealthEventModel(
      id: 'growth-control',
      babyId: activeBabyId,
      type: HealthEventType.growthControl,
      title: 'Control de crecimiento',
      description: 'Registro de peso y talla',
      startsAt: DateTime.utc(2026, 8, 18, 15, 30),
      caregiverId: 'mother',
      status: HealthEventStatus.scheduled,
    ),
  ];

  static final _healthMeasurements = <HealthMeasurementModel>[
    HealthMeasurementModel(
      id: 'weight-current',
      babyId: activeBabyId,
      type: HealthMeasurementType.weight,
      value: 7.25,
      unit: 'kg',
      recordedAt: DateTime.utc(2026, 8, 6, 12),
      source: 'home',
    ),
    HealthMeasurementModel(
      id: 'height-current',
      babyId: activeBabyId,
      type: HealthMeasurementType.height,
      value: 65,
      unit: 'cm',
      recordedAt: DateTime.utc(2026, 8, 6, 12),
      source: 'home',
    ),
  ];
}
