enum AppEnvironmentType {
  development,
  staging,
  production;

  static AppEnvironmentType? tryParse(String value) {
    for (final environment in values) {
      if (environment.name == value.trim().toLowerCase()) {
        return environment;
      }
    }
    return null;
  }
}

/// Configuración de despliegue compilada mediante `--dart-define-from-file`.
///
/// Las aplicaciones deben consumir esta clase en vez de leer variables con
/// `String.fromEnvironment` directamente. De ese modo, las claves y sus
/// validaciones permanecen centralizadas en `core`.
final class AppEnvironment {
  const AppEnvironment({
    required this.name,
    required this.appDisplayName,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.invitationBaseUrl,
    required this.enableVerboseLogs,
  });

  static const current = AppEnvironment(
    name: String.fromEnvironment(
      'APP_ENVIRONMENT',
      defaultValue: 'development',
    ),
    appDisplayName: String.fromEnvironment(
      'APP_DISPLAY_NAME',
      defaultValue: 'BebéApp',
    ),
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    invitationBaseUrl: String.fromEnvironment(
      'INVITATION_BASE_URL',
      defaultValue: 'https://bebe.app',
    ),
    enableVerboseLogs: bool.fromEnvironment('ENABLE_VERBOSE_LOGS'),
  );

  final String name;
  final String appDisplayName;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String invitationBaseUrl;
  final bool enableVerboseLogs;

  AppEnvironmentType? get type => AppEnvironmentType.tryParse(name);

  bool get isDevelopment => type == AppEnvironmentType.development;
  bool get isStaging => type == AppEnvironmentType.staging;
  bool get isProduction => type == AppEnvironmentType.production;

  Uri? get supabaseUri => Uri.tryParse(supabaseUrl.trim());
  Uri? get invitationBaseUri => Uri.tryParse(invitationBaseUrl.trim());

  bool get hasSupabaseConfiguration =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;

  Uri invitationUri(String code) {
    final baseUri = invitationBaseUri;
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      throw StateError('INVITATION_BASE_URL no es una URL válida.');
    }

    return baseUri.replace(
      path: _joinPath(baseUri.path, 'invitation'),
      queryParameters: {'code': code},
    );
  }

  /// Falla temprano si el archivo de entorno está incompleto o no coincide
  /// con el flavor seleccionado por Android/iOS.
  void ensureValid({String? platformFlavor}) {
    final errors = validationErrors(platformFlavor: platformFlavor);
    if (errors.isNotEmpty) {
      throw StateError(
        'Configuración de entorno inválida: ${errors.join(' ')}',
      );
    }
  }

  List<String> validationErrors({String? platformFlavor}) {
    final errors = <String>[];
    if (type == null) {
      errors.add('APP_ENVIRONMENT "$name" no está soportado.');
    }
    if (appDisplayName.trim().isEmpty) {
      errors.add('APP_DISPLAY_NAME está vacío.');
    }
    if (hasSupabaseConfiguration) {
      final uri = supabaseUri;
      final validSupabaseUrl =
          uri != null &&
          (uri.isScheme('https') ||
              (uri.isScheme('http') &&
                  (uri.host == 'localhost' || uri.host == '127.0.0.1')));
      if (!validSupabaseUrl) {
        errors.add('SUPABASE_URL no es una URL permitida.');
      }
    } else if (supabaseUrl.trim().isNotEmpty ||
        supabasePublishableKey.trim().isNotEmpty) {
      errors.add(
        'SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY deben definirse juntas.',
      );
    }
    final invitationUri = invitationBaseUri;
    if (invitationUri == null ||
        !invitationUri.isScheme('https') ||
        invitationUri.host.isEmpty) {
      errors.add('INVITATION_BASE_URL debe ser una URL HTTPS válida.');
    }
    final normalizedFlavor = platformFlavor?.trim().toLowerCase();
    if (normalizedFlavor != null &&
        normalizedFlavor.isNotEmpty &&
        normalizedFlavor != name.trim().toLowerCase()) {
      errors.add(
        'El flavor nativo "$platformFlavor" no coincide con '
        'APP_ENVIRONMENT "$name".',
      );
    }
    return errors;
  }

  static String _joinPath(String basePath, String child) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return '$normalizedBase/$child';
  }
}
