import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';

void main() {
  test('todas las secciones de salud tienen una ruta estable', () {
    expect(
      {
        for (final kind in HealthSectionKind.values)
          kind: HealthSectionPage.locationFor(kind),
      },
      {
        HealthSectionKind.vaccines: '/health/vaccines',
        HealthSectionKind.controls: '/health/controls',
        HealthSectionKind.growth: '/health/growth',
        HealthSectionKind.consultations: '/health/consultations',
        HealthSectionKind.pediatricCare: '/health/pediatric-care',
        HealthSectionKind.clinicalHistory: '/health/clinical-history',
        HealthSectionKind.reports: '/health/reports',
        HealthSectionKind.sync: '/health/sync',
      },
    );
  });

  test('las acciones generan subrutas navegables', () {
    expect(
      HealthSectionPage.flowLocation(
        HealthSectionKind.vaccines,
        HealthFlowAction.register,
      ),
      '/health/vaccines/register',
    );
    expect(
      HealthSectionPage.flowLocation(
        HealthSectionKind.reports,
        HealthFlowAction.export,
      ),
      '/health/reports/export',
    );
  });
}
