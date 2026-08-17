import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/models/health_flow_controller.dart';

void main() {
  final now = DateTime.utc(2026, 8, 16, 12);

  test('UT-REPORT-001: 1d uses an inclusive 24-hour window', () {
    final report = HealthReportSnapshot.project(
      records: [
        _event('boundary', now.subtract(const Duration(days: 1))),
        _event('older', now.subtract(const Duration(days: 1, seconds: 1))),
        _event('future', now.add(const Duration(seconds: 1))),
      ],
      babyId: 'baby-1',
      range: HealthReportRange.day,
      now: now,
    );

    expect(report.records.map((event) => event.id), ['boundary']);
  });

  test('UT-REPORT-002/003: 7d and 30d share the same boundaries', () {
    final records = [
      _event('day-6', now.subtract(const Duration(days: 6))),
      _event('day-8', now.subtract(const Duration(days: 8))),
      _event('day-29', now.subtract(const Duration(days: 29))),
      _event('day-31', now.subtract(const Duration(days: 31))),
    ];

    final week = HealthReportSnapshot.project(
      records: records,
      babyId: 'baby-1',
      range: HealthReportRange.week,
      now: now,
    );
    final month = HealthReportSnapshot.project(
      records: records,
      babyId: 'baby-1',
      range: HealthReportRange.month,
      now: now,
    );

    expect(week.records.map((event) => event.id), ['day-6']);
    expect(month.records.map((event) => event.id), [
      'day-6',
      'day-8',
      'day-29',
    ]);
  });

  test('UT-REPORT-004: no-data is different from a recorded zero', () {
    final empty = HealthReportSnapshot.project(
      records: const [],
      babyId: 'baby-1',
      range: HealthReportRange.day,
      now: now,
    );
    final recordedZero = HealthReportSnapshot.project(
      records: [
        _event('feeding-zero', now, details: const {'amount_ml': 0}),
      ],
      babyId: 'baby-1',
      range: HealthReportRange.day,
      now: now,
    );

    expect(empty.feedingVolumeMl, isNull);
    expect(recordedZero.feedingVolumeMl, 0);
    expect(recordedZero.feedings, hasLength(1));
  });

  test('UT-REPORT-005/006: deleted and other-baby rows are excluded', () {
    final report = HealthReportSnapshot.project(
      records: [
        _event('visible', now),
        _event('deleted', now, deletedAt: now),
        _event('other', now, babyId: 'baby-2'),
      ],
      babyId: 'baby-1',
      range: HealthReportRange.day,
      now: now,
    );

    expect(report.records.map((event) => event.id), ['visible']);
  });

  test('active sleep is reported but never added as infinite duration', () {
    final report = HealthReportSnapshot.project(
      records: [
        _event(
          'active',
          now.subtract(const Duration(hours: 10)),
          type: RegisterEventType.sleep,
          details: const {
            'sleep_status': 'ongoing',
            'duration_minutes': null,
            'end_at': null,
          },
        ),
        _event(
          'finished',
          now.subtract(const Duration(hours: 2)),
          type: RegisterEventType.sleep,
          details: {
            'sleep_status': 'completed',
            'duration_minutes': 90,
            'end_at': now
                .subtract(const Duration(minutes: 30))
                .toIso8601String(),
          },
        ),
      ],
      babyId: 'baby-1',
      range: HealthReportRange.day,
      now: now,
    );

    expect(report.activeSleeps, hasLength(1));
    expect(report.completedSleeps, hasLength(1));
    expect(report.sleepDurationMinutes, 90);
    expect(report.dailyCounts(RegisterEventType.sleep).single, 1);
  });

  test('partial data preserves available metrics', () {
    final report = HealthReportSnapshot.project(
      records: [
        _event(
          'diaper',
          now,
          type: RegisterEventType.diaper,
          details: const {'diaper_type': 'wet'},
        ),
      ],
      babyId: 'baby-1',
      range: HealthReportRange.day,
      now: now,
    );

    expect(report.diapers, hasLength(1));
    expect(report.feedings, isEmpty);
    expect(report.sleepDurationMinutes, isNull);
    expect(report.hasActivityTrendData, isTrue);
  });
}

RegisteredEvent _event(
  String id,
  DateTime occurredAt, {
  String babyId = 'baby-1',
  RegisterEventType type = RegisterEventType.feeding,
  Map<String, Object?> details = const {'amount_ml': 90},
  DateTime? deletedAt,
}) => RegisteredEvent(
  id: id,
  babyId: babyId,
  type: type,
  occurredAt: occurredAt,
  createdAt: occurredAt,
  updatedAt: occurredAt,
  details: details,
  deletedAt: deletedAt,
  syncStatus: RegisterSyncStatus.synced,
);
