import 'package:core/core.dart';

/// Creates the minimum valid parent graph required by Baby-owned test data.
Future<void> insertBabyFixture(
  BebeDatabase database, {
  List<String> babyIds = const ['baby-1'],
}) async {
  final sqlite = await database.database;
  await sqlite.transaction((transaction) async {
    await transaction.insert(BebeDatabaseSchema.families, {
      'id': 'family-1',
      'name': 'Familia de prueba',
      'active_baby_id': babyIds.first,
    });
    for (final babyId in babyIds) {
      await transaction.insert(BebeDatabaseSchema.babies, {
        'id': babyId,
        'family_id': 'family-1',
        'name': babyId,
        'birth_date': DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
        'avatar_asset_path': null,
      });
    }
  });
}
