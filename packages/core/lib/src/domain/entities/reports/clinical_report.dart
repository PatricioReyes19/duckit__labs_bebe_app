enum ClinicalReportType {
  pediatricControl,
  symptomConsultation,
  medicationFollowUp,
  growthNutrition,
  fullHistory,
}

enum ClinicalReportSection {
  growth,
  feeding,
  medications,
  vaccines,
  appointments,
  observations,
  elimination,
  sleep,
  timeline,
  photos,
}

class ClinicalReportRequest {
  ClinicalReportRequest({
    required this.babyId,
    required this.type,
    required this.dateFrom,
    required this.dateTo,
    this.includePhotos = false,
    this.includeCaregiverNames = false,
    this.includeRawTimeline = false,
    this.includePrivateNotes = false,
    this.locale = 'es_CL',
    this.sections = const <ClinicalReportSection>{},
  }) : assert(!dateTo.isBefore(dateFrom));

  final String babyId;
  final ClinicalReportType type;
  final DateTime dateFrom;
  final DateTime dateTo;
  final bool includePhotos;
  final bool includeCaregiverNames;
  final bool includeRawTimeline;
  final bool includePrivateNotes;
  final String locale;
  final Set<ClinicalReportSection> sections;

  bool includes(ClinicalReportSection section) =>
      sections.isEmpty || sections.contains(section);
}

class ClinicalFeedingSummary {
  const ClinicalFeedingSummary({
    required this.recordCount,
    required this.averagePerDay,
    required this.subtypes,
    this.averageVolumeMl,
    this.lastFeedingAt,
  });

  final int recordCount;
  final double averagePerDay;
  final double? averageVolumeMl;
  final DateTime? lastFeedingAt;
  final Map<String, int> subtypes;
}

class ClinicalEliminationSummary {
  const ClinicalEliminationSummary({
    required this.wetDiapers,
    required this.stools,
    required this.averageWetPerDay,
    required this.averageStoolsPerDay,
    required this.anomalies,
    this.predominantConsistency,
    this.predominantColor,
    this.bloodOrMucusRecorded,
  });

  final int wetDiapers;
  final int stools;
  final double averageWetPerDay;
  final double averageStoolsPerDay;
  final String? predominantConsistency;
  final String? predominantColor;
  final bool? bloodOrMucusRecorded;
  final List<String> anomalies;
}

class ClinicalSleepSummary {
  const ClinicalSleepSummary({
    required this.completedSessions,
    required this.activeSessions,
    required this.averageMinutes,
    required this.averageNightMinutes,
    required this.averageNapsPerDay,
  });

  final int completedSessions;
  final int activeSessions;
  final double? averageMinutes;
  final double? averageNightMinutes;
  final double averageNapsPerDay;
}

class ClinicalMedicationSummary {
  const ClinicalMedicationSummary({
    required this.name,
    required this.dose,
    required this.unit,
    required this.frequency,
    required this.registeredAdministrations,
    required this.unregisteredAdministrations,
    required this.startedAt,
    required this.endedAt,
    required this.adverseEvents,
    this.route,
    this.lastAdministrationAt,
  });

  final String name;
  final String dose;
  final String unit;
  final String? route;
  final String frequency;
  final int registeredAdministrations;

  /// Configured administration slots without a matching record. This is not
  /// evidence that a dose was omitted and must be labelled "sin registro".
  final int unregisteredAdministrations;
  final DateTime startedAt;
  final DateTime endedAt;
  final DateTime? lastAdministrationAt;
  final List<String> adverseEvents;
}

class ClinicalGrowthPoint {
  const ClinicalGrowthPoint({
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
  });

  final String type;
  final double value;
  final String unit;
  final DateTime recordedAt;
}

class ClinicalReportItem {
  const ClinicalReportItem({
    required this.occurredAt,
    required this.title,
    required this.detail,
    this.status,
    this.professional,
  });

  final DateTime occurredAt;
  final String title;
  final String detail;
  final String? status;
  final String? professional;
}

class ClinicalTimelineItem {
  const ClinicalTimelineItem({
    required this.occurredAt,
    required this.type,
    required this.detail,
    this.caregiverName,
  });

  final DateTime occurredAt;
  final String type;
  final String detail;
  final String? caregiverName;
}

class ClinicalReportData {
  const ClinicalReportData({
    required this.reportId,
    required this.request,
    required this.babyName,
    required this.birthDate,
    required this.generatedAt,
    required this.summary,
    required this.feeding,
    required this.elimination,
    required this.sleep,
    required this.medications,
    required this.growth,
    required this.vaccines,
    required this.appointments,
    required this.observations,
    required this.timeline,
    required this.photoPaths,
    this.appVersion = 'unknown',
    this.dataVersion = 1,
  });

  final String reportId;
  final ClinicalReportRequest request;
  final String babyName;
  final DateTime birthDate;
  final DateTime generatedAt;
  final String summary;
  final ClinicalFeedingSummary feeding;
  final ClinicalEliminationSummary elimination;
  final ClinicalSleepSummary sleep;
  final List<ClinicalMedicationSummary> medications;
  final List<ClinicalGrowthPoint> growth;
  final List<ClinicalReportItem> vaccines;
  final List<ClinicalReportItem> appointments;
  final List<ClinicalReportItem> observations;
  final List<ClinicalTimelineItem> timeline;
  final List<String> photoPaths;
  final String appVersion;
  final int dataVersion;
}
