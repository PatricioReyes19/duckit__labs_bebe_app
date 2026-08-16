import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/onboarding_repository/active_context_repository.dart';

class SharedPreferencesActiveContextRepository
    implements ActiveContextRepository {
  const SharedPreferencesActiveContextRepository(this._preferences);

  static const storageKey = 'bebeapp.active_context.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<ActiveContext?> read() async {
    final encoded = await _preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) return null;
      final userId = decoded['userId'];
      final circleId = decoded['circleId'];
      final babyId = decoded['babyId'];
      if (userId is! String || userId.isEmpty) return null;
      if (circleId is! String || circleId.isEmpty) return null;
      if (babyId is! String || babyId.isEmpty) return null;
      return ActiveContext(userId: userId, circleId: circleId, babyId: babyId);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(ActiveContext context) => _preferences.setString(
    storageKey,
    jsonEncode({
      'userId': context.userId,
      'circleId': context.circleId,
      'babyId': context.babyId,
    }),
  );

  @override
  Future<void> clear() => _preferences.remove(storageKey);
}
