class SupabaseConfiguration {
  const SupabaseConfiguration({
    required this.url,
    required this.publishableKey,
  });

  static const fromEnvironment = SupabaseConfiguration(
    url: String.fromEnvironment('SUPABASE_URL'),
    publishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

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
