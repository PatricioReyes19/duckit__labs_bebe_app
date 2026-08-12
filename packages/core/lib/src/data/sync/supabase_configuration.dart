import '../../config/app_environment.dart';

class SupabaseConfiguration {
  const SupabaseConfiguration({
    required this.url,
    required this.publishableKey,
  });

  factory SupabaseConfiguration.fromAppEnvironment(
    AppEnvironment environment,
  ) => SupabaseConfiguration(
    url: environment.supabaseUrl,
    publishableKey: environment.supabasePublishableKey,
  );

  static SupabaseConfiguration get fromEnvironment =>
      SupabaseConfiguration.fromAppEnvironment(AppEnvironment.current);

  final String url;
  final String publishableKey;

  String get normalizedUrl => url.trim().replaceFirst(RegExp(r'/$'), '');

  bool get isConfigured => switch (Uri.tryParse(normalizedUrl)) {
    final uri?
        when (uri.isScheme('https') ||
                (uri.isScheme('http') &&
                    (uri.host == 'localhost' || uri.host == '127.0.0.1'))) &&
            publishableKey.trim().isNotEmpty =>
      true,
    _ => false,
  };
}
