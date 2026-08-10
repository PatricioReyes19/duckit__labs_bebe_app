typedef AccessTokenLoader =
    Future<String?> Function({required bool forceRefresh});

/// Provides the short-lived user JWT used to authorize Supabase requests.
///
/// Implementations delegate token persistence and refresh to the selected
/// identity provider. Tokens must never be copied into the application
/// database or logs.
abstract interface class AccessTokenProvider {
  Future<String?> getToken({bool forceRefresh = false});
}

class CallbackAccessTokenProvider implements AccessTokenProvider {
  const CallbackAccessTokenProvider(this._loader);

  final AccessTokenLoader _loader;

  @override
  Future<String?> getToken({bool forceRefresh = false}) =>
      _loader(forceRefresh: forceRefresh);
}
