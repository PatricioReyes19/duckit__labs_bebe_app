import '../../../domain/entities/session/auth_user.dart';
import '../../network/supabase_rest_client.dart';

abstract interface class ProfileRemoteDataSource {
  bool get isConfigured;

  Future<bool> isAuthenticated();

  Future<void> syncAuthenticatedUser(AuthUser user);
}

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  const SupabaseProfileRemoteDataSource(this._client);

  final SupabaseRestClient _client;

  @override
  bool get isConfigured => _client.isConfigured;

  @override
  Future<bool> isAuthenticated() => _client.isAuthenticated();

  @override
  Future<void> syncAuthenticatedUser(AuthUser user) async {
    if (!isConfigured || !await isAuthenticated()) return;
    await _client.rpc(
      'upsert_current_profile',
      parameters: {'p_display_name': user.displayName, 'p_email': user.email},
    );
  }
}
