import '../family/family.dart';

/// Clinical type of an item in the official immunization catalogue.
///
/// Nirsevimab deliberately belongs to [monoclonalAntibody], never to
/// [vaccine]. This distinction is carried through the catalogue, UI and the
/// persisted administration record.
enum ImmunizationItemType { vaccine, monoclonalAntibody }

/// Programme source, kept separate from clinical recommendation status.
enum ImmunizationSourceType {
  pniProgrammatic,
  minsalCampaign,
  complementaryPrivate,
  physicianIndicated,
}

enum ImmunizationEligibilityRule {
  all,
  bornOnOrAfter,
  premature,
  rapaNui,
  influenzaCampaign,
  rsvCampaignNewborn,
  rsvCampaignInfant,
  rsvRisk,
}

class ImmunizationCatalog {
  const ImmunizationCatalog({
    required this.version,
    required this.sourceName,
    required this.items,
  });

  final String version;
  final String sourceName;
  final List<ImmunizationCatalogItem> items;
}

class ImmunizationCatalogItem {
  const ImmunizationCatalogItem({
    required this.id,
    required this.displayName,
    required this.itemType,
    required this.sourceType,
    required this.targetAge,
    required this.doseLabel,
    required this.eligibilityRule,
    required this.sourceVersion,
    required this.sourceName,
    this.effectiveFrom,
    this.effectiveTo,
    this.minimumBirthDate,
    this.maximumBirthDate,
    this.campaignStart,
    this.campaignEnd,
    this.campaignOffsetDays = 0,
    this.minimumAgeMonths,
    this.maximumAgeMonths,
    this.administrationGroup,
    this.administrationPriority = 0,
    this.isActive = true,
  });

  final String id;
  final String displayName;
  final ImmunizationItemType itemType;
  final ImmunizationSourceType sourceType;
  final ImmunizationTargetAge targetAge;
  final String doseLabel;
  final ImmunizationEligibilityRule eligibilityRule;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final String sourceVersion;
  final String sourceName;
  final DateTime? minimumBirthDate;
  final DateTime? maximumBirthDate;
  final DateTime? campaignStart;
  final DateTime? campaignEnd;

  /// Offset applied when a campaign begins after the age-based target date.
  /// Keeping it in catalogue data allows campaign multi-dose intervals to be
  /// changed without changing presentation code.
  final int campaignOffsetDays;
  final int? minimumAgeMonths;
  final int? maximumAgeMonths;

  /// Alternative catalogue entries that represent one administration share
  /// this key (for example the 2026 Nirsevimab campaign cohorts).
  final String? administrationGroup;
  final int administrationPriority;
  final bool isActive;

  String get sourceBadge => switch (sourceType) {
    ImmunizationSourceType.pniProgrammatic => 'PNI',
    ImmunizationSourceType.minsalCampaign => 'Campaña MINSAL',
    ImmunizationSourceType.complementaryPrivate => 'Particular',
    ImmunizationSourceType.physicianIndicated => 'Indicada',
  };
}

class ImmunizationTargetAge {
  const ImmunizationTargetAge({this.days = 0, this.months = 0});

  final int days;
  final int months;

  DateTime at(DateTime birthDate) {
    final local = birthDate.toLocal();
    return DateTime(local.year, local.month + months, local.day + days);
  }
}

/// Information needed to evaluate an official eligibility rule. Unknown
/// clinical conditions default to false so the app never asserts eligibility
/// for a risk-only item without an explicit profile confirmation.
class ImmunizationEligibilityContext {
  const ImmunizationEligibilityContext({
    required this.birthDate,
    this.isPremature = false,
    this.livesInRapaNui = false,
    this.hasRsvRisk = false,
    this.hasCompletedInfluenzaSeries = false,
  });

  factory ImmunizationEligibilityContext.fromBaby(BabyEntity baby) =>
      ImmunizationEligibilityContext(
        birthDate: baby.birthDate,
        isPremature: baby.isPremature,
        livesInRapaNui: baby.livesInRapaNui,
        hasRsvRisk: baby.hasRsvRisk,
      );

  final DateTime birthDate;
  final bool isPremature;
  final bool livesInRapaNui;
  final bool hasRsvRisk;
  final bool hasCompletedInfluenzaSeries;
}

/// Immutable snapshot of a real administration. [nameSnapshot] and
/// [doseLabel] intentionally survive any future catalogue update.
class ImmunizationRecord {
  const ImmunizationRecord({
    required this.id,
    required this.babyId,
    required this.nameSnapshot,
    required this.doseLabel,
    required this.administeredAt,
    required this.createdBy,
    this.catalogItemId,
    this.itemType = ImmunizationItemType.vaccine,
    this.sourceType,
    this.sourceVersion,
    this.facility,
    this.lotNumber,
    this.professional,
    this.notes,
  });

  final String id;
  final String babyId;
  final String? catalogItemId;
  final String nameSnapshot;
  final String doseLabel;
  final DateTime administeredAt;
  final String createdBy;
  final ImmunizationItemType itemType;
  final ImmunizationSourceType? sourceType;
  final String? sourceVersion;
  final String? facility;
  final String? lotNumber;
  final String? professional;
  final String? notes;
}

class PlannedImmunization {
  const PlannedImmunization({
    required this.item,
    required this.scheduledAt,
    required this.isPending,
  });

  final ImmunizationCatalogItem item;
  final DateTime scheduledAt;
  final bool isPending;
}

/// Applies the versioned rules in [ImmunizationCatalog] without placing
/// clinical rules inside widgets. A scheduled item is omitted once an
/// administration with the same catalogue ID exists.
class ImmunizationSchedulePlanner {
  const ImmunizationSchedulePlanner();

  List<PlannedImmunization> plan({
    required ImmunizationCatalog catalog,
    required ImmunizationEligibilityContext context,
    required Iterable<ImmunizationRecord> records,
    required DateTime now,
  }) {
    final completedIds = records
        .where((record) => record.catalogItemId?.trim().isNotEmpty == true)
        .map((record) => record.catalogItemId!)
        .toSet();
    final itemById = {for (final item in catalog.items) item.id: item};
    final completedAdministrationGroups = records
        .map((record) => itemById[record.catalogItemId]?.administrationGroup)
        .whereType<String>()
        .toSet();
    final hasInfluenzaSeries =
        context.hasCompletedInfluenzaSeries ||
        records
                .where(
                  (record) =>
                      record.catalogItemId?.startsWith('influenza-') ?? false,
                )
                .length >=
            2;

    final planned = <PlannedImmunization>[];
    for (final item in catalog.items) {
      if (!item.isActive ||
          completedIds.contains(item.id) ||
          (item.administrationGroup != null &&
              completedAdministrationGroups.contains(
                item.administrationGroup,
              ))) {
        continue;
      }
      final scheduledAt = _scheduledAt(item, context.birthDate);
      if (!_isEffective(item, scheduledAt) ||
          !_isEligible(item, context, now, hasInfluenzaSeries)) {
        continue;
      }
      planned.add(
        PlannedImmunization(
          item: item,
          scheduledAt: scheduledAt,
          isPending: scheduledAt.isBefore(_startOfDay(now)),
        ),
      );
    }
    planned.sort(
      (first, second) => first.scheduledAt.compareTo(second.scheduledAt),
    );
    final bestAdministrationPriority = <String, int>{};
    for (final plannedItem in planned) {
      final group = plannedItem.item.administrationGroup;
      if (group == null) continue;
      final current = bestAdministrationPriority[group];
      if (current == null ||
          plannedItem.item.administrationPriority < current) {
        bestAdministrationPriority[group] =
            plannedItem.item.administrationPriority;
      }
    }
    return List.unmodifiable(
      planned.where((item) {
        final group = item.item.administrationGroup;
        return group == null ||
            item.item.administrationPriority ==
                bestAdministrationPriority[group];
      }),
    );
  }

  DateTime _scheduledAt(ImmunizationCatalogItem item, DateTime birthDate) {
    final target = item.targetAge.at(birthDate);
    final campaignStart = item.campaignStart;
    if (campaignStart != null && target.isBefore(campaignStart)) {
      return campaignStart.add(Duration(days: item.campaignOffsetDays));
    }
    return target;
  }

  bool _isEffective(ImmunizationCatalogItem item, DateTime scheduledAt) {
    final from = item.effectiveFrom;
    if (from != null && scheduledAt.isBefore(from)) return false;
    final to = item.effectiveTo;
    if (to != null && scheduledAt.isAfter(to)) return false;
    return true;
  }

  bool _isEligible(
    ImmunizationCatalogItem item,
    ImmunizationEligibilityContext context,
    DateTime now,
    bool hasInfluenzaSeries,
  ) {
    final birthDate = _startOfDay(context.birthDate);
    final ageInMonths = _calendarMonthsBetween(birthDate, _startOfDay(now));
    final minimumAgeMonths = item.minimumAgeMonths;
    if (minimumAgeMonths != null && ageInMonths < minimumAgeMonths) {
      return false;
    }
    final maximumAgeMonths = item.maximumAgeMonths;
    if (maximumAgeMonths != null && ageInMonths > maximumAgeMonths) {
      return false;
    }
    final minimumBirthDate = item.minimumBirthDate;
    if (minimumBirthDate != null &&
        birthDate.isBefore(_startOfDay(minimumBirthDate))) {
      return false;
    }
    final maximumBirthDate = item.maximumBirthDate;
    if (maximumBirthDate != null &&
        birthDate.isAfter(_startOfDay(maximumBirthDate))) {
      return false;
    }
    final campaignStart = item.campaignStart;
    if (campaignStart != null && now.isBefore(campaignStart)) return false;
    final campaignEnd = item.campaignEnd;
    if (campaignEnd != null && now.isAfter(campaignEnd)) return false;

    return switch (item.eligibilityRule) {
      ImmunizationEligibilityRule.all ||
      ImmunizationEligibilityRule.bornOnOrAfter ||
      ImmunizationEligibilityRule.rsvCampaignNewborn ||
      ImmunizationEligibilityRule.rsvCampaignInfant => true,
      ImmunizationEligibilityRule.premature => context.isPremature,
      ImmunizationEligibilityRule.rapaNui => context.livesInRapaNui,
      ImmunizationEligibilityRule.rsvRisk => context.hasRsvRisk,
      ImmunizationEligibilityRule.influenzaCampaign =>
        !hasInfluenzaSeries || item.doseLabel.startsWith('1'),
    };
  }

  static DateTime _startOfDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static int _calendarMonthsBetween(DateTime from, DateTime until) {
    var months = (until.year - from.year) * 12 + until.month - from.month;
    if (until.day < from.day) months--;
    return months;
  }
}
