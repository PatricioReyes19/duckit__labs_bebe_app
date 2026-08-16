import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('persists user, circle and baby as one active context', () async {
    final repository = SharedPreferencesActiveContextRepository(
      SharedPreferencesAsync(),
    );
    const context = ActiveContext(
      userId: 'user-a',
      circleId: 'family-a',
      babyId: 'baby-a',
    );

    await repository.save(context);
    final restored = await repository.read();

    expect(restored?.userId, 'user-a');
    expect(restored?.circleId, 'family-a');
    expect(restored?.babyId, 'baby-a');
  });

  test('corrupt persisted context is treated as unknown, not empty', () async {
    final preferences = SharedPreferencesAsync();
    await preferences.setString(
      SharedPreferencesActiveContextRepository.storageKey,
      '{invalid',
    );
    final repository = SharedPreferencesActiveContextRepository(preferences);

    expect(await repository.read(), isNull);
  });
}
