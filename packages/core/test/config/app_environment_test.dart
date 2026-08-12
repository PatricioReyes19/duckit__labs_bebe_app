import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const environment = AppEnvironment(
    name: 'development',
    appDisplayName: 'BebéApp Dev',
    supabaseUrl: 'https://project.supabase.co',
    supabasePublishableKey: 'sb_publishable_test',
    invitationBaseUrl: 'https://bebe.app',
    enableVerboseLogs: true,
  );

  test('expone las variables tipadas del entorno', () {
    expect(environment.type, AppEnvironmentType.development);
    expect(environment.isDevelopment, isTrue);
    expect(environment.hasSupabaseConfiguration, isTrue);
    expect(
      environment.validationErrors(platformFlavor: 'development'),
      isEmpty,
    );
  });

  test('construye el enlace de invitación desde la URL centralizada', () {
    expect(
      environment.invitationUri('A B').toString(),
      'https://bebe.app/invitation?code=A+B',
    );
  });

  test('detecta un flavor nativo distinto al entorno Dart', () {
    expect(
      environment.validationErrors(platformFlavor: 'production'),
      contains(contains('no coincide')),
    );
  });

  test('rechaza una configuración Supabase parcial', () {
    const invalid = AppEnvironment(
      name: 'development',
      appDisplayName: 'BebéApp Dev',
      supabaseUrl: 'https://project.supabase.co',
      supabasePublishableKey: '',
      invitationBaseUrl: 'https://bebe.app',
      enableVerboseLogs: false,
    );

    expect(
      invalid.validationErrors(),
      contains(contains('deben definirse juntas')),
    );
  });
}
